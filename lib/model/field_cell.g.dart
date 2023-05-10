// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field_cell.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FieldCell _$FieldCellFromJson(Map<String, dynamic> json) => FieldCell(
      value: json['value'] as int? ?? FieldCell.emptyValue,
      type: $enumDecodeNullable(_$FieldCellTypeEnumMap, json['type']) ??
          FieldCellType.empty,
    );

Map<String, dynamic> _$FieldCellToJson(FieldCell instance) => <String, dynamic>{
      'value': instance.value,
      'type': _$FieldCellTypeEnumMap[instance.type]!,
    };

const _$FieldCellTypeEnumMap = {
  FieldCellType.clue: 'clue',
  FieldCellType.user: 'user',
  FieldCellType.empty: 'empty',
};
