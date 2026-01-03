import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';  // This should work after adding the dependency

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _servicesController = TextEditingController(); // New field for services
  File? _uploadedFile;
  int _rating = 0;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _customerName; // To store fetched customer name

  @override
  void initState() {
    super.initState();
    _fetchCustomerName();
  }

  Future<void> _fetchCustomerName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _customerName = 'Unknown';
        });
        return;
      }
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _customerName = userDoc['name'] ?? 'Unknown'; // Fetch name from Firestore
        });
      }
    } catch (e) {
      print('Error fetching customer name: $e');
      setState(() {
        _customerName = 'Unknown';
      });
    }
  }

  Future<void> _pickFile() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _uploadedFile = File(file.path);
      });
    }
  }

  Future<String?> _uploadFile(File file) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final fileExtension = file.path.split('.').last; // Get actual file extension (e.g., jpg, png)
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final ref = FirebaseStorage.instance
          .ref()
          .child('feedback_images')
          .child(fileName);
      final uploadTask = ref.putFile(file);

      // Optional: Listen for progress (you can add a progress bar here if desired)
      uploadTask.snapshotEvents.listen((event) {
        // Example: Calculate progress percentage
        // double progress = (event.bytesTransferred / event.totalBytes) * 100;
        // print('Upload progress: $progress%');
      });

      await uploadTask;
      return await ref.getDownloadURL();
    } catch (e) {
      print('Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image: $e")),
      );
      return null;
    }
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please give a star rating.")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You must be logged in to submit feedback.")),
      );
      return;
    }

    if (_customerName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unable to fetch user data. Please try again.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? fileUrl;
      if (_uploadedFile != null) {
        fileUrl = await _uploadFile(_uploadedFile!);
        // If upload fails, fileUrl will be null, but we still submit the feedback
      }

      await FirebaseFirestore.instance.collection('feedback').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'rating': _rating,
        'fileUrl': fileUrl,
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
        'customerName': _customerName, // Fetched from Firestore
        'services': _servicesController.text.trim(), // From user input
      });

      // Clear fields after successful submission
      _titleController.clear();
      _descriptionController.clear();
      _servicesController.clear();
      setState(() {
        _uploadedFile = null;
        _rating = 0;
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text("Feedback Submitted", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text("Thank you for your feedback!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting feedback: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return IconButton(
          icon: Icon(
            Icons.star,
            size: 35,
            color: _rating >= starIndex ? Colors.yellow : Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _rating = starIndex;
            });
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F7E2),
      appBar: AppBar(
        title: Text("Feedback & Report"),
        centerTitle: true,
        backgroundColor: Color(0xFFF2F7E2),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Rate Your Experience", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildStarRating(),
            SizedBox(height: 25),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Title",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _servicesController, // New services field
              decoration: InputDecoration(
                labelText: "Services Received",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Description",
                alignLabelWithHint: true,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF6A688E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _uploadedFile == null ? "Upload File (optional)" : "File Uploaded",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_uploadedFile != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_uploadedFile!, height: 200, width: double.infinity, fit: BoxFit.cover),
              ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6A688E),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Submit Feedback", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
