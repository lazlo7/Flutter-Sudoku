import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_sudoku/model/sudoku_difficulty.dart';
import 'package:flutter_sudoku/model/sudoku_field_keeper.dart';
import 'package:flutter_sudoku/model/sudoku_generator.dart';
import 'package:flutter_sudoku/model/sudoku_user_format_parser.dart';
import 'package:flutter_sudoku/ui/sudoku_level_editor_widget.dart';
import 'package:flutter_sudoku/ui/sudoku_levels_widget.dart';
import 'package:flutter_sudoku/ui/sudoku_game_widget.dart';

import 'icon_undertext_button.dart';
import '../model/sudoku_field.dart';

class SudokuMenuWidget extends StatefulWidget {
  const SudokuMenuWidget({required this.fieldKeeper, super.key});

  final SudokuFieldKeeper fieldKeeper;

  @override
  State<StatefulWidget> createState() => _SudokuMenuWidgetState();
}

class _SudokuMenuWidgetState extends State<SudokuMenuWidget> {
  SudokuDifficulty sudokuDifficulty = SudokuDifficulty.medium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        const SizedBox(height: 200),
        const Text("Судоку",
            style: TextStyle(color: Colors.blueGrey, fontSize: 38)),
        const SizedBox(height: 160),
        Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    iconSize: 36,
                    onPressed: () => onSwitchDifficultyButtonPressed(false),
                    icon: const Icon(Icons.arrow_back)),
                Text(sudokuDifficulty.name,
                    style: const TextStyle(fontSize: 20)),
                IconButton(
                    iconSize: 36,
                    onPressed: () => onSwitchDifficultyButtonPressed(true),
                    icon: const Icon(Icons.arrow_forward))
              ],
            )),
        const SizedBox(height: 30),
        ElevatedButton.icon(
            onPressed: onPlayButtonPressed,
            icon: const Icon(Icons.play_arrow),
            label: const Text("Играть", style: TextStyle(fontSize: 20))),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // iconSize: 32, textSize: 18, textAlign: center
            IconUnderTextButton.build(
                onPressed: onCreateLevelButtonPressed,
                icon: const Icon(Icons.add, size: 32),
                text: const Text("Создать",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18))),
            IconUnderTextButton.build(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SudokuLevelsWidget(widget.fieldKeeper))),
                icon: const Icon(Icons.more_horiz, size: 32),
                text: const Text("Уровни",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18))),
            IconUnderTextButton.build(
                onPressed: onImportLevelButtonPressed,
                icon: const Icon(Icons.file_download_outlined, size: 32),
                text: const Text("Импорт",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18))),
          ],
        )
      ],
    ));
  }

  void onSwitchDifficultyButtonPressed(bool next) {
    var difficulties = SudokuDifficulty.values;
    setState(() {
      sudokuDifficulty = difficulties[
          (sudokuDifficulty.index + (next ? 1 : -1)) % difficulties.length];
    });
  }

  void onPlayButtonPressed() {
    final newField = SudokuGenerator.generateField(
        sudokuDifficulty.minClues, sudokuDifficulty.maxClues);
    final id = widget.fieldKeeper.addField(newField);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SudokuGameWidget(id, widget.fieldKeeper)));
  }

  void onCreateLevelButtonPressed() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SudokuLevelEditorWidget(widget.fieldKeeper)));
  }

  void onImportLevelButtonPressed() async {
    final scaffold = ScaffoldMessenger.of(context);
    String? pathResult;

    try {
      pathResult = await FlutterFileDialog.pickFile(
          params: const OpenFileDialogParams());
    } catch (e) {
      scaffold.showSnackBar(
          const SnackBar(content: Text("Не удалось найти файл!")));
    }

    // Picker cancelled.
    if (pathResult == null) return;

    String encodedField;
    try {
      encodedField = await File(pathResult).readAsString();
    } catch (e) {
      scaffold.showSnackBar(
          const SnackBar(content: Text("Не удалось прочитать файл!")));
      return;
    }

    final clues = SudokuUserFormatParser.decode(encodedField);
    if (clues == null) {
      scaffold.showSnackBar(const SnackBar(
          content: Text("Не удалось распознать судоку в файле!")));
      return;
    }

    final solution = SudokuGenerator.solveField(clues);
    if (solution == null) {
      scaffold.showSnackBar(const SnackBar(
          content:
              Text("Не удалось найти уникальное решение для судоку в файле!")));
      return;
    }

    final field = SudokuField(clues, solution);
    scaffold.showSnackBar(const SnackBar(
        content:
            Text("Импортировано новое судоку! Перейдите в меню уровней.")));
  }
}
