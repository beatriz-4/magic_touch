import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditServicePage extends StatefulWidget {
  final String serviceId;
  final String type;
  final String name;
  final double price;
  final String duration;

  const EditServicePage({
    required this.serviceId,
    required this.type,
    required this.name,
    required this.price,
    required this.duration,
    super.key,
  });

  @override
  State<EditServicePage> createState() => _EditServicePageState();
}

class _EditServicePageState extends State<EditServicePage> {
  String? _selectedType;
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.type;
    _nameController = TextEditingController(text: widget.name);
    _priceController = TextEditingController(text: widget.price.toString());
    _durationController = TextEditingController(text: widget.duration);
  }

  void _pickType() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("Select Type"),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, "Services"),
              child: const Text("Services"),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, "Package"),
              child: const Text("Package"),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, "Training"),
              child: const Text("Training"),
            ),
          ],
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedType = selected;
      });
    }
  }

  void _saveEdit() async {
    if (_selectedType == null ||
        _nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('services').doc(widget.serviceId).update({
        'type': _selectedType,
        'name': _nameController.text.trim(),
        'price': double.parse(_priceController.text),
        'duration': _durationController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Edit Saved"),
          content: const Text("Service details have been updated successfully."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to content management
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating service: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deleteService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you sure?"),
        content: const Text(
            "You are about to delete this content. All associated data, including its service history and customer visibility, will be permanently removed. This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close confirmation

              setState(() {
                _isLoading = true;
              });

              try {
                await _firestore
                    .collection('services')
                    .doc(widget.serviceId)
                    .delete();

                if (!mounted) return;

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Deleted Successfully"),
                    content: const Text("Service has been removed."),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Go back to content management
                        },
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error deleting service: $e")),
                );
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7E2),
      appBar: AppBar(
        title: const Text("Edit Service"),
        backgroundColor: const Color(0xFFF2F7E2),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickType,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFAE7D57),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedType ?? "Select Type",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _nameController,
                  enabled: _selectedType != null,
                  decoration: InputDecoration(
                    hintText: "Name",
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFFAE7D57),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  enabled: _selectedType != null,
                  decoration: InputDecoration(
                    hintText: "Price (RM)",
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFFAE7D57),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _durationController,
                  enabled: _selectedType != null,
                  decoration: InputDecoration(
                    hintText: "Duration (e.g., 30 mins)",
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFFAE7D57),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveEdit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A688E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Save Edit",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _deleteService,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
