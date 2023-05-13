// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sudoku_field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SudokuField _$SudokuFieldFromJson(Map<String, dynamic> json) => SudokuField(
      (json['field'] as List<dynamic>)
          .map((e) => (e as List<dynamic>)
              .map((e) => FieldCell.fromJson(e as Map<String, dynamic>))
              .toList())
          .toList(),
      (json['solution'] as List<dynamic>)
          .map((e) => (e as List<dynamic>).map((e) => e as int).toList())
          .toList(),
      json['hintsReward'] as int,
    );

Map<String, dynamic> _$SudokuFieldToJson(SudokuField instance) =>
    <String, dynamic>{
      'field':
          instance.field.map((e) => e.map((e) => e.toJson()).toList()).toList(),
      'solution': instance.solution,
      'hintsReward': instance.hintsReward,
    };
