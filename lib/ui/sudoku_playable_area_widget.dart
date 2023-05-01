import 'package:flutter/material.dart';
import 'package:flutter_sudoku/model/field_coords.dart';

import '../model/sudoku_field.dart';

class SudokuPlayableAreaWidget extends StatefulWidget {
  final SudokuField _sudokuField;

  const SudokuPlayableAreaWidget(this._sudokuField, {super.key});

  @override
  State<StatefulWidget> createState() => _SudokuPlayableAreaWidgetState();
}

class _SudokuPlayableAreaWidgetState extends State<SudokuPlayableAreaWidget> {
  FieldCoords selectedCellCoords = FieldCoords(-1, -1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.only(top: 100, left: 10, right: 10),
            child: GridView.count(
              crossAxisCount: widget._sudokuField.field.length,
              children: List.generate(81, (index) {
                var row = index ~/ 9;
                var col = index % 9;
                var cellValue = widget._sudokuField.field[row][col];

                return Container(
                  decoration: BoxDecoration(
                    border: selectedCellCoords.row == row &&
                            selectedCellCoords.col == col
                        ? Border.all(
                            color: Colors.blue,
                            width: 2,
                          )
                        : Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                  ),
                  child: OutlinedButton(
                      style: const ButtonStyle(
                          splashFactory: NoSplash.splashFactory),
                      onPressed: () => setState(
                          () => selectedCellCoords = FieldCoords(row, col)),
                      child: cellValue == SudokuField.emptyCellValue
                          ? null
                          : Center(
                              child: Text(
                                cellValue.toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            )),
                );
              }),
            )));
  }
}
