import 'package:flutter/material.dart';

class AddClassForm extends StatefulWidget {
  final Function(String className, String spreadsheetLink) onSubmit;

  AddClassForm({required this.onSubmit});

  @override
  _AddClassFormState createState() => _AddClassFormState();
}

class _AddClassFormState extends State<AddClassForm> {
  TextEditingController classNameController = TextEditingController();
  TextEditingController spreadsheetLinkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Class'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: classNameController,
            decoration: InputDecoration(labelText: 'Class Name'),
          ),
          TextField(
            controller: spreadsheetLinkController,
            decoration: InputDecoration(labelText: 'Spreadsheet Link'),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final className = classNameController.text;
            final spreadsheetLink = spreadsheetLinkController.text;
            widget.onSubmit(className, spreadsheetLink);
            Navigator.of(context).pop();
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
