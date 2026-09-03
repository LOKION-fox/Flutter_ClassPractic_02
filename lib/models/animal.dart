class Animal {
  final int id;
  final String name;
  final String species;
  final String breed;
  final int ageMonths;
  final String sex;
  final String country;
  final double price;
  final String description;
  final DateTime? deletedAt;

  const Animal({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.ageMonths,
    required this.sex,
    required this.country,
    required this.price,
    required this.description,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Animal copyWith({
    String? name,
    String? species,
    String? breed,
    int? ageMonths,
    String? sex,
    String? country,
    double? price,
    String? description,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Animal(
      id: id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      ageMonths: ageMonths ?? this.ageMonths,
      sex: sex ?? this.sex,
      country: country ?? this.country,
      price: price ?? this.price,
      description: description ?? this.description,
      deletedAt: clearDeletedAt
          ? null
          : (deletedAt ?? this.deletedAt),
    );
  }
}