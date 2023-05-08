import 'package:flutter/material.dart';
import 'package:flutter_sudoku/model/sudoku_field_keeper.dart';
import 'package:flutter_sudoku/ui/sudoku_menu_widget.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  App({super.key});

  final SudokuFieldKeeper fieldKeeper = SudokuFieldKeeper();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        themeMode: ThemeMode.light,
        home: SudokuMenuWidget(fieldKeeper: fieldKeeper));
  }
}
