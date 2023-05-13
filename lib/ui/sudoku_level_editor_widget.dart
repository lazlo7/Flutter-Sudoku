import 'package:flutter/material.dart';
import 'package:flutter_sudoku/model/field_cell.dart';
import 'package:flutter_sudoku/model/field_cell_type.dart';
import 'package:flutter_sudoku/model/field_move.dart';
import 'package:flutter_sudoku/model/sudoku_field_keeper.dart';
import 'package:flutter_sudoku/model/sudoku_solver.dart';
import 'package:flutter_sudoku/ui/sudoku_game_widget.dart';

import '../model/field_coords.dart';
import '../model/sudoku_field.dart';
import 'icon_undertext_button.dart';

class SudokuLevelEditorWidget extends StatefulWidget {
  final SudokuFieldKeeper _fieldKeeper;

  const SudokuLevelEditorWidget(this._fieldKeeper, {super.key});

  @override
  State<SudokuLevelEditorWidget> createState() =>
      _SudokuLevelEditorWidgetState();
}

class _SudokuLevelEditorWidgetState extends State<SudokuLevelEditorWidget> {
  FieldCoords selectedCellCoords = SudokuField.invalidCoords;
  FieldCoords conflictingCellCoords = SudokuField.invalidCoords;
  List<List<int>> field =
      List.generate(9, (index) => List.filled(9, FieldCell.emptyValue));
  List<FieldMove> history = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Редактор уровней'),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: onSaveButtonPressed,
            )
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 100),
            Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: GridView.count(
                  crossAxisCount: 9,
                  shrinkWrap: true,
                  primary: false,
                  children: List.generate(81, (index) {
                    var row = index ~/ 9;
                    var col = index % 9;
                    var cell = field[row][col];

                    var coords = FieldCoords(row, col);
                    BoxBorder cellBorder;
                    if (coords == conflictingCellCoords) {
                      cellBorder = Border.all(color: Colors.red, width: 2);
                    } else if (coords == selectedCellCoords) {
                      cellBorder = Border.all(color: Colors.blue, width: 2);
                    } else {
                      cellBorder = Border.all(color: Colors.black, width: 1);
                    }

                    return Container(
                        decoration: BoxDecoration(border: cellBorder),
                        child: TextButton(
                          style: TextButton.styleFrom(
                              splashFactory: NoSplash.splashFactory,
                              padding: const EdgeInsets.all(0)),
                          onPressed: () {
                            if (row != selectedCellCoords.row ||
                                col != selectedCellCoords.col) {
                              setState(() =>
                                  selectedCellCoords = FieldCoords(row, col));
                            }
                          },
                          child: Text(
                            cell == FieldCell.emptyValue ? "" : cell.toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ));
                  }),
                )),
            const SizedBox(height: 50),
            Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildNumberButton(0),
                      buildNumberButton(1),
                      buildNumberButton(2),
                      buildNumberButton(3),
                      buildNumberButton(4)
                    ])),
            const SizedBox(height: 10),
            Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      buildNumberButton(5),
                      buildNumberButton(6),
                      buildNumberButton(7),
                      buildNumberButton(8)
                    ])),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Undo button.
                IconUnderTextButton.build(
                  icon: const Icon(Icons.undo),
                  text: const Text("Отмена", textAlign: TextAlign.center),
                  onPressed: onUndoButtonPressed,
                ),
                // Clear cell button.
                IconUnderTextButton.build(
                  icon: const Icon(Icons.clear_outlined),
                  text: const Text("Очистка", textAlign: TextAlign.center),
                  onPressed: onClearCellButtonPressed,
                ),
              ],
            )
          ],
        ));
  }

  void onSaveButtonPressed() {
    final fieldCells = List.generate(9, (row) {
      return List.generate(9, (col) {
        var value = field[row][col];
        return FieldCell(
            value: value,
            type: value == FieldCell.emptyValue
                ? FieldCellType.empty
                : FieldCellType.clue);
      });
    });

    final solution = SudokuSolver.solveFieldCell(fieldCells);
    if (solution == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Судоку не является валидным!")));
      return;
    }

    final sudokuField = SudokuField(fieldCells, solution, 0);
    final sudokuId = widget._fieldKeeper.addField(sudokuField);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SudokuGameWidget(sudokuId, widget._fieldKeeper)));
  }

  SizedBox buildNumberButton(int index) {
    var number = index + 1;

    return SizedBox(
      height: 50,
      width: 50,
      child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 1.5,
            ),
          ),
          child: TextButton(
            onPressed: () => onNumberButtonPressed(index),
            child: Text(
              number.toString(),
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          )),
    );
  }

  void onNumberButtonPressed(int index) {
    if (selectedCellCoords == SudokuField.invalidCoords) {
      return;
    }

    final number = index + 1;
    if (field[selectedCellCoords.row][selectedCellCoords.col] == number) {
      return;
    }

    final cellBefore = field[selectedCellCoords.row][selectedCellCoords.col];
    history.add(FieldMove(selectedCellCoords, cellBefore));

    setState(() {
      field[selectedCellCoords.row][selectedCellCoords.col] = number;
      selectedCellCoords = SudokuField.invalidCoords;
    });
  }

  void onClearCellButtonPressed() {
    if (selectedCellCoords == SudokuField.invalidCoords) {
      return;
    }

    if (field[selectedCellCoords.row][selectedCellCoords.col] ==
        FieldCell.emptyValue) {
      return;
    }

    final cellBefore = field[selectedCellCoords.row][selectedCellCoords.col];
    history.add(FieldMove(selectedCellCoords, cellBefore));

    setState(() {
      field[selectedCellCoords.row][selectedCellCoords.col] =
          FieldCell.emptyValue;
      selectedCellCoords = SudokuField.invalidCoords;
    });
  }

  void onUndoButtonPressed() {
    if (history.isEmpty) {
      return;
    }

    final move = history.removeLast();
    setState(() {
      field[move.coords.row][move.coords.col] = move.value;
    });
  }
}
