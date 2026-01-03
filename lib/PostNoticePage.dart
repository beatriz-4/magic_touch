import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class PostNoticePage extends StatefulWidget {
  @override
  State<PostNoticePage> createState() => _PostNoticePageState();
}

class _PostNoticePageState extends State<PostNoticePage> {
  String _postType = "Announcement";
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  PlatformFile? _selectedFile;
  bool _isSubmitting = false;

  // ================= PICK DATE =================
  void _pickDate() async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFC280A2),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // ================= PICK FILE =================
  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  // ================= UPLOAD FILE TO FIREBASE STORAGE =================
  Future<String?> _uploadFile() async {
    if (_selectedFile == null || _selectedFile!.path == null) return null;

    try {
      final file = File(_selectedFile!.path!);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_selectedFile!.name}';
      final storageRef = FirebaseStorage.instance.ref().child('notices/$fileName');

      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  // ================= SUBMIT =================
  void _submitPost() async {
    if (_descriptionController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter description and choose a date"),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Upload file if exists
      String? fileUrl;
      if (_selectedFile != null) {
        fileUrl = await _uploadFile();
      }

      // Save to Firestore
      await FirebaseFirestore.instance.collection('notices').add({
        'type': _postType,
        'description': _descriptionController.text.trim(),
        'scheduleDate': Timestamp.fromDate(_selectedDate!),
        'fileUrl': fileUrl,
        'fileName': _selectedFile?.name,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true, // To control visibility
      });

      setState(() {
        _isSubmitting = false;
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Post Submitted"),
          content: const Text("Your post has been successfully submitted!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Reset form
                setState(() {
                  _descriptionController.clear();
                  _selectedDate = null;
                  _selectedFile = null;
                  _postType = "Announcement";
                });
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting post: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7E2),
      appBar: AppBar(
        title: const Text("Post Notice"),
        backgroundColor: const Color(0xFFF2F7E2),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= TYPE OF POST =================
                const Text(
                  "Type of Post",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text("Announcement"),
                      selected: _postType == "Announcement",
                      onSelected: (_) {
                        setState(() {
                          _postType = "Announcement";
                        });
                      },
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text("Promotion"),
                      selected: _postType == "Promotion",
                      onSelected: (_) {
                        setState(() {
                          _postType = "Promotion";
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ================= DESCRIPTION =================
                const Text(
                  "Description",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Enter description",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),

                const SizedBox(height: 16),

                // ================= POST SCHEDULE =================
                const Text(
                  "Post Schedule",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC280A2),
                  ),
                  onPressed: _pickDate,
                  child: Text(
                    _selectedDate == null
                        ? "Choose Date"
                        : DateFormat('dd MMM yyyy').format(_selectedDate!),
                  ),
                ),

                const SizedBox(height: 16),

                // ================= ATTACH FILE =================
                const Text(
                  "Attach File",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _selectedFile?.name ?? "No file attached",
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC280A2),
                      ),
                      onPressed: _pickFile,
                      child: const Text("Attach"),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ================= SUBMIT =================
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC280A2),
                      minimumSize: const Size(150, 50),
                    ),
                    onPressed: _isSubmitting ? null : _submitPost,
                    child: const Text(
                      "Submit",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading overlay
          if (_isSubmitting)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}


