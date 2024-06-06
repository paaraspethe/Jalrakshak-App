import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JalRakshak Rewards',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue[800]),
          subtitle1: TextStyle(fontSize: 24, color: Colors.blue[800]),
          bodyText1: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
      home: RewardsPage(),
    );
  }
}

class RewardsPage extends StatelessWidget {
  void showUnderDevelopmentDialog(BuildContext context) {
    showAnimatedDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ClassicGeneralDialogWidget(
          titleText: 'Under Development',
          contentText: 'This feature is coming soon!',
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
      animationType: DialogTransitionType.scale,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Rewards'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () => showUnderDevelopmentDialog(context),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20.0),
        child: ListView(
          children: <Widget>[
            Text('Hello,', style: Theme.of(context).textTheme.subtitle1),
            Text('User Name', style: Theme.of(context).textTheme.headline1),
            SizedBox(height: 20),
            RewardPointsChip(),
            SizedBox(height: 20),
            RewardBalanceCard(onRefresh: () => showUnderDevelopmentDialog(context)),
            SizedBox(height: 20),
            Center(child: RedeemPointsButton(onPressed: () => showUnderDevelopmentDialog(context))),
            SizedBox(height: 40),
            RewardOptionsGrid(onTap: () => showUnderDevelopmentDialog(context)),
          ],
        ),
      ),
    );
  }
}

class RewardPointsChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Colors.orange,
      label: Text('Your Reward Points:', style: TextStyle(color: Colors.white)),
    );
  }
}

class RewardBalanceCard extends StatelessWidget {
  final VoidCallback onRefresh;

  RewardBalanceCard({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Icon(Icons.account_balance_wallet, color: Colors.white, size: 40),
          Text('0', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: 30),
            onPressed: onRefresh,
          ),
        ],
      ),
    );
  }
}

class RedeemPointsButton extends StatelessWidget {
  final VoidCallback onPressed;

  RedeemPointsButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text('Redeem Points', style: TextStyle(fontSize: 18, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
    );
  }
}

class RewardOptionsGrid extends StatelessWidget {
  final VoidCallback onTap;

  RewardOptionsGrid({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: RewardOptionCard(icon: Icons.water_damage, color: Colors.blue, title: 'Water Meter Rewards', onTap: onTap)),
        SizedBox(width: 20),
        Expanded(child: RewardOptionCard(icon: Icons.report, color: Colors.red, title: 'Complaint Rewards', onTap: onTap)),
      ],
    );
  }
}

class RewardOptionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  RewardOptionCard({required this.icon, required this.color, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.blue[50],
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Icon(icon, size: 48, color: color),
              SizedBox(height: 10),
              Text(title, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
