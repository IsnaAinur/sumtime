class MenuItem {
  final String id;
  final String name;
  final String? description;
  final int price;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;

  const MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
  });

  // Factory constructor from Supabase response
  factory MenuItem.fromSupabase(Map<String, dynamic> data) {
    return MenuItem(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      price: data['price'],
      imageUrl: data['image_url'],
      isAvailable: data['is_available'] ?? true,
      createdAt: data['created_at'] != null ? DateTime.parse(data['created_at']) : null,
      updatedAt: data['updated_at'] != null ? DateTime.parse(data['updated_at']) : null,
      createdBy: data['created_by'],
    );
  }

  // Convert to map for API calls
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'created_by': createdBy,
    };
  }

  // Create copy with updated fields
  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    int? price,
    String? imageUrl,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  // Format price for display
  String get formattedPrice {
    return 'Rp. ${price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }
}

class Poster {
  final String id;
  final String? title;
  final String imageUrl;
  final String? description;
  final bool isActive;
  final int displayOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;

  const Poster({
    required this.id,
    this.title,
    required this.imageUrl,
    this.description,
    this.isActive = true,
    this.displayOrder = 0,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
  });

  // Factory constructor from Supabase response
  factory Poster.fromSupabase(Map<String, dynamic> data) {
    return Poster(
      id: data['id'],
      title: data['title'],
      imageUrl: data['image_url'],
      description: data['description'],
      isActive: data['is_active'] ?? true,
      displayOrder: data['display_order'] ?? 0,
      createdAt: data['created_at'] != null ? DateTime.parse(data['created_at']) : null,
      updatedAt: data['updated_at'] != null ? DateTime.parse(data['updated_at']) : null,
      createdBy: data['created_by'],
    );
  }

  // Convert to map for API calls
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'description': description,
      'is_active': isActive,
      'display_order': displayOrder,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'created_by': createdBy,
    };
  }
}
