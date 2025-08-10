class MenuItem {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  bool isActive; // 👈 Add this field

  MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    this.isActive = true, // default ON
  });
}
