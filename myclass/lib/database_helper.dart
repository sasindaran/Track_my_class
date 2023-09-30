import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database; // Make _database nullable

  DatabaseHelper._internal();

  Future<void> deleteClass(String className) async {
    final db = await database;
    await db.delete(
      'scanned_data',
      where: 'className = ?',
      whereArgs: [className],
    );
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<List<ScannedData>> getAttendanceForExport(
      String className, DateTime? selectedDate) async {
    final db = await database;
    String whereClause = 'className = ?';
    List<String> whereArgs = [className];

    if (selectedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      whereClause += ' AND currentDate LIKE ?';
      whereArgs.add('$formattedDate%');
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'scanned_data',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return List.generate(maps.length, (i) {
      return ScannedData(
        className: maps[i]['className'],
        registerNumber: maps[i]['registerNumber'],
        currentDate: DateTime.parse(maps[i]['currentDate']),
      );
    });
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'attendance.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE scanned_data(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            className TEXT,
            registerNumber TEXT,
            name TEXT,
            currentDate TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertScannedData(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('scanned_data', row);
  }

  Future<List<ScannedData>> getAttendanceForDate(
      DateTime date, String className) async {
    final db = await database;
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final List<Map<String, dynamic>> maps = await db.query(
      'scanned_data',
      where: 'className = ? AND currentDate LIKE ?',
      whereArgs: [className, '$formattedDate%'],
    );

    return List.generate(maps.length, (i) {
      return ScannedData(
        className: maps[i]['className'],
        registerNumber: maps[i]['registerNumber'],
        currentDate: DateTime.parse(maps[i]['currentDate']),
      );
    });
  }
}

class ScannedData {
  final String className;
  final String registerNumber;
  // final String name;
  final DateTime currentDate;

  ScannedData({
    required this.className,
    required this.registerNumber,
    // required this.name,
    required this.currentDate,
  });
}

// Future<List<ScannedData>> getAttendanceForDate(
//     DateTime date, String className) async {
//   final db = await database;
//   final formattedDate = DateFormat('yyyy-MM-dd').format(date);
//
//   final List<Map<String, dynamic>> maps = await db.query(
//     'scanned_data',
//     where: 'className = ? AND currentDate LIKE ?',
//     whereArgs: [className, '$formattedDate%'],
//   );
//
//   return List.generate(maps.length, (i) {
//     final name =
//         maps[i]['name'] ?? ''; // Provide a default value if 'name' is null
//     return ScannedData(
//       className: maps[i]['className'],
//       registerNumber: maps[i]['registerNumber'],
//       name: name,
//       currentDate: DateTime.parse(maps[i]['currentDate']),
//     );
//   });
// }

// Future<List<ScannedData>> getAttendanceForDate(
//     DateTime date, String className) async {
//   final db = await database;
//   final formattedDate = DateFormat('yyyy-MM-dd').format(date);
//
//   final List<Map<String, dynamic>> maps = await db.query(
//     'scanned_data',
//     where: 'className = ? AND currentDate LIKE ?',
//     whereArgs: [className, '$formattedDate%'],
//   );
//
//   return List.generate(maps.length, (i) {
//     return ScannedData(
//       className: maps[i]['className'],
//       registerNumber: maps[i]['registerNumber'],
//       name: maps[i]['name'], // Include the 'name' field
//       currentDate: DateTime.parse(maps[i]['currentDate']),
//     );
//   });
// }

// import 'dart:async';
// import 'package:intl/intl.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
//
// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;
//
//   static late Database _database;
//
//   DatabaseHelper._internal();
//
//   Future<Database> get database async {
//     if (_database != null) {
//       return _database;
//     }
//     _database = await _initDatabase();
//     return _database;
//   }
//
//   Future<Database> _initDatabase() async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, 'attendance.db');
//
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (Database db, int version) async {
//         await db.execute('''
//           CREATE TABLE scanned_data(
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             className TEXT,
//             registerNumber TEXT,
//             name TEXT,
//             currentDate TEXT
//           )
//         ''');
//       },
//     );
//   }
//
//   Future<int> insertScannedData(Map<String, dynamic> row) async {
//     final db = await database;
//     return await db.insert('scanned_data', row);
//   }
//
//   Future<List<ScannedData>> getAttendanceForDate(
//       DateTime date, String className) async {
//     final db = await database;
//     final formattedDate = DateFormat('yyyy-MM-dd').format(date);
//
//     final List<Map<String, dynamic>> maps = await db.query(
//       'scanned_data',
//       where: 'className = ? AND currentDate LIKE ?',
//       whereArgs: [className, '$formattedDate%'],
//     );
//     Future<List<Map<String, dynamic>>> queryAllRows() async {
//       final db = await database;
//       return await db.query('scanned_data');
//     }
//
//     return List.generate(maps.length, (i) {
//       return ScannedData(
//         className: maps[i]['className'],
//         registerNumber: maps[i]['registerNumber'],
//         name: maps[i]['name'], // Include the 'name' field
//         currentDate: DateTime.parse(maps[i]['currentDate']),
//       );
//     });
//   }
// }
//
// class ScannedData {
//   final String className;
//   final String registerNumber;
//   final String name;
//   final DateTime currentDate;
//
//   ScannedData({
//     required this.className,
//     required this.registerNumber,
//     required this.name,
//     required this.currentDate,
//   });
// }
//
// // import 'dart:async';
// // import 'package:intl/intl.dart';
// // import 'package:myclass/qr_scanner_page.dart';
// // import 'package:path/path.dart';
// // import 'package:sqflite/sqflite.dart';
// //
// // class ScannedData {
// //   final String className;
// //   final String registerNumber;
// //   final String name; // Add the 'name' field here
// //   final DateTime currentDate;
// //
// //   ScannedData({
// //     required this.className,
// //     required this.registerNumber,
// //     required this.name,
// //     required this.currentDate,
// //   });
// // }
// //
// // class DatabaseHelper {
// //   static final DatabaseHelper _instance = DatabaseHelper._internal();
// //   factory DatabaseHelper() => _instance;
// //
// //   static late Database _database;
// //
// //   DatabaseHelper._internal();
// //
// //   Future<Database> get database async {
// //     if (_database != null) {
// //       return _database;
// //     }
// //     _database = await _initDatabase();
// //     return _database;
// //   }
// //
// //   Future<Database> _initDatabase() async {
// //     final dbPath = await getDatabasesPath();
// //     final path = join(dbPath, 'attendance.db');
// //
// //     return await openDatabase(
// //       path,
// //       version: 1,
// //       onCreate: (Database db, int version) async {
// //         await db.execute('''
// //           CREATE TABLE scanned_data(
// //             id INTEGER PRIMARY KEY AUTOINCREMENT,
// //             className TEXT,
// //             registerNumber TEXT,
// //             name TEXT,
// //             currentDate TEXT
// //           )
// //         ''');
// //       },
// //     );
// //   }
// //
// //   Future<int> insertScannedData(Map<String, dynamic> row) async {
// //     final db = await database;
// //     return await db.insert('scanned_data', row);
// //   }
// //
// //   Future<List<ScannedData>?> getAttendanceForDate(
// //       DateTime selectedDate, String className) async {
// //     final db = await database;
// //     final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
// //
// //     final List<Map<String, dynamic>> maps = await db.query(
// //       'scanned_data',
// //       where: 'className = ? AND currentDate LIKE ?',
// //       whereArgs: [className, '$formattedDate%'], // Filter by date
// //     );
// //
// //     if (maps.isNotEmpty) {
// //       return List.generate(maps.length, (i) {
// //         return ScannedData(
// //           className: maps[i]['className'],
// //           registerNumber: maps[i]['registerNumber'],
// //           name: maps[i]['name'],
// //           currentDate: DateTime.parse(maps[i]['currentDate']),
// //         );
// //       });
// //     } else {
// //       return null; // Return null if no data is found
// //     }
// //   }
// // }
// //
// // // import 'dart:async';
// // // import 'package:myclass/qr_scanner_page.dart';
// // // import 'package:path/path.dart';
// // // import 'package:sqflite/sqflite.dart';
// // // import 'package:intl/intl.dart'; // Add this import for DateFormat
// // //
// // // class DatabaseHelper {
// // //   static final DatabaseHelper _instance = DatabaseHelper._internal();
// // //   factory DatabaseHelper() => _instance;
// // //
// // //   static late Database _database;
// // //
// // //   DatabaseHelper._internal();
// // //
// // //   Future<Database> get database async {
// // //     if (_database != null) {
// // //       return _database;
// // //     }
// // //     _database = await _initDatabase();
// // //     return _database;
// // //   }
// // //
// // //   Future<Database> _initDatabase() async {
// // //     final dbPath = await getDatabasesPath();
// // //     final path = join(dbPath, 'attendance.db');
// // //
// // //     return await openDatabase(
// // //       path,
// // //       version: 1,
// // //       onCreate: (Database db, int version) async {
// // //         await db.execute('''
// // //           CREATE TABLE scanned_data(
// // //             id INTEGER PRIMARY KEY AUTOINCREMENT,
// // //             className TEXT,
// // //             registerNumber TEXT,
// // //             currentDate TEXT
// // //           )
// // //         ''');
// // //       },
// // //     );
// // //   }
// // //
// // //   Future<int> insertScannedData(
// // //       String className, String registerNumber, DateTime currentDate) async {
// // //     final db = await database;
// // //     final row = {
// // //       'className': className,
// // //       'registerNumber': registerNumber,
// // //       'currentDate': DateFormat('yyyy-MM-dd HH:mm:ss').format(currentDate),
// // //     };
// // //     return await db.insert('scanned_data', row);
// // //   }
// // //
// // //   Future<List<ScannedData>> getAttendanceForDate(
// // //       DateTime selectedDate, String className) async {
// // //     final db = await database;
// // //     final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
// // //
// // //     final List<Map<String, dynamic>> maps = await db.query(
// // //       'scanned_data',
// // //       where: 'className = ? AND currentDate LIKE ?',
// // //       whereArgs: [className, '$formattedDate%'],
// // //       orderBy: 'currentDate ASC',
// // //     );
// // //
// // //     return List.generate(maps.length, (i) {
// // //       return ScannedData(
// // //         className: maps[i]['className'],
// // //         registerNumber: maps[i]['registerNumber'],
// // //         name: maps[i]['name'],
// // //         currentDate: DateTime.parse(maps[i]['currentDate']),
// // //       );
// // //     });
// // //   }
// // // }
// // //
// // // // import 'dart:async';
// // // // import 'package:path/path.dart';
// // // // import 'package:sqflite/sqflite.dart';
// // // //
// // // // class DatabaseHelper {
// // // //   static final DatabaseHelper _instance = DatabaseHelper._internal();
// // // //   factory DatabaseHelper() => _instance;
// // // //
// // // //   static late Database _database;
// // // //
// // // //   DatabaseHelper._internal();
// // // //
// // // //   Future<Database> get database async {
// // // //     if (_database != null) {
// // // //       return _database;
// // // //     }
// // // //     _database = await _initDatabase();
// // // //     return _database;
// // // //   }
// // // //
// // // //   Future<Database> _initDatabase() async {
// // // //     final dbPath = await getDatabasesPath();
// // // //     final path = join(dbPath, 'attendance.db');
// // // //
// // // //     return await openDatabase(
// // // //       path,
// // // //       version: 1,
// // // //       onCreate: (Database db, int version) async {
// // // //         await db.execute('''
// // // //           CREATE TABLE scanned_data(
// // // //             id INTEGER PRIMARY KEY AUTOINCREMENT,
// // // //             className TEXT,
// // // //             registerNumber TEXT,
// // // //             currentDate TEXT
// // // //           )
// // // //         ''');
// // // //       },
// // // //     );
// // // //   }
// // // //
// // // //   Future<int> insertScannedData(
// // // //       String className, String registerNumber, DateTime currentDate) async {
// // // //     final db = await database;
// // // //     final row = {
// // // //       'className': className,
// // // //       'registerNumber': registerNumber,
// // // //       'currentDate': DateFormat('yyyy-MM-dd HH:mm:ss').format(currentDate),
// // // //     };
// // // //     return await db.insert('scanned_data', row);
// // // //   }
// // // // }
// // // //
// // // // // import 'dart:async';
// // // // // import 'package:path/path.dart';
// // // // // import 'package:sqflite/sqflite.dart';
// // // // //
// // // // // class DatabaseHelper {
// // // // //   static final DatabaseHelper _instance = DatabaseHelper._internal();
// // // // //   factory DatabaseHelper() => _instance;
// // // // //
// // // // //   static late Database _database;
// // // // //
// // // // //   DatabaseHelper._internal();
// // // // //
// // // // //   Future<Database> get database async {
// // // // //     if (_database != null) {
// // // // //       return _database;
// // // // //     }
// // // // //     _database = await _initDatabase();
// // // // //     return _database;
// // // // //   }
// // // // //
// // // // //   Future<Database> _initDatabase() async {
// // // // //     final dbPath = await getDatabasesPath();
// // // // //     final path = join(dbPath, 'attendance.db');
// // // // //
// // // // //     return await openDatabase(
// // // // //       path,
// // // // //       version: 1,
// // // // //       onCreate: (Database db, int version) async {
// // // // //         await db.execute('''
// // // // //           CREATE TABLE scanned_data(
// // // // //             id INTEGER PRIMARY KEY AUTOINCREMENT,
// // // // //             className TEXT,
// // // // //             registerNumber TEXT,
// // // // //             name TEXT,
// // // // //             currentDate TEXT
// // // // //           )
// // // // //         ''');
// // // // //       },
// // // // //     );
// // // // //   }
// // // // //
// // // // //   Future<int> insertScannedData(Map<String, dynamic> row) async {
// // // // //     final db = await database;
// // // // //     return await db.insert('scanned_data', row);
// // // // //   }
// // // // // }
