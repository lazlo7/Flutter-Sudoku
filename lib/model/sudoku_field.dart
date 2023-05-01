import 'dart:collection';

import 'field_coords.dart';
import 'field_move.dart';

class SudokuField {
  static const int emptyCellValue = 0;

  // Current playable field.
  final List<List<int>> _field =
      List.generate(9, (index) => List.generate(9, (index) => emptyCellValue));
  // The solution to this field.
  final List<List<int>> _solution;
  // Maps a cell to it's notes (possible values left by the player).
  final Map<FieldCoords, List<int>> _notes = HashMap();

  SudokuField(this._solution);

  /// Returns the field as a list of lists of integers.
  List<List<int>> get field => _field;

  /// Returns the solution field as a list of lists of integers.
  List<List<int>> get solution => _solution;

  /// Returns the notes of this field.
  Map<FieldCoords, List<int>> get notes => _notes;

  /// Returns true if a such sudoku move is valid (i. e. can be made) on the field.
  /// A sudoku move is valid iff the sudoku move's value is not present in the same row, column or 3x3 square
  /// and move's position is not occupied by a non-empty cell value.
  bool isValidMove(FieldMove move) {
    // Check if the move's value is present in the same row
    for (int col = 0; col < _field.length; col++) {
      if (_field[move.coords.row][col] == move.value) {
        return false;
      }
    }

    // Check if the move's value is present in the same column
    for (int row = 0; row < _field.length; row++) {
      if (_field[row][move.coords.col] == move.value) {
        return false;
      }
    }

    // Check if the move's value is present in the same 3x3 square
    int squareRow = move.coords.row ~/ 3;
    int squareCol = move.coords.col ~/ 3;
    for (int row = squareRow * 3; row < squareRow * 3 + 3; row++) {
      for (int col = squareCol * 3; col < squareCol * 3 + 3; col++) {
        if (_field[row][col] == move.value) {
          return false;
        }
      }
    }

    return true;
  }

  /// Returns true if the sudoku field is solved (i. e. the board is full of non-empty cell values).
  bool isSolved() {
    for (int row = 0; row < _field.length; row++) {
      for (int col = 0; col < _field.length; col++) {
        if (_field[row][col] == emptyCellValue) {
          return false;
        }
      }
    }

    return true;
  }

  /// Sets the cell at the given row and column to the given value.
  /// Returns true if the cell was set successfully (the provided move was valid), false otherwise.
  bool setCell(FieldMove move) {
    if (isValidMove(move)) {
      _field[move.coords.row][move.coords.col] = move.value;
      return true;
    }
    return false;
  }

  /// Clears the cell at the given row and column.
  /// Returns true if the cell at the provided coords is not empty, false otherwise.
  bool clearCell(FieldCoords coords) {
    if (_field[coords.row][coords.col] != emptyCellValue) {
      _field[coords.row][coords.col] = emptyCellValue;
      return true;
    }
    return false;
  }

  /// Adds a note for the given cell.
  /// Returns true if the cell doesn't contain the given note already, otherwise false.
  bool addNote(FieldMove note) {
    if (!_notes.containsKey(note.coords)) {
      _notes[note.coords] = [note.value];
      return true;
    } else if (!_notes[note.coords]!.contains(note.value)) {
      _notes[note.coords]!.add(note.value);
      return true;
    }
    return false;
  }

  /// Removes a note for the given cell.
  /// Returns true if the cell contains the given note, otherwise false.
  bool removeNote(FieldMove note) {
    if (_notes.containsKey(note.coords) &&
        _notes[note.coords]!.contains(note.value)) {
      _notes[note.coords]!.remove(note.value);
      return true;
    }
    return false;
  }
}
