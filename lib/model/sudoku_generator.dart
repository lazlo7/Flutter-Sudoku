import 'dart:math';

import 'package:flutter_sudoku/model/field_cell.dart';
import 'package:flutter_sudoku/model/sudoku_field.dart';
import 'package:flutter_sudoku/model/sudoku_solver.dart';

import 'field_cell_type.dart';
import 'field_coords.dart';

class SudokuGenerator {
  static const _prefillClues = 11;
  static const _shuffleRepeats = 1000;
  static final _random = Random();

  /// Returns a new Sudoku field with clues in the range [minClues], [maxClues].
  static SudokuField generate(int minClues, int maxClues) {
    List<List<int>> field;
    List<List<int>>? solution;

    while (true) {
      // 1. Generate a random 'prefill' with exactly 11 clues.
      field = _generatePrefill();

      // 2. Solve the prefill.
      solution = _solveAny(field);

      // If there is no solution, go back to step 1.
      if (solution == null) {
        continue;
      }

      // Copy values from the solution into field.
      for (int row = 0; row < 9; ++row) {
        for (int col = 0; col < 9; ++col) {
          field[row][col] = solution[row][col];
        }
      }

      List<List<bool>> forbidden =
          List<List<bool>>.generate(9, (_) => List<bool>.filled(9, false));

      final neededClues = _random.nextInt(maxClues - minClues + 1) + minClues;
      final neededEmpties = 81 - neededClues;
      int empties = 0;

      bool restart = false;
      bool success = false;
      while (empties < neededEmpties) {
        restart = true;
        for (int row = 0; row < 9; ++row) {
          for (int col = 0; col < 9; ++col) {
            if (field[row][col] == FieldCell.emptyValue) {
              continue;
            }

            if (forbidden[row][col]) {
              continue;
            }

            // 3. Judge the uniqueness of the solution by
            // reduction to absurdity.
            // We do that by substituting the original cell
            // with other values from 1 to 9 (while meeting the rules)
            // and checking whether the new field has any solutions.
            // If for all substitutions there are no solutions,
            // we dig out this value.
            final toDigCoords = FieldCoords(row, col);
            final valueToDig = field[row][col];
            if (!_judgeUniqueness(field, valueToDig, toDigCoords)) {
              forbidden[row][col] = true;
              continue;
            }

            // 4. If the uniqueness is confirmed, dig out the cell.
            field[row][col] = FieldCell.emptyValue;
            empties++;
            restart = false;

            if (empties >= neededEmpties) {
              success = true;
              break;
            }
          }

          if (success) {
            break;
          }
        }

        if (restart || success) {
          break;
        }
      }

      if (restart) {
        continue;
      }

      break;
    }

    // 5. Finally, shuffle the field.
    final result = _shuffle(field, solution);
    field = result.key;
    solution = result.value;

    final fieldCells = List<List<FieldCell>>.generate(
        9,
        (row) => List<FieldCell>.generate(
            9,
            (col) => FieldCell(
                value: field[row][col],
                type: field[row][col] == FieldCell.emptyValue
                    ? FieldCellType.empty
                    : FieldCellType.clue)));

    return SudokuField(fieldCells, solution);
  }

  /// Returns a new randomly generated 'prefill'
  /// with exactly 11 clues.
  static List<List<int>> _generatePrefill() {
    final field =
        List.generate(9, (_) => List<int>.filled(9, FieldCell.emptyValue));

    int clues = 0;
    while (clues < _prefillClues) {
      final row = _random.nextInt(9);
      final col = _random.nextInt(9);

      if (field[row][col] != FieldCell.emptyValue) {
        continue;
      }

      final value = _random.nextInt(9) + 1;
      final coords = FieldCoords(row, col);
      field[row][col] = value;

      if (!SudokuSolver.isFieldCellCorrect(field, coords)) {
        field[row][col] = FieldCell.emptyValue;
        continue;
      }

      clues++;
    }

    return field;
  }

  /// Returns any solution for the given [field].
  /// Returns null if there is no solution.
  static List<List<int>>? _solveAny(List<List<int>> field) {
    final problem = SudokuProblem(field);
    if (problem.isSolved(field)) {
      return field;
    }

    final start = NodeState(problem.original);

    final stack = <NodeState>[];
    stack.add(start);

    while (stack.isNotEmpty) {
      final node = stack.removeLast();
      if (problem.isSolved(node.state)) {
        return node.state;
      }
      stack.addAll(node.expand(problem));
    }

    return null;
  }

