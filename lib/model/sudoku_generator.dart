import 'dart:math';

import 'package:flutter_sudoku/model/field_cell.dart';
import 'package:flutter_sudoku/model/sudoku_field.dart';

import 'field_cell_type.dart';

class SudokuGenerator {
  static final _random = Random();

  static SudokuField generate(int minClues, int maxClues) {
    // TODO: Actually generate the sudoku.
    final solution = [[1, 2, 3, 4, 5, 6, 7, 8, 9],
                      [4, 5, 6, 7, 8, 9, 1, 2, 3],
                      [7, 8, 9, 1, 2, 3, 4, 5, 6],
                      [2, 3, 4, 5, 6, 7, 8, 9, 1],
                      [5, 6, 7, 8, 9, 1, 2, 3, 4],
                      [8, 9, 1, 2, 3, 4, 5, 6, 7],
                      [3, 4, 5, 6, 7, 8, 9, 1, 2],
                      [6, 7, 8, 9, 1, 2, 3, 4, 5],
                      [9, 1, 2, 3, 4, 5, 6, 7, 8]];
    
    final field = solution.map((row) => row.map((cell) => FieldCell(value: cell, type: FieldCellType.clue)).toList()).toList();
    // Remove some of the clues from field.
    final clues = _random.nextInt(maxClues - minClues) + minClues;
    for (int i = 0; i < clues; i++) {
      final row = _random.nextInt(9);
      final col = _random.nextInt(9);
      field[row][col] = FieldCell(value: field[row][col].value, type: FieldCellType.empty);
    }

    return SudokuField(field, solution);
  }
}