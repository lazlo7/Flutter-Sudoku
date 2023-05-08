import 'package:flutter_sudoku/model/field_cell_type.dart';

class FieldCell {
  static const int emptyValue = 0;

  int value;
  FieldCellType type;

  FieldCell({this.value = emptyValue, this.type = FieldCellType.empty});
}