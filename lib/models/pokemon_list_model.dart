import 'package:pokedex/models/pokemon_model.dart';

class PokemonListModel {
  final int count;
  final String next;
  final String? previous;
  final List<dynamic> results;
  final String url;

  PokemonListModel(
      {required this.count,
      required this.next,
      required this.previous,
      required this.results,
      required this.url});

  factory PokemonListModel.fromMap(Map<String, dynamic> map) {
    var resultsList = map['results'] as List;

    return PokemonListModel(
        count: map['count'] as int,
        next: map['next'] as String,
        previous: map['previous'] as String?,
        results: map['results'] as List<dynamic>,
        url: map['results'].forEach());
  }
}