  /// Returns true if the given [toDig] value at [toDigCoords]
  /// in [field] could be dug out without breaking
  /// the uniqueness of the solution.
  static bool _judgeUniqueness(
      List<List<int>> field, int toDig, FieldCoords toDigCoords) {
    for (int number = 1; number <= 9; ++number) {
      if (number == toDig) {
        continue;
      }

      field[toDigCoords.row][toDigCoords.col] = number;
      final solution = _solveAny(field);
      if (solution != null) {
        field[toDigCoords.row][toDigCoords.col] = toDig;
        return false;
      }
    }

    return true;
  }

  /// Shuffles [field] and [solution] using differrent equivalent transformations.
  static MapEntry<List<List<int>>, List<List<int>>> _shuffle(
      List<List<int>> field, List<List<int>> solution) {
    final shufflers = <_FieldShuffler>[
      _TwoMutualDigitsShuffler(),
      _TwoColumnsInSameColumnOfBlocksShuffler(),
      _TwoColumnsOfBlocksShuffler(),
      _TwoRowsInSameRowOfBlocksShuffler(),
      _TwoRowsOfBlocksShuffler(),
      _GridRollingShuffler()
    ];

    for (int i = 0; i < _shuffleRepeats; ++i) {
      shufflers.shuffle(_random);
      for (final shuffler in shufflers) {
        shuffler.shuffle(field, solution, _random);
      }
    }

    return MapEntry(field, solution);
  }
}

/// Common interface for all field shufflers.
abstract class _FieldShuffler {
  MapEntry<List<List<int>>, List<List<int>>> shuffle(
      List<List<int>> field, List<List<int>> solution, Random random);
}

/// Mutually exchanges two digits in the field.
class _TwoMutualDigitsShuffler implements _FieldShuffler {
  @override
  MapEntry<List<List<int>>, List<List<int>>> shuffle(
      List<List<int>> field, List<List<int>> solution, Random random) {
    final digit1 = random.nextInt(9) + 1;

    int digit2;
    do {
      digit2 = random.nextInt(9) + 1;
    } while (digit2 == digit1);

    for (int row = 0; row < 9; ++row) {
      for (int col = 0; col < 9; ++col) {
        if (field[row][col] == digit1) {
          field[row][col] = digit2;
        } else if (field[row][col] == digit2) {
          field[row][col] = digit1;
        }

        if (solution[row][col] == digit1) {
          solution[row][col] = digit2;
        } else if (solution[row][col] == digit2) {
          solution[row][col] = digit1;
        }
      }
    }

    return MapEntry(field, solution);
  }
}

/// Mutually exchanges two columns in the same column of blocks.
class _TwoColumnsInSameColumnOfBlocksShuffler implements _FieldShuffler {
  @override
  MapEntry<List<List<int>>, List<List<int>>> shuffle(
      List<List<int>> field, List<List<int>> solution, Random random) {
    final columnBlock = random.nextInt(3);
    final column1 = random.nextInt(3);

    int column2;
    do {
      column2 = random.nextInt(3);
    } while (column2 == column1);

    for (int row = 0; row < 9; ++row) {
      final tempField = field[row][columnBlock * 3 + column1];
      field[row][columnBlock * 3 + column1] =
          field[row][columnBlock * 3 + column2];
      field[row][columnBlock * 3 + column2] = tempField;

      final tempSolution = solution[row][columnBlock * 3 + column1];
      solution[row][columnBlock * 3 + column1] =
          solution[row][columnBlock * 3 + column2];
      solution[row][columnBlock * 3 + column2] = tempSolution;
    }

    return MapEntry(field, solution);
  }
}

