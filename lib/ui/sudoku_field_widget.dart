import 'package:flutter/material.dart';
import 'package:flutter_sudoku/model/sudoku_field.dart';

class SudokuFieldWidget extends StatelessWidget {
  final SudokuField _sudokuField;

  const SudokuFieldWidget(this._sudokuField, {super.key});

  @override
  Widget build(BuildContext context) {
    // Draw the sudoku field
    return GridView.count(
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
                    _sudokuField.field[index ~/ 9][index % 9].toString(),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
        );
      }),
    );
  }
}
