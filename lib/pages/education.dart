import 'package:flutter/material.dart';

class Edu extends StatelessWidget {
  const Edu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text(
          "Water Conservation",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              buildHeader(context, "How to Save Water"),
              SizedBox(height: 20),
              buildTip("Measure Your Water Footprint",
                  "Understand how much water you use in daily activities and find ways to reduce it."),
              buildTip("Fix Leaks Immediately",
                  "A small drip from a leaky faucet can waste up to 20 gallons of water a day."),
              buildTip("Upgrade to Efficient Appliances",
                  "Consider energy-efficient dishwashers and washing machines to save water."),
              buildTip("Shower Smarter",
                  "Limit showers to 5 minutes to save water. A shorter shower can save up to 1000 gallons a month."),
              buildTip("Use Rainwater for Gardening",
                  "Collect rainwater in barrels and use it for watering your garden."),
              buildTip("Water Plants Wisely",
                  "Water your garden during the coolest part of the day to prevent water loss through evaporation."),
              buildTip("Skip the Hose, Use a Broom",
                  "Clean driveways and sidewalks with a broom instead of a hose to avoid water wastage."),
              // Add more tips as needed
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context, String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade800,
        ),
      ),
    );
  }

  Widget buildTip(String title, String description) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey[200],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
