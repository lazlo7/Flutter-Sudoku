import 'package:flutter/material.dart';
import 'package:flutter_sudoku/model/field_cell_type.dart';
import 'package:flutter_sudoku/model/field_coords.dart';

import '../model/field_move.dart';
import '../model/sudoku_field.dart';

class SudokuPlayableAreaWidget extends StatefulWidget {
  final SudokuField _sudokuField;

  const SudokuPlayableAreaWidget(this._sudokuField, {super.key});

  @override
  State<StatefulWidget> createState() => _SudokuPlayableAreaWidgetState();
}

class _SudokuPlayableAreaWidgetState extends State<SudokuPlayableAreaWidget> {
  Future<void>? conflictingRemoveFuture;
  FieldCoords selectedCellCoords = SudokuField.invalidCoords;
  FieldCoords conflictingCellCoords = SudokuField.invalidCoords;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                var cell = widget._sudokuField.field[row][col];

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
                      style: const ButtonStyle(
                          splashFactory: NoSplash.splashFactory),
                      onPressed: () {
                        if (row != selectedCellCoords.row ||
                            col != selectedCellCoords.col) {
                          setState(
                              () => selectedCellCoords = FieldCoords(row, col));
                        }
                      },
                      child: Text(
                        cell.type == FieldCellType.empty 
                            ? ""
                            : cell.value.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      )),
                );
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
      ],
    ));
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

    var move = FieldMove(
        FieldCoords(selectedCellCoords.row, selectedCellCoords.col), index + 1);

    setState(() {
      selectedCellCoords = SudokuField.invalidCoords;
      conflictingCellCoords = widget._sudokuField.setCell(move);
    });

    if (conflictingCellCoords != SudokuField.invalidCoords) {
      conflictingRemoveFuture = Future.delayed(const Duration(seconds: 1), () {
        // setState only if widget is still mounted
        if (mounted) {
          setState(() {
            conflictingCellCoords = SudokuField.invalidCoords;
          });
        } 
      });
    }
  }
}
