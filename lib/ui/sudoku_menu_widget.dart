import 'package:flutter/material.dart';
import 'package:flutter_sudoku/model/sudoku_difficulty.dart';
import 'package:flutter_sudoku/model/sudoku_field_keeper.dart';
import 'package:flutter_sudoku/model/sudoku_generator.dart';
import 'package:flutter_sudoku/ui/sudoku_levels_widget.dart';
import 'package:flutter_sudoku/ui/sudoku_game_widget.dart';

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
            buildLevelButton(
                onPressed: onCreateLevelButtonPressed,
                icon: Icons.add,
                label: "Создать"),
            buildLevelButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SudokuLevelsWidget(widget.fieldKeeper))),
                icon: Icons.more_horiz,
                label: "Уровни"),
            buildLevelButton(
                onPressed: onImportLevelButtonPressed,
                icon: Icons.file_download_outlined,
                label: "Импорт"),
          ],
        )
      ],
    ));
  }

  Widget buildLevelButton(
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return TextButton(
        onPressed: onPressed,
        child: Column(
          children: [
            Icon(icon, size: 32),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18))
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
    final newField = SudokuGenerator.generateField(sudokuDifficulty.minClues, sudokuDifficulty.maxClues);
    final id = widget.fieldKeeper.addField(newField);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SudokuGameWidget(id, widget.fieldKeeper)));
  }

  void onCreateLevelButtonPressed() {}
  void onImportLevelButtonPressed() {}
}
