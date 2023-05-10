import 'package:json_annotation/json_annotation.dart';

part 'field_coords.g.dart';

@JsonSerializable()
class FieldCoords {
  final int row;
  final int col;
  const FieldCoords(this.row, this.col);

  factory FieldCoords.fromJson(Map<String, dynamic> json) => _$FieldCoordsFromJson(json);
  Map<String, dynamic> toJson() => _$FieldCoordsToJson(this);

  @override
  bool operator ==(Object other) {
    if (other is FieldCoords) {
      return row == other.row && col == other.col;
    }
    return false;
  }

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() {
    return 'FieldCoords{x: $row, y: $col}';
  }
}