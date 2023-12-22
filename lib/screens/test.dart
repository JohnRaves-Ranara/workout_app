import 'package:flutter/material.dart';

class test extends StatefulWidget {
  const test({super.key});

  @override
  State<test> createState() => _testState();
}

class _testState extends State<test> {
  void showValidationDialog() {
  final _formKey = GlobalKey<FormState>(); // Define formKey for validation

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Enter Details'),
        content: Form(
          key: _formKey, // Use the formKey
          child: Column(
            mainAxisSize: MainAxisSize.min, // Adjust for smaller height
            children: [
              // TextFormFields with validation
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a value';
                  }
                  else if(value=='a'){
                    return "CANNOT BE";
                  }
                  return null; // Valid input
                },
                // autovalidateMode: AutovalidateMode.onUserInteraction, // Immediate feedback
                decoration: InputDecoration(
                  labelText: 'Field 1',
                ),
              ),
              // Add more TextFormFields as needed
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // All fields valid, proceed with submission
                Navigator.pop(context); // Close dialog
                // Handle valid data here
              }
            },
            child: Text('Submit'),
          ),
        ],
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Validation Demo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: showValidationDialog,
          child: Text('Show Validation Dialog'),
        ),
      ),
    );
  }
}