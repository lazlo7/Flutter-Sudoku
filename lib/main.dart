import 'package:flutter/material.dart';
import 'package:flutter_sudoku/model/sudoku_generator.dart';

import 'ui/sudoku_playable_area_widget.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(themeMode: ThemeMode.light, home: SudokuPlayableAreaWidget(SudokuGenerator.generate(5)));
  }
}
