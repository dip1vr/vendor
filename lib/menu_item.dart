class MenuItem {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final String? imageUrl; // 👈 Add this field
  bool isActive;

  MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    this.imageUrl, // 👈 Add this
    this.isActive = true,
  });
}
