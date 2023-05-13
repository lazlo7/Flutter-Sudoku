import 'package:flutter/material.dart';
import 'package:flutter_sudoku/model/sudoku_field_keeper.dart';
import 'package:flutter_sudoku/ui/loading_overlay.dart';
import 'package:flutter_sudoku/ui/sudoku_menu_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SudokuFieldKeeper fieldKeeper = SudokuFieldKeeper();
  runApp(App(fieldKeeper));
}

class App extends StatelessWidget {
  final SudokuFieldKeeper fieldKeeper;

  const App(this.fieldKeeper, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        themeMode: ThemeMode.light,
        home:
            LoadingOverlay(child: SudokuMenuWidget(fieldKeeper: fieldKeeper)));
  }
}
