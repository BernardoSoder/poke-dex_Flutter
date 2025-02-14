class PokemonDetails {
  final String name;
  final int height;
  final int weight;
  final List<Ability> abilities;
  final String imageUrl;

  PokemonDetails({
    required this.name,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.imageUrl,
  });

  factory PokemonDetails.fromMap(Map<String, dynamic> map) {
    return PokemonDetails(
      name: map['name'],
      height: map['height'],
      weight: map['weight'],
      imageUrl: map['sprites']['front_default'],
      abilities: (map['abilities'] as List)
          .map((e) => Ability.fromMap(e['ability']))
          .toList(),
    );
  }
}

class Ability {
  final String name;
  final String url;

  Ability({required this.name, required this.url});

  factory Ability.fromMap(Map<String, dynamic> map) {
    return Ability(
      name: map['name'],
      url: map['url'],
    );
  }
}
