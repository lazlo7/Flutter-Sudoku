import 'package:flutter/material.dart';
import 'package:flutter_sudoku/model/field_cell_type.dart';
import 'package:flutter_sudoku/ui/sudoku_game_widget.dart';

import '../model/sudoku_field_keeper.dart';

class SudokuLevelsWidget extends StatefulWidget {
  final SudokuFieldKeeper _fieldKeeper;

  const SudokuLevelsWidget(this._fieldKeeper, {super.key});

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
          itemCount: widget._fieldKeeper.fields.length,
          addAutomaticKeepAlives: true,
          itemBuilder: (context, index) {
            var sudokuId = widget._fieldKeeper.fields.keys.elementAt(index);
            var sudokuField = widget._fieldKeeper.fields[sudokuId]!;

            return Container(
                decoration: BoxDecoration(border: Border.all(width: 1)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextButton(
                        child: GridView.count(
                          crossAxisCount: 9,
                          shrinkWrap: true,
                          primary: false,
                          children: List.generate(81, (index) {
                            final row = index ~/ 9;
                            final col = index % 9;
                            final cell = sudokuField.field[row][col];

                            return Container(
                                decoration:
                                    BoxDecoration(border: Border.all(width: 1)),
                                child: Center(
                                    child: Text(
                                        cell.type == FieldCellType.empty
                                            ? ""
                                            : cell.value.toString(),
                                        style: TextStyle(
                                          color: cell.type == FieldCellType.clue
                                              ? Colors.grey
                                              : Colors.black,
                                        ))));
                          }),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SudokuGameWidget(
                                      sudokuId, widget._fieldKeeper)));
                        },
                      ),
                      TextButton.icon(
                          icon: const Icon(Icons.delete),
                          label: const Text("Удалить"),
                          onPressed: () {
                            widget._fieldKeeper.removeField(sudokuId);
                            setState(() {});
                          })
                    ],
                  ),
                ));
          }),
    );
  }
}
