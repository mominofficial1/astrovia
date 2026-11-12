class InventoryItem {
  final String id;
  final String name;
  final String category; // "Sample", "Tool", "Instrument", "Recovered Component"
  final double massKg;
  final String description;
  final String locationFound;
  final String missionRelevance;
  final String iconKey;
  bool isSecuredInVehicle;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.massKg,
    required this.description,
    required this.locationFound,
    required this.missionRelevance,
    required this.iconKey,
    this.isSecuredInVehicle = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'massKg': massKg,
        'description': description,
        'locationFound': locationFound,
        'missionRelevance': missionRelevance,
        'iconKey': iconKey,
        'isSecuredInVehicle': isSecuredInVehicle,
      };

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        massKg: (json['massKg'] as num).toDouble(),
        description: json['description'] as String,
        locationFound: json['locationFound'] as String,
        missionRelevance: json['missionRelevance'] as String,
        iconKey: json['iconKey'] as String? ?? "science",
        isSecuredInVehicle: json['isSecuredInVehicle'] as bool? ?? false,
      );
}

class InventoryBag {
  final double maxCapacityKg;
  final List<InventoryItem> items;

  InventoryBag({
    this.maxCapacityKg = 15.0, // Astronaut EVA suit sample bag capacity
    List<InventoryItem>? items,
  }) : items = items ?? [];

  double get currentMassKg => items.fold(0.0, (acc, item) => acc + item.massKg);
  double get remainingCapacityKg => (maxCapacityKg - currentMassKg).clamp(0.0, maxCapacityKg);
  double get capacityFraction => maxCapacityKg > 0 ? (currentMassKg / maxCapacityKg).clamp(0.0, 1.0) : 0.0;
  bool get isFull => currentMassKg >= maxCapacityKg;

  bool canAddItem(InventoryItem item) {
    return (currentMassKg + item.massKg) <= maxCapacityKg;
  }

  bool addItem(InventoryItem item) {
    if (canAddItem(item)) {
      items.add(item);
      return true;
    }
    return false;
  }

  bool removeItem(String itemId) {
    final idx = items.indexWhere((i) => i.id == itemId);
    if (idx >= 0) {
      items.removeAt(idx);
      return true;
    }
    return false;
  }

  void transferAllToVehicle(List<InventoryItem> vehicleStorage) {
    for (final item in items) {
      item.isSecuredInVehicle = true;
      vehicleStorage.add(item);
    }
    items.clear();
  }

  void clear() => items.clear();

  Map<String, dynamic> toJson() => {
        'maxCapacityKg': maxCapacityKg,
        'items': items.map((i) => i.toJson()).toList(),
      };

  factory InventoryBag.fromJson(Map<String, dynamic> json) => InventoryBag(
        maxCapacityKg: (json['maxCapacityKg'] as num?)?.toDouble() ?? 15.0,
        items: (json['items'] as List<dynamic>?)
            ?.map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

