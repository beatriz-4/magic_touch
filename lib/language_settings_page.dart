import 'package:flutter/material.dart';

class LanguageSettingsPage extends StatefulWidget {
  @override
  _LanguageSettingsPageState createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  String selectedLanguage = "English";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Language"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          RadioListTile<String>(
            title: Text("English"),
            value: "English",
            groupValue: selectedLanguage,
            onChanged: (value) {
              setState(() {
                selectedLanguage = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: Text("Malay"),
            value: "Malay",
            groupValue: selectedLanguage,
            onChanged: (value) {
              setState(() {
                selectedLanguage = value!;
              });
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Language set to $selectedLanguage")),
              );
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }
}
