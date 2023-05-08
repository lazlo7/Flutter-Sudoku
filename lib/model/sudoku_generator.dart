import 'package:flutter_sudoku/model/field_cell.dart';

import 'sudoku_field.dart';

class SudokuGenerator {
  /// Returns a new sudoku field.
  static SudokuField generate(int clues) {
    // TODO: Actually generate a sudoku field.
    // For now, just return a field with all zeroes.
    return SudokuField(List.generate(9, (index) => List.generate(9, (index) => FieldCell.emptyValue)));
  }
}