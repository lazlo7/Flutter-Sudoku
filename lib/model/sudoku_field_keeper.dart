import 'package:flutter_sudoku/model/sudoku_field.dart';

class SudokuFieldKeeper {
  final List<SudokuField> _fields = [];

  List<SudokuField> get fields => _fields;

  void addField(SudokuField field) {
    _fields.add(field);
  }

  SudokuField getField(int index) {
    return _fields[index];
  }

  void removeField(int index) {
    _fields.removeAt(index);
  }
}
