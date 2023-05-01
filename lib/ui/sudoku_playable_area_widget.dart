import 'package:flutter/material.dart';
import 'package:flutter_sudoku/ui/sudoku_field_widget.dart';

class SudokuPlayableAreaWidget extends StatelessWidget {
  final SudokuFieldWidget fieldWidget;

  const SudokuPlayableAreaWidget(this.fieldWidget, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.only(top: 50), child: fieldWidget));
  }
}
