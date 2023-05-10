import 'dart:convert';
import 'dart:io';

import 'package:flutter_sudoku/model/sudoku_field.dart';
import 'package:path_provider/path_provider.dart';

class SudokuFieldKeeper {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _sudokusPath async {
    final path = await _localPath;
    return File('$path/sudokus.json');
  }

  Map<String, SudokuField> fields = {};

  SudokuFieldKeeper() {
    // Initialize fields from file. 
    _sudokusPath.then((file) {
      file.exists().then((exists) {
        if (exists) {
          file.readAsString().then((json) {
            print("read sudokus json: $json");
            fields = SudokuFieldKeeper._fieldsFromJson(json);
          });
        }
      });
    });
  }

  String addField(SudokuField field) {
    final id = _getNextId();
    fields[_getNextId()] = field;
    saveFields();
    return id;
  }

  SudokuField? getField(String id) {
    return fields[id];
  }

  Future<void> removeField(String id) {
    fields.remove(id);
    return saveFields();
  }

  String _getNextId() {
    int id = 0;
    while (fields.containsKey(id.toString())) {
      id++;
    }
    return id.toString();
  }

  Future<void> saveFields() {
    print("saved fields");
    return _sudokusPath.then((file) {
      file.writeAsString(SudokuFieldKeeper._fieldsToJson(fields));
    }); 
  }

  /// Reads fields from json content.
  static Map<String, SudokuField> _fieldsFromJson(String json) {
    Map<String, dynamic> jsonMap = jsonDecode(json);
    Map<String, SudokuField> fields = {};
    jsonMap.forEach((key, value) {
      fields[key] = SudokuField.fromJson(value);
    });
    return fields;
  }

  /// Encodes fields a json string.
  static String _fieldsToJson(Map<String, SudokuField> fields) {
    Map<String, dynamic> jsonMap = {};
    fields.forEach((key, value) {
      jsonMap[key.toString()] = value.toJson();
    });
    return jsonEncode(jsonMap);
  }
} 
