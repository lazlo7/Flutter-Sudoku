import 'package:flutter_sudoku/model/field_cell_type.dart';
import 'package:json_annotation/json_annotation.dart';

import 'field_cell.dart';
import 'field_coords.dart';
import 'field_move.dart';

part 'sudoku_field.g.dart';

@JsonSerializable(explicitToJson: true)
class SudokuField {
  static const FieldCoords invalidCoords = FieldCoords(-1, -1);

  // Current playable field.
  final List<List<FieldCell>> field;
  // The solution to this field.
  final List<List<int>> solution;
  // Maps a cell to it's notes (possible values left by the player).
  final Map<FieldCoords, List<int>> notes = {};

  SudokuField(this.field, this.solution);

  factory SudokuField.fromJson(Map<String, dynamic> json) =>
      _$SudokuFieldFromJson(json);
  Map<String, dynamic> toJson() => _$SudokuFieldToJson(this);

  /// Returns invalidCoords constant if the move is valid,
  /// otherwise returns the coords of the first found cell, that conflicts with the move.
  /// A sudoku move is valid iff the sudoku move's value is not present in the same row, column or 3x3 square
  /// and move's position is not occupied by a non-empty cell value.
  FieldCoords isValidMove(FieldMove move) {
    // Check if the move's value is present in the same row
    for (int col = 0; col < field.length; col++) {
      if (field[move.coords.row][col].type == FieldCellType.clue &&
          field[move.coords.row][col].value == move.value) {
        return FieldCoords(move.coords.row, col);
      }
    }

    // Check if the move's value is present in the same column
    for (int row = 0; row < field.length; row++) {
      if (field[row][move.coords.col].type == FieldCellType.clue &&
          field[row][move.coords.col].value == move.value) {
        return FieldCoords(row, move.coords.col);
      }
    }

    // Check if the move's value is present in the same 3x3 square
    int squareRow = move.coords.row ~/ 3;
    int squareCol = move.coords.col ~/ 3;
    for (int row = squareRow * 3; row < squareRow * 3 + 3; row++) {
      for (int col = squareCol * 3; col < squareCol * 3 + 3; col++) {
        if (field[row][col].type == FieldCellType.clue &&
            field[row][col].value == move.value) {
          return FieldCoords(row, col);
        }
      }
    }

    return invalidCoords;
  }

  /// Returns true if the sudoku field is solved (i. e. the board is full of non-empty cell values).
  bool isSolved() {
    for (int row = 0; row < field.length; row++) {
      for (int col = 0; col < field.length; col++) {
        if (field[row][col].type == FieldCellType.empty) {
          return false;
        }
      }
    }

    return true;
  }

  /// Sets the cell at the given row and column to the given value.
  /// Returns invalidCoords constant if the cell was set successfully (the provided move was valid),
  /// otherwise returns the coords of the first found cell, that conflicts with the move.
  FieldCoords setCell(FieldMove move) {
    FieldCoords conflictingCoords = isValidMove(move);
    if (conflictingCoords == SudokuField.invalidCoords) {
      field[move.coords.row][move.coords.col] =
          FieldCell(value: move.value, type: FieldCellType.user);
    }
    return conflictingCoords;
  }

  /// Clears the cell at the given row and column.
  /// Returns true if the cell at the provided coords is not empty, false otherwise.
  bool clearCell(FieldCoords coords) {
    if (field[coords.row][coords.col].type != FieldCellType.empty) {
      field[coords.row][coords.col].type = FieldCellType.empty;
      return true;
    }
    return false;
  }

  /// Adds a note for the given cell.
  /// Returns true if the cell doesn't contain the given note already, otherwise false.
  void toggleNote(FieldMove note) {
    if (!notes.containsKey(note.coords)) {
      notes[note.coords] = [note.value];
      return;
    } else if (notes[note.coords]!.contains(note.value)) {
      notes[note.coords]!.remove(note.value);
      return;
    }

    notes[note.coords]!.add(note.value);
    notes[note.coords]!.sort();
    return;
  }

  /// Removes a note for the given cell.
  /// Returns true if the cell contains the given note, otherwise false.
  bool removeNote(FieldMove note) {
    if (notes.containsKey(note.coords) &&
        notes[note.coords]!.contains(note.value)) {
      notes[note.coords]!.remove(note.value);
      return true;
    }
    return false;
  }
}
