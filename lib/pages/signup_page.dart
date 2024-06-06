import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:project4/pages/log_in.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _mobileNumber = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _dateOfBirth = TextEditingController();
  bool passToggle = true;

  Future<void> pickDateOfBirth(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        _dateOfBirth.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  createUserWithEmailAndPassword() async {
    try {
      setState(() {
        isLoading = true;
      });

      final String email = _email.text.trim();
      final String password = _password.text.trim();

      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // User registered successfully with Firebase Authentication.
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();


        // Store user data in Firestore.

        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'name': _name.text,
          'mobile': _mobileNumber.text,
          'email': _email.text,
          'dob': _dateOfBirth.text,
          'address': _address.text,
        }, SetOptions(merge: true)); // Use merge: true to update existing data or create if not exists


        setState(() {
          isLoading = false;
        });

        // After successful registration, navigate to the home page.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInPage()),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      // Handle registration errors
      print('Error during registration: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.12),
            Text(
              "SIGNUP",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.08,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Text(
              "Let's Get Started!",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: MediaQuery.of(context).size.width * 0.05,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _name,
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return "Full name is empty";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Enter Name",
                        labelText: "Full Name",
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    TextFormField(
                      controller: _email,
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return "Email is empty";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Enter Email",
                        labelText: "Email",
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    TextFormField(
                      controller: _mobileNumber,
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return "Mobile number is empty";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Enter Mobile Number",
                        labelText: "Mobile Number",
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    TextFormField(
                      controller: _address,
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return "Address is empty";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Enter Address",
                        labelText: "Address",
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    TextFormField(
                      controller: _dateOfBirth,
                      readOnly: true,
                      onTap: () => pickDateOfBirth(context),
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return "Date of birth is empty";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Select Date of Birth",
                        labelText: "Date of Birth",
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      controller: _password,
                      obscureText: passToggle,
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return "Password is empty";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Enter Password",
                        labelText: "Password",
                        suffix: InkWell(
                          onTap: () {
                            setState(() {
                              passToggle = !passToggle;
                            });
                          },
                          child: Icon(
                              passToggle
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await createUserWithEmailAndPassword();

                  // After successful registration, navigate to the home page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignInPage()),
                  );
                }
              },
              child: isLoading
                  ? CircularProgressIndicator(
                color: Colors.white,
              )
                  : const Text(
                "Register",
                style: TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(
                minimumSize: Size(140, 50),
                backgroundColor: Colors.black,
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account ?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInPage()),
                      );
                    },
                    child: Text(
                      "Log In",
                      style: TextStyle(
                        shadows: [
                          Shadow(color: Colors.black, offset: Offset(0, -5))
                        ],
                        color: Colors.transparent,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.black,
                        decorationThickness: 4,
                        decorationStyle: TextDecorationStyle.dotted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
