import 'package:flutter_sudoku/model/field_cell_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'field_cell.g.dart';

@JsonSerializable(explicitToJson: true)
class FieldCell {
  static const int emptyValue = 0;

  int value;
  FieldCellType type;

  FieldCell({this.value = emptyValue, this.type = FieldCellType.empty});

  factory FieldCell.fromJson(Map<String, dynamic> json) => _$FieldCellFromJson(json);
  Map<String, dynamic> toJson() => _$FieldCellToJson(this);
}