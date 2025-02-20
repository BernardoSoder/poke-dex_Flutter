import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/models/pokemon_summary.dart';

class PokeDetailPage extends StatefulWidget {
  final Pokemon pokemon;
  const PokeDetailPage({super.key, required this.pokemon});

  @override
  State<PokeDetailPage> createState() => _PokeDetailPageState();
}

class _PokeDetailPageState extends State<PokeDetailPage> {
  Map<String, dynamic>? _details;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final dio = Dio();
    final response = await dio.get(widget.pokemon.detailsUrl);
    setState(() {
      _details = response.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.pokemon.name.toUpperCase(),
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: _getTypeColor(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _details == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.network(
                    widget.pokemon.imageUrl,
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 20),
                  _infoBox(Icons.height, "Altura", "${_details!['height']} dm"),
                  _infoBox(Icons.fitness_center, "Peso",
                      "${_details!['weight']} hg"),
                  _infoBox(Icons.category, "Tipo", _getTypes()),
                  _buildAbilities(),
                  _buildMoves(),
                  _buildStats(),
                ],
              ),
            ),
    );
  }

  Color _getTypeColor() {
    if (_details == null || _details!['types'] == null) {
      return Colors.grey;
    }

    var types = _details!['types'] as List;
    if (types.isEmpty) return Colors.grey;

    String type = types[0]['type']['name'];
    switch (type) {
      case 'fire':
        return Colors.orange;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.yellow.shade700;
      case 'psychic':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  Widget _infoBox(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _getTypeColor().withOpacity(0.2),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Icon(icon, color: _getTypeColor(), size: 28),
          const SizedBox(width: 12),
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Spacer(),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _getTypes() {
    var types = _details!['types'] as List;
    return types.map((e) => e['type']['name']).join(', ');
  }

  Widget _buildAbilities() {
    var abilities = _details!['abilities'] as List;
    return _infoBox(Icons.flash_on, "Habilidades",
        abilities.map((e) => e['ability']['name']).join(', '));
  }

  Widget _buildMoves() {
    var moves = _details!['moves'] as List;
    return Column(
      children: [
        const Text("Movimentos",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: moves
              .take(5)
              .map((e) => Chip(
                    avatar:
                        Icon(Icons.sports_martial_arts, color: _getTypeColor()),
                    label: Text(e['move']['name']),
                    backgroundColor: _getTypeColor().withOpacity(0.2),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildStats() {
    var stats = _details!['stats'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Status Básicos",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...stats
            .map((e) => _statBar(e['stat']['name'], e['base_stat']))
            .toList(),
      ],
    );
  }

  Widget _statBar(String stat, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(stat,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 12,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(_getTypeColor()),
          ),
        ),
      ],
    );
  }
}
