import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'qr_scanner_page.dart'; // Import the QRScannerPage file

class AttendanceTrackerPage extends StatefulWidget {
  @override
  _AttendanceTrackerPageState createState() => _AttendanceTrackerPageState();
}

class _AttendanceTrackerPageState extends State<AttendanceTrackerPage> {
  List<ClassInfo> classes = [];

  // Define a key for storing class data in SharedPreferences
  static const String classDataKey = 'classData';

  // Load class data from SharedPreferences when the widget is initialized
  @override
  void initState() {
    super.initState();
    _loadClassData();
  }

  // Save class data to SharedPreferences whenever it changes
  void _saveClassData() async {
    final prefs = await SharedPreferences.getInstance();
    final classData = classes.map((classInfo) {
      return {
        'className': classInfo.className,
        'spreadsheetLink': classInfo.spreadsheetLink,
      };
    }).toList();
    await prefs.setStringList(classDataKey, classData.map((data) => jsonEncode(data)).toList());
  }

  // Load class data from SharedPreferences
  void _loadClassData() async {
    final prefs = await SharedPreferences.getInstance();
    final classData = prefs.getStringList(classDataKey);
    if (classData != null) {
      setState(() {
        classes = classData.map((data) {
          final decodedData = jsonDecode(data);
          return ClassInfo(decodedData['className'], decodedData['spreadsheetLink']);
        }).toList();
      });
    }
  }

  void _showAddClassDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddClassForm(
          onSubmit: (className, spreadsheetLink) {
            setState(() {
              classes.add(ClassInfo(className, spreadsheetLink));
              _saveClassData(); // Save the updated data
            });
          },
        );
      },
    );
  }

  void _deleteClass(int index) {
    setState(() {
      classes.removeAt(index);
      _saveClassData(); // Save the updated data after deletion
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Tracker'),
        backgroundColor: Color.fromARGB(255, 150, 235, 153),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: classes.length,
              itemBuilder: (context, index) {
                return ClassBox(
                  classInfo: classes[index],
                  onDelete: () {
                    _deleteClass(index);
                  },
                  onEdit: (newClassName, newSpreadsheetLink) {
                    _editClass(index, newClassName, newSpreadsheetLink);
                  },
                  onScanQR: () {
                    _openQRScanner(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddClassDialog(context);
        },
        tooltip: 'Add',
        child: Icon(
          Icons.add,
          color: Color.fromARGB(255, 150, 235, 153),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  // Create a method to handle the edit action
  void _editClass(int index, String className, String spreadsheetLink) {
    setState(() {
      // Update the class information in the list
      classes[index].className = className;
      classes[index].spreadsheetLink = spreadsheetLink;

      // Save the updated data
      _saveClassData();
    });
  }

  // Function to open QR scanner
  void _openQRScanner(BuildContext context) async {
    final scannedData = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRScannerPage()),
    );

    if (scannedData != null) {
      // Handle the scanned data, e.g., display it or process it as needed
      print('Scanned QR Code: $scannedData');
    }
  }
}

class ClassInfo {
  String className;
  String spreadsheetLink;

  ClassInfo(this.className, this.spreadsheetLink);
}

class ClassBox extends StatelessWidget {
  final ClassInfo classInfo;
  final VoidCallback onDelete;
  final Function(String, String) onEdit;
  final VoidCallback onScanQR;

  ClassBox({
    required this.classInfo,
    required this.onDelete,
    required this.onEdit,
    required this.onScanQR,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(255, 150, 235, 153)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Class Name: ${classInfo.className}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditClassDialog(context);
                  } else if (value == 'view') {
                    // Implement the view action
                  } else if (value == 'export') {
                    // Implement the export action
                  } else if (value == 'delete') {
                    onDelete(); // Call the delete callback
                  } else if (value == 'scanQR') {
                    onScanQR(); // Call the scan QR callback
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'view',
                    child: Text('View'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'export',
                    child: Text('Export'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'scanQR',
                    child: Text('Scan QR Code'), // Add a custom menu item for QR scanner
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditClassDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditClassDialog(
          initialClassName: classInfo.className,
          initialSpreadsheetLink: classInfo.spreadsheetLink,
          onSubmit: (newClassName, newSpreadsheetLink) {
            onEdit(newClassName, newSpreadsheetLink);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

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
