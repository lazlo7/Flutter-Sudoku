import 'package:flutter_sudoku/model/field_cell.dart';
import 'package:flutter_sudoku/model/field_cell_type.dart';
import 'package:flutter_sudoku/model/sudoku_field.dart';

class SudokuUserFormatParser {
  /// Encode sudoku field to user-readable format string.
  /// This format is just 9 lines of 9 numbers, where 0 means empty cell.
  /// Numbers are separated by space.
  static String encode(SudokuField field) {
    var result = "";
    for (var row in field.field) {
      for (var cell in row) {
        result +=
            "${cell.type == FieldCellType.empty ? FieldCell.emptyValue : cell.value} ";
      }
      result += "\n";
    }
    return result;
  }

  /// Decodes a sudoku field from user-readable format string.
  /// Returns null on error.
  static List<List<FieldCell>>? decode(String encodedField) {
    var lines = encodedField.split("\n");
    var field =
        List.generate(9, (index) => List.generate(9, (index) => FieldCell()));
    for (var i = 0; i < 9; i++) {
      var line = lines[i];
      var cells = line.split(" ");
      for (var j = 0; j < 9; j++) {
        var cell = cells[j];
        var value = int.parse(cell);
        field[i][j] = FieldCell(
            value: value,
            type: value == FieldCell.emptyValue
                ? FieldCellType.empty
                : FieldCellType.clue);
      }
    }
    return field;
  }
}
