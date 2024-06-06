import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Usage App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<List<dynamic>>> _data;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _data = loadCsvData();
    processCsvAndUpdateFirebase();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<List<List<dynamic>>> loadCsvData() async {
    final rawData = await rootBundle.loadString("Csv_files/Water Usage Data.csv");
    List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);
    return listData;
  }

  bool detectLeak(List<List<dynamic>> data) {
    for (var row in data) {
      if (row[6].toString().toLowerCase() == 'yes') {
        return true;
      }
    }
    return false;
  }

  Future<void> updateFirebaseWithLeakStatus(bool isLeak) async {
    await FirebaseFirestore.instance
        .collection('waterUsage')
        .doc('latest')
        .set({'leakDetected': isLeak});
  }

  Future<void> updateFirebaseWithUsageData(Map<String, dynamic> usageData) async {
    await FirebaseFirestore.instance
        .collection('waterUsage')
        .doc('latest')
        .update(usageData);
  }

  Future<void> sendPlumberRequestToFirebase() async {
    await FirebaseFirestore.instance
        .collection('plumberRequests')
        .add({'requestTime': DateTime.now()});
  }

  void showNotificationForLeak() async {
    var androidDetails = AndroidNotificationDetails('Water Leak', 'Water Leak Notification');
    var generalNotificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Water Leak Detected',
      'A potential water leak has been detected in your system. Immediate attention required.',
      generalNotificationDetails,
    );
  }

  Future<void> processCsvAndUpdateFirebase() async {
    final List<List<dynamic>> csvData = await loadCsvData();
    final bool isLeak = detectLeak(csvData);
    await updateFirebaseWithLeakStatus(isLeak);

    if (isLeak) {
      showNotificationForLeak();
    }

    final Map<String, dynamic> usageData = {
      'dailyAverageUsage': csvData.last[1],
      'peakUsageTime': csvData.last[2],
      'washroomUsage': csvData.last[3],
      'kitchenUsage': csvData.last[4],
      'gardenUsage': csvData.last[5],
      'bathroomUsage': csvData.last[6],
    };

    await updateFirebaseWithUsageData(usageData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Water Usage Analysis'),
      ),
      body: FutureBuilder<List<List<dynamic>>>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  LeakStatusIndicator(isLeakPresent: detectLeak(snapshot.data!)),
                  UsageDataTable(snapshot.data!.last),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Get Plumber"),
                content: Text("Plumber service requested."),
              );
            },
          );
        },
        child: Icon(Icons.build),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class LeakStatusIndicator extends StatelessWidget {
  final bool isLeakPresent;

  const LeakStatusIndicator({Key? key, required this.isLeakPresent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        isLeakPresent ? 'No water leak found!' : 'You may have a leak!',
        style: TextStyle(color: isLeakPresent ? Colors.green : Colors.red),
      ),
      leading: Icon(
        isLeakPresent ? Icons.check_circle_outline : Icons.warning_rounded,
        color: isLeakPresent ? Colors.green : Colors.red,
      ),
    );
  }
}

class UsageDataTable extends StatelessWidget {
  final List<dynamic> usageData;

  UsageDataTable(this.usageData);

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const <DataColumn>[
        DataColumn(label: Text('Category')),
        DataColumn(label: Text('Usage (Liters)')),
      ],
      rows: <DataRow>[
        DataRow(cells: [DataCell(Text('Daily Average')), DataCell(Text('${usageData[1]}'))]),
        DataRow(cells: [DataCell(Text('Peak Usage Time')), DataCell(Text('${usageData[2]}'))]),
        DataRow(cells: [DataCell(Text('Washroom')), DataCell(Text('${usageData[8]}'))]),
        DataRow(cells: [DataCell(Text('Kitchen')), DataCell(Text('${usageData[9]}'))]),
        DataRow(cells: [DataCell(Text('Garden')), DataCell(Text('${usageData[10]}'))]),
        DataRow(cells: [DataCell(Text('Bathroom')), DataCell(Text('${usageData[11]}'))]),
      ],
    );
  }
}
