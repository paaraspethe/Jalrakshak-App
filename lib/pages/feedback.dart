import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MyFeedback extends StatefulWidget {
  const MyFeedback({Key? key}) : super(key: key);

  @override
  _MyFeedbackState createState() => _MyFeedbackState();
}

class _MyFeedbackState extends State<MyFeedback> {
  TextEditingController feedbackController = TextEditingController();
  final fb = FirebaseDatabase.instance;
  double rating = 0;

  @override
  Widget build(BuildContext context) {
    final ref = fb.reference().child('feedback');

    return Scaffold(
      appBar: AppBar(
        title: Text("Feedback", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitle(),
            SizedBox(height: 30),
            _buildRatingBar(),
            SizedBox(height: 30),
            _buildFeedbackTextField(),
            SizedBox(height: 30),
            _buildSubmitButton(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'We value your feedback!',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRatingBar() {
    return RatingBar.builder(
      initialRating: rating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
      onRatingUpdate: (ratingValue) {
        setState(() {
          rating = ratingValue;
        });
      },
    );
  }

  Widget _buildFeedbackTextField() {
    return NeumorphicTextField(
      controller: feedbackController,
      hintText: 'Your feedback here...',
    );
  }

  Widget _buildSubmitButton(DatabaseReference ref) {
    return NeumorphicButton(
      onPressed: () => _handleSubmit(ref),
      child: Text('Submit Feedback', style: TextStyle(fontSize: 18)),
    );
  }

  void _handleSubmit(DatabaseReference ref) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final timestamp = DateTime.now().toUtc().toString();

        await ref.push().set({
          'feedback': feedbackController.text,
          'user_id': currentUser.uid,
          'timestamp': timestamp,
          'rating': rating,
        });

        _showDialog(true);
        feedbackController.clear();
        setState(() {
          rating = 0; // Resetting the rating to 0 after successful submission
        });
      } else {
        _showDialog(false);
      }
    } catch (e) {
      print('Error submitting feedback: $e');
      _showDialog(false);
    }
  }


  void _showDialog(bool success) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(success ? 'Thank You!' : 'Oops!'),
          content: Text(success ? 'Your feedback has been submitted.' : 'Failed to submit feedback. Please try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

// Custom Neumorphic TextField
class NeumorphicTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const NeumorphicTextField({
    Key? key,
    required this.controller,
    required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade500,
            offset: Offset(4, 4),
            blurRadius: 15,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

// Custom Neumorphic Button
class NeumorphicButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const NeumorphicButton({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade500,
              offset: Offset(4, 4),
              blurRadius: 15,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.white,
              offset: Offset(-4, -4),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
