import 'dart:developer';
import 'dart:math';

import 'package:flutter_sudoku/model/field_cell.dart';
import 'package:flutter_sudoku/model/field_cell_type.dart';

import 'sudoku_field.dart';

/*
Inspired by Peter Norvig's "Solving Every Sudoku Puzzle" essay: http://norvig.com/sudoku.html 
*/

class SudokuGenerator {
  static const String _digits = "123456789";

  static const String _rows = "ABCDEFGHI";

  static const String _cols = _digits;

  static final _random = Random();

  static final List<String> _squares = _cross(_rows, _cols);

  // A list of units. A unit is a list of nine squares (column, row or box) that must contain all digits.
  static final List<List<String>> _unitList = List<List<String>>.from(
          _cols.split('').map((c) => _cross(_rows, c))) +
      List<List<String>>.from(_rows.split('').map((r) => _cross(r, _cols))) +
      List<List<String>>.generate(
          9,
          (i) => _cross(_rows.substring((i ~/ 3) * 3, (i ~/ 3) * 3 + 3),
              _cols.substring((i % 3) * 3, (i % 3) * 3 + 3)));

  static final Map<String, List<List<String>>> _units =
      Map<String, List<List<String>>>.fromEntries(_squares.map(
          (s) => MapEntry(s, _unitList.where((u) => u.contains(s)).toList())));

  // Peers of a square are all squares that are in the same unit as the square.
  static final Map<String, Set<String>> _peers =
      Map<String, Set<String>>.fromEntries(_squares.map(
          (s) => MapEntry(s, _units[s]!.expand((u) => u).toSet()..remove(s))));

  /// Returns a random generated valid sudoku field with at least [clues] number of clues.
  static SudokuField generateField(int minClues, int maxClues) {
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

  /// Returns true iff the [field] is valid (i. e. it has only one solution).
  static bool isFieldValid(List<List<FieldCell>> field) {
    return _isGridValid(_encodeGrid(field));
  }

  // Cross product of elements in A and elements in B.
  static List<String> _cross(String A, String B) {
    List<String> result = [];
    for (String a in A.split('')) {
      for (String b in B.split('')) {
        result.add(a + b);
      }
    }
    return result;
  }

  /// Converts grid to a map of possible values, {square: digits}, or
  /// returns False if a contradiction is detected.
  /// A grid is a field with clues only (original state of the field).
  static Map<String, String> _parseGrid(String grid) {
    Map<String, String> values = Map<String, String>.fromEntries(
        _squares.map((s) => MapEntry(s, _digits)));
    for (String s in _squares) {
      if (_digits.contains(grid[_squares.indexOf(s)])) {
        if (!_assign(values, s, grid[_squares.indexOf(s)])) {
          return {};
        }
      }
    }
    return values;
  }

  /// Converts grid into a map of {square: char} with '0' or '.' for empties.
  static Map<String, String> _gridValues(String grid) {
    Map<String, String> chars = Map<String, String>.fromEntries(
        _squares.map((s) => MapEntry(s, _digits)));
    for (String s in _squares) {
      if (_digits.contains(grid[_squares.indexOf(s)])) {
        chars[s] = grid[_squares.indexOf(s)];
      }
    }
    return chars;
  }

  /// Eliminates all the other values (except d) from values[s] and propagates.
  /// Returns true iff there's no contradiction (a field is still valid).
  static bool _assign(Map<String, String> values, String s, String d) {
    String otherValues = values[s]!.replaceAll(d, '');
    for (String d2 in otherValues.split('')) {
      if (!_eliminate(values, s, d2)) {
        return false;
      }
    }
    return true;
  }

  /// Eliminates d from values, propagates when values or places <= 2.
  /// Returns true iff there's no contradiction (a field is still valid).
  static bool _eliminate(Map<String, String> values, String s, String d) {
    if (!values[s]!.contains(d)) {
      return true;
    }
    values[s] = values[s]!.replaceAll(d, '');
    if (values[s]!.isEmpty) {
      return false;
    } else if (values[s]!.length == 1) {
      String d2 = values[s]!;
      for (String s2 in _peers[s]!) {
        if (!_eliminate(values, s2, d2)) {
          return false;
        }
      }
    }
    for (List<String> u in _units[s]!) {
      List<String> dPlaces = [];
      for (String s in u) {
        if (values[s]!.contains(d)) {
          dPlaces.add(s);
        }
      }
      if (dPlaces.isEmpty) {
        return false;
      } else if (dPlaces.length == 1) {
        if (!_assign(values, dPlaces[0], d)) {
          return false;
        }
      }
    }
    return true;
  }

  /// Searches for all solutions using depth-first search and propagation.
  /// Returns an empty list if there are no solutions.
  static List<Map<String, String>> _search(Map<String, String> values) {
    if (values.isEmpty) {
      return [];
    }

    // Check if the field is solved.
    bool solved = true;
    for (String s in _squares) {
      if (values[s]!.length != 1) {
        solved = false;
        break;
      }
    }

    if (solved) {
      return [values];
    }

    String s = values.keys.firstWhere((s) => values[s]!.length > 1);
    List<Map<String, String>> result = [];
    for (String d in values[s]!.split('')) {
      Map<String, String> copy = Map<String, String>.from(values);
      if (_assign(copy, s, d)) {
        List<Map<String, String>> solutions = _search(copy);
        if (solutions.isNotEmpty) {
          result.addAll(solutions);
        }
      }
    }
    return result;
  }

  /// Returns a list of all solution for the given [grid].
  /// Returns an empty list if there are no solutions.
  static List<Map<String, String>> _solve(String grid) {
    return _search(_parseGrid(grid));
  }

  /// Returns true iff the [grid] is valid (i. e. it has only one solution).
  static bool _isGridValid(String grid) {
    return _solve(grid).length == 1;
  }

  /// Encodes a sudoku field to a grid format.
  /// A grid is a string of 81 characters containing only digits 1-9
  /// and '.' as a placeholder for empty squares.
  static String _encodeGrid(List<List<FieldCell>> field) {
    String result = '';
    for (List<FieldCell> row in field) {
      for (FieldCell cell in row) {
        result +=
            cell.type == FieldCellType.empty ? '.' : cell.value.toString();
      }
    }
    return result;
  }

  /// Decodes a [grid] to a sudoku field.
  /// A grid is a string of 81 characters containing only digits 1-9
  /// and '.' as a placeholder for empty squares.
  static List<List<int>> _decodeGrid(String grid) {
    assert(grid.length == 81);
    return List<List<int>>.generate(
        9,
        (i) => List<int>.generate(9, (j) {
              final cell = grid[9 * i + j];
              return cell == '.' ? FieldCell.emptyValue : int.parse(cell);
            }));
  }
}
