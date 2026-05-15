import 'package:flutter/material.dart';

class CategoryModel {
  final int? id;
  final String name;
  final String iconName;
  final int colorValue;
  final String type; // 'income' | 'expense'

  const CategoryModel({
    this.id,
    required this.name,
    required this.iconName,
    required this.colorValue,
    required this.type,
  });

  // Resolvemos pelo nome em vez de codepoint para evitar inconsistências entre versões do Flutter
  static const Map<String, IconData> _iconMap = {
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'home': Icons.home,
    'local_hospital': Icons.local_hospital,
    'sports_esports': Icons.sports_esports,
    'school': Icons.school,
    'shopping_bag': Icons.shopping_bag,
    'more_horiz': Icons.more_horiz,
    'work': Icons.work,
    'computer': Icons.computer,
    'trending_up': Icons.trending_up,
    'card_giftcard': Icons.card_giftcard,
    'category': Icons.category,
  };

  IconData get icon => _iconMap[iconName] ?? Icons.category;
  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'icon_name': iconName,
        'color_value': colorValue,
        'type': type,
      };

  factory CategoryModel.fromMap(Map<String, dynamic> map) => CategoryModel(
        id: map['id'] as int?,
        name: map['name'] as String,
        iconName: map['icon_name'] as String,
        colorValue: map['color_value'] as int,
        type: map['type'] as String,
      );
}