/// Mutually exchanges two columns of blocks.
class _TwoColumnsOfBlocksShuffler implements _FieldShuffler {
  @override
  MapEntry<List<List<int>>, List<List<int>>> shuffle(
      List<List<int>> field, List<List<int>> solution, Random random) {
    final columnBlock1 = random.nextInt(3);
    int columnBlock2;
    do {
      columnBlock2 = random.nextInt(3);
    } while (columnBlock2 == columnBlock1);

    for (int row = 0; row < 9; ++row) {
      for (int column = 0; column < 3; ++column) {
        final tempField = field[row][columnBlock1 * 3 + column];
        field[row][columnBlock1 * 3 + column] =
            field[row][columnBlock2 * 3 + column];
        field[row][columnBlock2 * 3 + column] = tempField;

        final tempSolution = solution[row][columnBlock1 * 3 + column];
        solution[row][columnBlock1 * 3 + column] =
            solution[row][columnBlock2 * 3 + column];
        solution[row][columnBlock2 * 3 + column] = tempSolution;
      }
    }

    return MapEntry(field, solution);
  }
}

// Mutually exchanges two rows in the same row of blocks.
class _TwoRowsInSameRowOfBlocksShuffler implements _FieldShuffler {
  @override
  MapEntry<List<List<int>>, List<List<int>>> shuffle(
      List<List<int>> field, List<List<int>> solution, Random random) {
    final rowBlock = random.nextInt(3);
    final row1 = random.nextInt(3);

    int row2;
    do {
      row2 = random.nextInt(3);
    } while (row2 == row1);

    for (int column = 0; column < 9; ++column) {
      final tempField = field[rowBlock * 3 + row1][column];
      field[rowBlock * 3 + row1][column] = field[rowBlock * 3 + row2][column];
      field[rowBlock * 3 + row2][column] = tempField;

      final tempSolution = solution[rowBlock * 3 + row1][column];
      solution[rowBlock * 3 + row1][column] =
          solution[rowBlock * 3 + row2][column];
      solution[rowBlock * 3 + row2][column] = tempSolution;
    }

    return MapEntry(field, solution);
  }
}

/// Mutually exchanges two rows of blocks.
class _TwoRowsOfBlocksShuffler implements _FieldShuffler {
  @override
  MapEntry<List<List<int>>, List<List<int>>> shuffle(
      List<List<int>> field, List<List<int>> solution, Random random) {
    final rowBlock1 = random.nextInt(3);
    int rowBlock2;
    do {
      rowBlock2 = random.nextInt(3);
    } while (rowBlock2 == rowBlock1);

    for (int column = 0; column < 9; ++column) {
      for (int row = 0; row < 3; ++row) {
        final tempField = field[rowBlock1 * 3 + row][column];
        field[rowBlock1 * 3 + row][column] = field[rowBlock2 * 3 + row][column];
        field[rowBlock2 * 3 + row][column] = tempField;

        final tempSolution = solution[rowBlock1 * 3 + row][column];
        solution[rowBlock1 * 3 + row][column] =
            solution[rowBlock2 * 3 + row][column];
        solution[rowBlock2 * 3 + row][column] = tempSolution;
      }
    }

    return MapEntry(field, solution);
  }
}

/// Rolls the grid.
class _GridRollingShuffler implements _FieldShuffler {
  @override
  MapEntry<List<List<int>>, List<List<int>>> shuffle(
      List<List<int>> field, List<List<int>> solution, Random random) {
    final rolling = random.nextInt(3);
    final rollingDirection = random.nextBool();

    if (rollingDirection) {
      for (int row = 0; row < 9; ++row) {
        final tempField = field[row][rolling * 3];
        field[row][rolling * 3] = field[row][rolling * 3 + 1];
        field[row][rolling * 3 + 1] = field[row][rolling * 3 + 2];
        field[row][rolling * 3 + 2] = tempField;

        final tempSolution = solution[row][rolling * 3];
        solution[row][rolling * 3] = solution[row][rolling * 3 + 1];
        solution[row][rolling * 3 + 1] = solution[row][rolling * 3 + 2];
        solution[row][rolling * 3 + 2] = tempSolution;
      }
    } else {
      for (int row = 0; row < 9; ++row) {
        final tempField = field[row][rolling * 3 + 2];
        field[row][rolling * 3 + 2] = field[row][rolling * 3 + 1];
        field[row][rolling * 3 + 1] = field[row][rolling * 3];
        field[row][rolling * 3] = tempField;

        final tempSolution = solution[row][rolling * 3 + 2];
        solution[row][rolling * 3 + 2] = solution[row][rolling * 3 + 1];
        solution[row][rolling * 3 + 1] = solution[row][rolling * 3];
        solution[row][rolling * 3] = tempSolution;
      }
    }

    return MapEntry(field, solution);
  }
}
