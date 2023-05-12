import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_sudoku/model/field_cell_type.dart';
import 'package:flutter_sudoku/model/sudoku_user_format_parser.dart';
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
                                              ? Colors.blueGrey
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton.icon(
                              icon: const Icon(Icons.delete),
                              label: const Text("Удалить"),
                              onPressed: () async {
                                await widget._fieldKeeper.removeField(sudokuId);
                                setState(() {});
                              }),
                          TextButton.icon(
                            icon: const Icon(Icons.file_upload_outlined),
                            label: const Text("Экспорт"),
                            onPressed: () => exportFieldToFile(sudokuId),
                          )
                        ],
                      )
                    ],
                  ),
                ));
          }),
    );
  }

  void exportFieldToFile(String sudokuId) async {
    final field = widget._fieldKeeper.fields[sudokuId]!;
    final encodedField = SudokuUserFormatParser.encode(field);
    final scaffold = ScaffoldMessenger.of(context);
    String? pathResult;

    try {
      pathResult = await FlutterFileDialog.saveFile(
          params: SaveFileDialogParams(
              data: Uint8List.fromList(encodedField.codeUnits),
              fileName: "sudoku-$sudokuId.txt"));
    } catch (e) {
      scaffold.showSnackBar(const SnackBar(
        content: Text("Не удалось сохранить файл!"),
      ));
    }

    // Picker cancelled.
    if (pathResult == null) return;

    scaffold.showSnackBar(const SnackBar(
      content: Text("Судоку экспортировано!"),
    ));
  }
}
