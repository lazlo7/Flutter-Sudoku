import 'package:flutter_sudoku/model/field_cell.dart';
import 'package:flutter_sudoku/model/field_cell_type.dart';
import 'package:flutter_sudoku/model/field_coords.dart';

class SudokuSolver {
  /*
  Based on: https://github.com/jderrickguarin/sudoku-uninformed-search/blob/master/main/Heuristics_Sudoku.py
  */

  /// Tries to solve a sudoku [field] using DFS.
  /// Returns null if the field is invalid or has multiple solutions.
  static List<List<int>>? solve(List<List<int>> field) {
    List<List<int>> solution = [];
    int solutionsFound = 0;

    print("Started solving");
    void search(_SudokuProblem problem) {
      final start = _NodeState(problem.original);
      if (problem.isSolved(start.state)) {
        ++solutionsFound;
        solution = start.state;
      }

      final stack = <_NodeState>[];
      stack.add(start);

      while (stack.isNotEmpty) {
        final node = stack.removeLast();

        print("testing new node");
        if (problem.isSolved(node.state)) {
          print("Found solution");
          ++solutionsFound;
          if (solutionsFound > 1) {
            return;
          }

          solution = node.state;
        }

        stack.addAll(node.expand(problem));
      }
    }

    final problem = _SudokuProblem(field);
    search(problem);

    return solutionsFound > 1 ? null : solution;
  }

  /// Tries to solve a sudoku [field] using DFS.
  /// Returns null if the field is invalid or has multiple solutions.
  static List<List<int>>? solveFieldCell(List<List<FieldCell>> field) => solve(field
      .map((row) => row
          .map((cell) => cell.type == FieldCellType.empty ? FieldCell.emptyValue : cell.value)
          .toList())
      .toList());
}

class _SudokuProblem {
  static const int _size = 9;
  static const int _height = 3;
  static const int _solvedExpectedSum = 45;

  final List<List<int>> original;

  _SudokuProblem(this.original);

  bool isSolved(List<List<int>> state) {
    // Check the sum of rows and columns.
    for (int i = 0; i < _size; i++) {
      int rowSum = 0;
      int colSum = 0;
      for (int j = 0; j < _size; j++) {
        rowSum += state[i][j];
        colSum += state[j][i];
      }
      if (rowSum != _solvedExpectedSum || colSum != _solvedExpectedSum) {
        return false;
      }
    }

    // Check the sum of each quadrant.
    for (int i = 0; i < _height; i++) {
      for (int j = 0; j < _height; j++) {
        int quadSum = 0;
        for (int k = 0; k < _height; k++) {
          for (int l = 0; l < _height; l++) {
            quadSum += state[i * _height + k][j * _height + l];
          }
        }
        if (quadSum != _solvedExpectedSum) {
          return false;
        }
      }
    }

    return true;
  }

  /// Returns a new list of [values] without the values from [used].
  List<int> filterValues(List<int> values, List<int> used) =>
      values.where((element) => !used.contains(element)).toList();

  /// Returns a list of valid values from [state] based on [row].
  List<int> filterRow(List<List<int>> state, int row) {
    final numbers = List.generate(_size, (index) => index + 1);
    final used =
        state[row].where((element) => element != FieldCell.emptyValue).toList();
    return filterValues(numbers, used);
  }

  /// Returns a list of valid values from [state] based on [col].
  List<int> filterCol(List<int> options, List<List<int>> state, int col) {
    final inColumn = <int>[];
    for (int columnIdx = 0; columnIdx < _size; columnIdx++) {
      if (state[columnIdx][col] != FieldCell.emptyValue) {
        inColumn.add(state[columnIdx][col]);
      }
    }
    return filterValues(options, inColumn);
  }

  /// Returns a list of valid values from [state] based on [quad].
  List<int> filterQuad(
      List<int> options, List<List<int>> state, int row, int col) {
    final inQuad = <int>[];
    final rowStart = (row ~/ _height) * _height;
    final colStart = (col ~/ _height) * _height;

    for (int quadRow = 0; quadRow < _height; ++quadRow) {
      for (int quadCol = 0; quadCol < _height; ++quadCol) {
        inQuad.add(state[rowStart + quadRow][colStart + quadCol]);
      }
    }

    return filterValues(options, inQuad);
  }

  /// Returns most constrained field coordinates in [state].
  /// Returns null if there are no more cells to fill.
  FieldCoords? getMostConstrained(List<List<int>> state) {
    FieldCoords? result;
    var targetOptionLength = _size;

    for (int row = 0; row < _size; row++) {
      for (int col = 0; col < _size; col++) {
        if (state[row][col] == FieldCell.emptyValue) {
          var options = filterRow(state, row);
          options = filterCol(options, state, col);
          options = filterQuad(options, state, row, col);

          if (result == null || options.length < targetOptionLength) {
            targetOptionLength = options.length;
            result = FieldCoords(row, col);
          }
        }
      }
    }

    return result;
  }

  /// Yields all possible states from [state] by filling the most constrained
  /// cells with all possible values.
  Iterable<List<List<int>>> getSuccessors(List<List<int>> state) sync* {
    final coords = getMostConstrained(state);
    if (coords == null) {
      return;
    }

    var options = filterRow(state, coords.row);
    options = filterCol(options, state, coords.col);
    options = filterQuad(options, state, coords.row, coords.col);

    for (final option in options) {
      final newState = List.generate(_size,
          (index) => List.generate(_size, (index) => state[index][index]));
      newState[coords.row][coords.col] = option;
      yield newState;
    }
  }
}

class _NodeState {
  final List<List<int>> state;

  _NodeState(this.state);

  List<_NodeState> expand(_SudokuProblem problem) =>
      problem.getSuccessors(state).map((e) => _NodeState(e)).toList();
}
