import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AddNote(),
  ));
}

class AddNote extends StatefulWidget {
  @override
  _AddNoteState createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _selectedComplaint;
  String? _imageUrl;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final ImagePicker _picker = ImagePicker();
  bool _loading = false; // Track loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complaint", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20),
                  buildDropdown(),
                  SizedBox(height: 30),
                  buildDateField(),
                  SizedBox(height: 30),
                  buildTextField(_complaintController, 'Complaint Details', Icons.edit),
                  SizedBox(height: 30),
                  buildLocationField(),
                  SizedBox(height: 20),
                  buildCameraButton(),
                  SizedBox(height: 20),
                  _imageUrl != null ? buildImageDisplay() : SizedBox.shrink(),
                  SizedBox(height: 20),
                  buildSubmitButton(),
                  SizedBox(height: 20), // Add some space at the bottom
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDropdown() {
    return DropdownButtonFormField<String>(
      decoration: inputDecoration('Select Complaint Type', Icons.arrow_drop_down),
      value: _selectedComplaint,
      items: ['Water Leak', 'Pilferage', 'Water Quality', 'Other']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedComplaint = newValue;
        });
      },
    );
  }

  InputDecoration inputDecoration(String hintText, IconData icon) {
    return InputDecoration(
      hintText: hintText,
      icon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget buildDateField() {
    return TextField(
      controller: _dateController,
      readOnly: true,
      decoration: inputDecoration('Incident Date', Icons.calendar_today),
      onTap: () => _selectDate(),
    );
  }

  Widget buildTextField(TextEditingController controller, String hintText, IconData icon) {
    return TextField(
      controller: controller,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      decoration: inputDecoration(hintText, icon),
    );
  }

  Widget buildLocationField() {
    return GestureDetector(
      onTap: _getCurrentLocation,
      child: buildTextField(_locationController, 'Location Details', Icons.location_on),
    );
  }

  Widget buildCameraButton() {
    return ElevatedButton.icon(
      onPressed: _loading ? null : _captureImage, // Disable button when loading
      icon: Icon(Icons.camera_alt, color: Colors.white),
      label: Text("Capture Image", style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(primary: Colors.blueAccent),
    );
  }

  Widget buildImageDisplay() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Image.network(
            _imageUrl!,
            fit: BoxFit.cover,
            height: 200, // Set a fixed height for the image
            width: double.infinity,
          ),
        ),
        Text("Captured Image", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget buildSubmitButton() {
    return ElevatedButton(
      onPressed: _loading ? null : _submitComplaint, // Disable button when loading
      child: _loading
          ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
          : Text("Submit", style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        primary: Colors.blueAccent,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _locationController.text = "${position.latitude}, ${position.longitude}";
      });
    } catch (e) {
      print(e); // Handle the exception
    }
  }

  Future<void> _captureImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.camera);
    if (file == null) return;

    // Upload the image to Firebase Storage and get the URL
    String fileName = 'complaints/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    FirebaseStorage storage = FirebaseStorage.instance;
    setState(() {
      _loading = true;
    });
    try {
      await storage.ref(fileName).putFile(File(file.path));
      String downloadUrl = await storage.ref(fileName).getDownloadURL();
      setState(() {
        _imageUrl = downloadUrl;
      });
    } catch (e) {
      print("Error uploading image: $e");
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _submitComplaint() async {
    DatabaseReference complaintsRef = _databaseRef.child('Complains');

    try {
      setState(() {
        _loading = true;
      });
      await complaintsRef.push().set({
        "date": _dateController.text,
        "description": _complaintController.text,
        "location": _locationController.text,
        "imageUrl": _imageUrl, // Save the image URL
        "type": _selectedComplaint,
      });

      _clearForm();
      _showDialog(true);
    } catch (e) {
      print(e); // Handle the exception
      _showDialog(false);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _clearForm() {
    _dateController.clear();
    _complaintController.clear();
    _locationController.clear();
    setState(() {
      _selectedComplaint = null;
      _imageUrl = null;
    });
  }

  void _showDialog(bool success) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(success ? 'Success' : 'Error'),
          content: Text(success ? 'Data saved successfully!' : 'Failed to save data.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
