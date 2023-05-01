import 'package:flutter/material.dart';

import '../model/sudoku_field.dart';

class SudokuPlayableAreaWidget extends StatelessWidget {
  final SudokuField _sudokuField;

  const SudokuPlayableAreaWidget(this._sudokuField, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.only(top: 50),
            child: GridView.count(
              crossAxisCount: _sudokuField.field.length,
              children: List.generate(81, (index) {
                var cellValue = _sudokuField.field[index ~/ 9][index % 9];
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  child: cellValue == SudokuField.emptyCellValue
                      ? null
                      : Center(
                          child: Text(
                            _sudokuField.field[index ~/ 9][index % 9]
                                .toString(),
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                );
              }),
            )));
  }
}
