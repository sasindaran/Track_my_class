import 'package:flutter/material.dart';
import 'package:myclass/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'qr_scanner_page.dart';
import 'attendance_list_page.dart';

class AttendanceTrackerPage extends StatefulWidget {
  const AttendanceTrackerPage({Key? key}) : super(key: key);

  @override
  _AttendanceTrackerPageState createState() => _AttendanceTrackerPageState();
}

class _AttendanceTrackerPageState extends State<AttendanceTrackerPage> {
  List<ClassInfo> classes = [];
  late String selectedClassName;

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
        'scannedData': classInfo.scannedData,
      };
    }).toList();
    await prefs.setStringList(
        classDataKey, classData.map((data) => jsonEncode(data)).toList());
  }

  // Load class data from SharedPreferences
  void _loadClassData() async {
    final prefs = await SharedPreferences.getInstance();
    final classData = prefs.getStringList(classDataKey);
    if (classData != null) {
      setState(() {
        classes = classData.map((data) {
          final decodedData = jsonDecode(data);
          return ClassInfo(
            decodedData['className'],
            decodedData['scannedData'] ?? '',
          );
        }).toList();
      });
    }
  }

  void _showAddClassDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddClassForm(
          onSubmit: (className) {
            setState(() {
              classes.add(ClassInfo(className, ''));
              _saveClassData();
            });
          },
        );
      },
    );
  }

  void _deleteClass(int index) async {
    final classNameToDelete = classes[index].className;

    // Delete the class from the database
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteClass(classNameToDelete);

    setState(() {
      classes.removeAt(index);
      _saveClassData();
    });
  }

  // void _deleteClass(int index) {
  //   setState(() {
  //     classes.removeAt(index);
  //     _saveClassData();
  //   });
  // }

  void _openQRScanner(BuildContext context, int index) async {
    final scannedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            QRScannerPage(className: classes[index].className),
      ),
    );

    if (scannedData != null) {
      _updateScannedData(index, scannedData);
    }
  }

  void _updateScannedData(int index, String scannedData) {
    setState(() {
      classes[index].scannedData = scannedData;
      _saveClassData();
    });
  }

  void _showViewAttendancePage(BuildContext context, String className) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (selectedDate != null) {
      // Redirect to the AttendanceListPage with the selected date and class name
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AttendanceListPage(
            selectedDate: selectedDate,
            className: className,
          ),
        ),
      );
    }
  }

  // void _showViewAttendancePage(BuildContext context, String className) {
  //   // Redirect to the AttendanceListPage with the selected class name
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => AttendanceListPage(
  //         selectedDate: DateTime.now(), // Modify the date as needed
  //         className: className,
  //       ),
  //     ),
  //   );
  // }

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
                  onEdit: (newClassName) {
                    _editClass(index, newClassName);
                  },
                  onScanQR: () {
                    _openQRScanner(context, index);
                  },
                  onView: () {
                    _showViewAttendancePage(context, classes[index].className);
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
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void restartApp(BuildContext context) {
    runApp(
      MaterialApp(
        home: AttendanceTrackerPage(),
      ),
    );
  }

  void _editClass(int index, String className) {
    print('Editing class: $className');

    setState(() {
      classes[index].className = className;
      _saveClassData();
    });
    restartApp(context);
  }
}

class ClassInfo {
  String className;
  String scannedData;

  ClassInfo(this.className, this.scannedData);
}

class ClassBox extends StatelessWidget {
  final ClassInfo classInfo;
  final VoidCallback onDelete;
  final Function(String) onEdit;
  final VoidCallback onScanQR;
  final VoidCallback onView; // Added callback for "View" action

  ClassBox({
    required this.classInfo,
    required this.onDelete,
    required this.onEdit,
    required this.onScanQR,
    required this.onView,
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
                    onView(); // Call the "View" callback
                  } else if (value == 'export') {
                    // Implement the export action
                  } else if (value == 'delete') {
                    onDelete();
                  } else if (value == 'scanQR') {
                    onScanQR();
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
                    child: Text('Scan QR Code'),
                  ),
                ],
              ),
            ],
          ),
          // Text(
          //   'Scanned Data: ${classInfo.scannedData}',
          //   style: TextStyle(fontWeight: FontWeight.bold),
          // ),
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
          onSubmit: (newClassName) {
            onEdit(newClassName);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

class EditClassDialog extends StatefulWidget {
  final String initialClassName;
  final Function(String) onSubmit;

  EditClassDialog({
    required this.initialClassName,
    required this.onSubmit,
  });

  @override
  _EditClassDialogState createState() => _EditClassDialogState();
}

class _EditClassDialogState extends State<EditClassDialog> {
  TextEditingController classNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    classNameController.text = widget.initialClassName;
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
            widget.onSubmit(className);
            Navigator.of(context).pop();
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}

class AddClassForm extends StatefulWidget {
  final Function(String) onSubmit;

  AddClassForm({required this.onSubmit});

  @override
  _AddClassFormState createState() => _AddClassFormState();
}

class _AddClassFormState extends State<AddClassForm> {
  TextEditingController classNameController = TextEditingController();

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
            widget.onSubmit(className);
            Navigator.of(context).pop();
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
