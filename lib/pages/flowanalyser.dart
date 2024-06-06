import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
void checkFileExists() {
  final file = File('assets/Csv_files/network_data.csv');
  print('File exists: ${file.existsSync()}');
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlowAnalyser',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Arial',
      ),
      home: FlowAnalyser(),
    );
  }
}

class FlowAnalyser extends StatefulWidget {
  @override
  _FlowAnalyserState createState() => _FlowAnalyserState();
}

class _FlowAnalyserState extends State<FlowAnalyser> {
  List<List<dynamic>> _rows = [];
  String? _selectedNode;
  String? _selectedArea;
  String? _selectedAttribute;
  String _attributeValue = '';
  List<String> _areas = [];
  final List<String> _attributes = [
    'Pressure',
    'Actual Demand',
    'Total Head',
    'Elevation',
    'Flow',
    'Diameter',
    'Length',
    'Roughness',
    'Velocity'
  ];

  @override
  void initState() {
    super.initState();
    checkFileExists();
    loadCsvData();
  }

  Future<void> loadCsvData() async {
    final contents = await rootBundle.loadString('assets/Csv_files/network_data.csv');
    List<List<dynamic>> rows = const CsvToListConverter().convert(contents);
    setState(() {
      _rows = rows.sublist(1); // Skip the header row
      _areas = _rows.map((row) => row[10].toString()).toSet().toList(); // Assuming area is in column 11
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('FlowAnalyser'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildDropdown(
                      'Select an Area',
                      _selectedArea,
                      areaChanged,
                      _createDropdownMenuItemsFromAreas()
                  ),
                  const SizedBox(height: 20),
                  buildDropdown(
                      'Select a Node',
                      _selectedNode,
                      nodeChanged,
                      _createDropdownMenuItems(_rows)
                  ),
                  const SizedBox(height: 20),
                  buildDropdown(
                      'Select an Attribute',
                      _selectedAttribute,
                      attributeChanged,
                      _createDropdownMenuItemsFromAttributes()
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _fetchAttributeValue,
                    child: Text('Get Attribute Value', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (_attributeValue.isNotEmpty) attributeValueDisplayBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDropdown(
      String hintText,
      String? value,
      ValueChanged<String?> onChanged,
      List<DropdownMenuItem<String>> items
      ) {
    return DropdownButton<String>(
      hint: Text(hintText),
      value: value,
      onChanged: onChanged,
      items: items,
      style: TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
      icon: Icon(
        Icons.arrow_drop_down,
        color: Colors.blueAccent,
      ),
      elevation: 4,
      isExpanded: true,
      underline: Container(
        height: 2,
        color: Colors.blueAccent,
      ),
    );
  }

  void areaChanged(String? newValue) {
    setState(() {
      _selectedArea = newValue;
      _selectedNode = null;
      _selectedAttribute = null;
      _attributeValue = '';
    });
  }

  void nodeChanged(String? newValue) {
    setState(() {
      _selectedNode = newValue;
    });
  }

  void attributeChanged(String? newValue) {
    setState(() {
      _selectedAttribute = newValue;
    });
  }

  void _fetchAttributeValue() {
    if (_selectedNode != null && _selectedAttribute != null) {
      _updateDisplay();
    }
  }

  void _updateDisplay() {
    if (_selectedNode == null || _selectedAttribute == null) {
      _attributeValue = '';
      return;
    }

    for (var row in _rows) {
      if (row[0].toString() == _selectedNode) {
        int columnIndex = _attributes.indexOf(_selectedAttribute!) + 1;
        _attributeValue = row[columnIndex].toString();
        break;
      }
    }

    setState(() {});
  }

  Widget attributeValueDisplayBox() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent, width: 2),
      ),
      child: Text(
        '$_selectedAttribute at Node $_selectedNode: $_attributeValue',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  List<DropdownMenuItem<String>> _createDropdownMenuItems(List<List<dynamic>> rows) {
    var filteredRows = _selectedArea == null
        ? rows
        : rows.where((row) => row[10].toString() == _selectedArea).toList();

    return filteredRows.map<DropdownMenuItem<String>>((List<dynamic> value) {
      return DropdownMenuItem<String>(
        value: value[0].toString(),
        child: Text(value[0].toString()),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> _createDropdownMenuItemsFromAreas() {
    return _areas.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> _createDropdownMenuItemsFromAttributes() {
    return _attributes.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
  }
}
