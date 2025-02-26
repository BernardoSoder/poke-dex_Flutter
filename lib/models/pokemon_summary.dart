class Pokemon {
  final String name;
  final String imageUrl;
  final String detailsUrl;

  Pokemon({
    required this.name,
    required this.imageUrl,
    required this.detailsUrl,
  });

  factory Pokemon.fromMap(Map<String, dynamic> map) {
    return Pokemon(
      name: map['name'],
      imageUrl:
          "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${_getIdFromUrl(map['url'])}.png",
      detailsUrl: map['url'],
    );
  }

  static String _getIdFromUrl(String url) {
    final segments = url.split('/');
    return segments[segments.length - 2];
  }
}
