class Category {
  final String id;
  final String name;
  final String icon;
  final String color;
  final int order;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.order,
  });

  factory Category.fromFirestore(Map<String, dynamic> data, String id) {
    return Category(
      id: id,
      name: data['name'] as String? ?? '',
      icon: data['icon'] as String? ?? 'category',
      color: data['color'] as String? ?? '#6C63FF',
      order: data['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'icon': icon, 'color': color, 'order': order};
  }
}
