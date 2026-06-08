import 'package:flutter/material.dart';

class CategoryModel {
  final int? id;
  final String name;
  final String iconName;
  final int colorValue;
  final String type; // 'income' | 'expense'
  final bool isDefault; // categorias padrão não podem ser excluídas

  const CategoryModel({
    this.id,
    required this.name,
    required this.iconName,
    required this.colorValue,
    required this.type,
    this.isDefault = false,
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
    // Ícones extras disponíveis para categorias personalizadas
    'pets': Icons.pets,
    'flight': Icons.flight,
    'fitness_center': Icons.fitness_center,
    'phone_android': Icons.phone_android,
    'savings': Icons.savings,
    'attach_money': Icons.attach_money,
  };

  /// Nomes de ícones disponíveis para o seletor de categorias personalizadas.
  static List<String> get availableIconNames => _iconMap.keys.toList();

  static IconData iconForName(String name) => _iconMap[name] ?? Icons.category;

  IconData get icon => iconForName(iconName);
  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'icon_name': iconName,
        'color_value': colorValue,
        'type': type,
        'is_default': isDefault ? 1 : 0,
      };

  factory CategoryModel.fromMap(Map<String, dynamic> map) => CategoryModel(
        id: map['id'] as int?,
        name: map['name'] as String,
        iconName: map['icon_name'] as String,
        colorValue: map['color_value'] as int,
        type: map['type'] as String,
        isDefault: (map['is_default'] as int? ?? 1) == 1,
      );

  CategoryModel copyWith({
    String? name,
    String? iconName,
    int? colorValue,
    String? type,
  }) =>
      CategoryModel(
        id: id,
        name: name ?? this.name,
        iconName: iconName ?? this.iconName,
        colorValue: colorValue ?? this.colorValue,
        type: type ?? this.type,
        isDefault: isDefault,
      );
}
