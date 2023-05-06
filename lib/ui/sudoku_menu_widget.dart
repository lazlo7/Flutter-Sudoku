import 'package:flutter/material.dart';
import 'package:flutter_sudoku/model/sudoku_difficulty.dart';

class SudokuMenuWidget extends StatefulWidget {
  const SudokuMenuWidget({super.key});

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
        const SizedBox(height: 170),
        const Text("Судоку",
            style: TextStyle(color: Colors.blueGrey, fontSize: 38)),
        const SizedBox(height: 140),
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
        const SizedBox(height: 10),
        ElevatedButton.icon(
            onPressed: onPlayButtonPressed,
            icon: const Icon(Icons.play_arrow),
            label: const Text("Играть")),
        const SizedBox(height: 20),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildLevelButton(
                  onPressed: onCreateLevelButtonPressed,
                  icon: Icons.add,
                  label: "Создать\nуровень"),
              buildLevelButton(
                  onPressed: onLevelsButtonPressed,
                  icon: Icons.more_horiz,
                  label: "Уровни"),
              buildLevelButton(
                  onPressed: onImportLevelButtonPressed,
                  icon: Icons.file_download_outlined,
                  label: "Импортировать\nуровень"),
            ],
          ),
        )
      ],
    ));
  }

  Widget buildLevelButton(
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return Column(children: [
      IconButton(onPressed: onPressed, icon: Icon(icon)),
      Text(label, softWrap: true, textAlign: TextAlign.start)
    ]);
  }

  void onSwitchDifficultyButtonPressed(bool next) {
    var difficulties = SudokuDifficulty.values;
    setState(() {
      sudokuDifficulty = difficulties[
          (sudokuDifficulty.index + (next ? 1 : -1)) % difficulties.length];
    });
  }

  void onPlayButtonPressed() {
    // TODO: Add level generation here.
    print("play button pressed");
  }

  void onCreateLevelButtonPressed() {}
  void onLevelsButtonPressed() {}
  void onImportLevelButtonPressed() {}
}
