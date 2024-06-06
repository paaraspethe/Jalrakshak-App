import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool isLoading = false;
  String? profileImageUrl;
  File? _image;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  User? get currentUser => auth.currentUser;

  Future<void> fetchUserData() async {
    if (currentUser == null) return;
    try {
      setState(() => isLoading = true);
      DocumentSnapshot userDoc = await firestore.collection('users').doc(currentUser!.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        nameController.text = data['name'] ?? '';
        mobileController.text = data['mobile'] ?? '';
        emailController.text = data['email'] ?? '';
        dobController.text = data['dob'] ?? '';
        addressController.text = data['address'] ?? '';
        profileImageUrl = data['profileImageUrl'] ?? '';
      }
    } catch (e) {
      showSnackBar('Error fetching user data: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateProfile() async {
    if (currentUser == null) return;
    try {
      setState(() => isLoading = true);

      String? imageUrl = profileImageUrl;
      if (_image != null) {
        imageUrl = await uploadImage(_image!);
      }

      await firestore.collection('users').doc(currentUser!.uid).set({
        'name': nameController.text,
        'mobile': mobileController.text,
        'email': emailController.text,
        'dob': dobController.text,
        'address': addressController.text,
        'profileImageUrl': imageUrl,
      }, SetOptions(merge: true)); // Use merge: true to update existing data or create if not exists


      showSnackBar('Profile updated successfully');
    } catch (e) {
      showSnackBar('Error updating profile: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<String> uploadImage(File image) async {
    String fileName = 'profile_${currentUser!.uid}.jpg';
    Reference ref = storage.ref().child('profile_images').child(fileName);
    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Your Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildProfileImage(),
              SizedBox(height: 20),
              buildInputField(nameController, 'Name', Icons.person),
              SizedBox(height: 10),
              buildInputField(mobileController, 'Mobile', Icons.phone),
              SizedBox(height: 10),
              buildInputField(emailController, 'Email', Icons.email),
              SizedBox(height: 10),
              buildInputField(dobController, 'Date of Birth', Icons.calendar_today, readOnly: true, onTap: () => pickDateOfBirth(context)),
              SizedBox(height: 10),
              buildInputField(addressController, 'Address', Icons.location_city),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateProfile,
                child: Text('Update Profile',style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfileImage() {
    return GestureDetector(
      onTap: () => pickImage(),
      child: CircleAvatar(
        radius: 50,
        backgroundImage: _image != null
            ? FileImage(_image!)
            : (profileImageUrl != null && profileImageUrl!.isNotEmpty
            ? NetworkImage(profileImageUrl!)
            : AssetImage('images/community.png') as ImageProvider),
        backgroundColor: Colors.grey.shade300,
      ),
    );
  }


  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Widget buildInputField(TextEditingController controller, String label, IconData icon, {bool readOnly = false, VoidCallback? onTap}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> pickDateOfBirth(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }
}
