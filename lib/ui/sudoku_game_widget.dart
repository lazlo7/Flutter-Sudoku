import 'package:flutter/material.dart';
import 'package:flutter_sudoku/model/field_cell_type.dart';
import 'package:flutter_sudoku/model/field_coords.dart';
import 'package:flutter_sudoku/ui/icon_undertext_button.dart';
import 'package:flutter_sudoku/model/sudoku_field_keeper.dart';

import '../model/field_move.dart';
import '../model/sudoku_field.dart';

class SudokuGameWidget extends StatefulWidget {
  final String _sudokuFieldId;
  final SudokuFieldKeeper _fieldKeeper;

  const SudokuGameWidget(this._sudokuFieldId, this._fieldKeeper, {super.key});

  @override
  State<StatefulWidget> createState() => _SudokuGameWidgetState();
}

class _SudokuGameWidgetState extends State<SudokuGameWidget> {
  bool notesMode = false;
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
                var cell = widget._fieldKeeper.fields[widget._sudokuFieldId]!
                    .field[row][col];

                var coords = FieldCoords(row, col);
                BoxBorder cellBorder;
                if (coords == conflictingCellCoords) {
                  cellBorder = Border.all(color: Colors.red, width: 2);
                } else if (coords == selectedCellCoords) {
                  cellBorder = Border.all(color: Colors.blue, width: 2);
                } else {
                  cellBorder = Border.all(color: Colors.black, width: 1);
                }

                final notes = widget._fieldKeeper.fields[widget._sudokuFieldId]!
                    .notes[FieldCoords(row, col)];
                Widget cellText;

                if (cell.type == FieldCellType.empty && notes != null) {
                  cellText = Text(notes.map((e) => e.toString()).join(),
                      textAlign: TextAlign.center,
                      softWrap: true,
                      style: const TextStyle(fontSize: 10, color: Colors.grey));
                } else {
                  cellText = Text(
                    cell.type == FieldCellType.empty
                        ? ""
                        : cell.value.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      color: cell.type == FieldCellType.clue
                          ? Colors.blueGrey
                          : Colors.black,
                    ),
                  );
                }

                return Container(
                  decoration: BoxDecoration(border: cellBorder),
                  child: TextButton(
                      style: TextButton.styleFrom(
                          splashFactory: NoSplash.splashFactory,
                          padding: const EdgeInsets.all(0)),
                      onPressed: () => onCellButtonPressed(row, col),
                      child: cellText),
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
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Undo button.
            IconUnderTextButton.build(
              icon: const Icon(Icons.undo),
              text: const Text("Отмена", textAlign: TextAlign.center),
              onPressed: onUndoButtonPressed,
            ),
            // Notes mode button.
            IconUnderTextButton.build(
              icon: notesMode
                  ? const Icon(Icons.edit)
                  : const Icon(Icons.edit_outlined),
              text: const Text("Заметки", textAlign: TextAlign.center),
              onPressed: onNotesButtonPressed,
            ),
            // Restart button.
            IconUnderTextButton.build(
              icon: const Icon(Icons.restart_alt),
              text: const Text("Начать\nсначала", textAlign: TextAlign.center),
              onPressed: onRestartButtonPressed,
            ),
            // Clear cell button.
            IconUnderTextButton.build(
              icon: const Icon(Icons.clear_outlined),
              text: const Text("Очистка", textAlign: TextAlign.center),
              onPressed: onClearCellButtonPressed,
            ),
            // Hint button.
            IconUnderTextButton.build(
                icon: const Icon(Icons.lightbulb_outline),
                text: const Text("Подсказка", textAlign: TextAlign.center),
                onPressed: onHintButtonPressed),
          ],
        )
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

  onCellButtonPressed(int row, int col) {
    if (FieldCoords(row, col) == selectedCellCoords) {
      return;
    }

    final cell =
        widget._fieldKeeper.fields[widget._sudokuFieldId]!.field[row][col];

    // Ignore clues.
    if (cell.type == FieldCellType.clue) {
      return;
    }

    setState(() {
      selectedCellCoords = FieldCoords(row, col);
    });
  }

  void onNumberButtonPressed(int index) {
    // Can't change the cell if no cell is selected.
    if (selectedCellCoords == SudokuField.invalidCoords) {
      return;
    }

    if (notesMode) {
      setState(() {
        widget._fieldKeeper.fields[widget._sudokuFieldId]!.toggleNote(FieldMove(
            FieldCoords(selectedCellCoords.row, selectedCellCoords.col),
            index + 1));
      });
      return;
    }

    var move = FieldMove(
        FieldCoords(selectedCellCoords.row, selectedCellCoords.col), index + 1);

    setState(() {
      selectedCellCoords = SudokuField.invalidCoords;
      conflictingCellCoords =
          widget._fieldKeeper.fields[widget._sudokuFieldId]!.setCell(move);
    });

    if (conflictingCellCoords != SudokuField.invalidCoords) {
      Future.delayed(const Duration(seconds: 1), () {
        // setState only if widget is still mounted
        if (mounted) {
          setState(() {
            conflictingCellCoords = SudokuField.invalidCoords;
          });
        }
      });
    } else {
      widget._fieldKeeper.saveFields();
    }
  }

  void onUndoButtonPressed() {
    // TODO: Imeplement later.
  }

  void onNotesButtonPressed() {
    setState(() {
      notesMode = !notesMode;
    });
  }

  void onRestartButtonPressed() {
    setState(() {
      var field = widget._fieldKeeper.fields[widget._sudokuFieldId]!;
      for (int i = 0; i < 81; ++i) {
        field.clearCell(FieldCoords(i ~/ 9, i % 9));
      }
    });
  }

  void onClearCellButtonPressed() {
    if (selectedCellCoords == SudokuField.invalidCoords) {
      return;
    }
    setState(() {
      widget._fieldKeeper.fields[widget._sudokuFieldId]!
          .clearCell(selectedCellCoords);
    });
  }

  void onHintButtonPressed() {}
}
