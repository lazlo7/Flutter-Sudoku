import 'package:flutter/material.dart';
import 'package:flutter_sudoku/model/field_cell_type.dart';

import '../model/sudoku_field_keeper.dart';

class SudokuLevelsWidget extends StatefulWidget {
  final SudokuFieldKeeper fieldKeeper;

  const SudokuLevelsWidget({required this.fieldKeeper, super.key});

  @override
  State<SudokuLevelsWidget> createState() => _SudokuLevelsWidgetState();
}

class _SudokuLevelsWidgetState extends State<SudokuLevelsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Уровни", style: TextStyle(fontSize: 24))),
      body: ListView.builder(
          itemCount: widget.fieldKeeper.fields.length,
          addAutomaticKeepAlives: true,
          itemBuilder: (context, index) {
            var sudokuId = widget.fieldKeeper.fields.keys.elementAt(index);
            var sudokuField = widget.fieldKeeper.fields[sudokuId];

            return Container(
                decoration: BoxDecoration(border: Border.all(width: 1)),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: GridView.count(
                    crossAxisCount: 9,
                    shrinkWrap: true,
                    primary: false,
                    children: List.generate(81, (index) {
                      final row = index ~/ 9;
                      final col = index % 9;
                      final cell = sudokuField!.field[row][col];

                      return Container(
                          decoration:
                              BoxDecoration(border: Border.all(width: 1)),
                          child: Center(
                              child: Text(
                                  cell.type == FieldCellType.empty
                                      ? ""
                                      : cell.value.toString())));
                    }),
                  ),
                ));
          }),
    );
  }
}
