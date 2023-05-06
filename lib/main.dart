import 'package:flutter/material.dart';
import 'package:flutter_sudoku/ui/sudoku_menu_widget.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        themeMode: ThemeMode.light, home: SudokuMenuWidget());
  }
}
