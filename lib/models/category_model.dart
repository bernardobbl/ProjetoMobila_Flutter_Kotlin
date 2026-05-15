import 'package:flutter/material.dart';

class CategoryModel {
  final int? id;
  final String name;
  final int iconCode;
  final int colorValue;
  final String type; // 'income' | 'expense'

  const CategoryModel({
    this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    required this.type,
  });

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'icon_code': iconCode,
        'color_value': colorValue,
        'type': type,
      };

  factory CategoryModel.fromMap(Map<String, dynamic> map) => CategoryModel(
        id: map['id'] as int?,
        name: map['name'] as String,
        iconCode: map['icon_code'] as int,
        colorValue: map['color_value'] as int,
        type: map['type'] as String,
      );
}
