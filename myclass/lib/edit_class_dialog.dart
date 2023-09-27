import 'package:flutter/material.dart';

class EditClassDialog extends StatefulWidget {
  final String initialClassName;
  final String initialSpreadsheetLink;
  final Function(String className, String spreadsheetLink) onSubmit;

  EditClassDialog({
    required this.initialClassName,
    required this.initialSpreadsheetLink,
    required this.onSubmit,
  });

  @override
  _EditClassDialogState createState() => _EditClassDialogState();
}

class _EditClassDialogState extends State<EditClassDialog> {
  TextEditingController classNameController = TextEditingController();
  TextEditingController spreadsheetLinkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    classNameController.text = widget.initialClassName;
    spreadsheetLinkController.text = widget.initialSpreadsheetLink;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Class'),
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
