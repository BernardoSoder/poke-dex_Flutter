import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/models/pokemon_summary.dart';

class PokeDetailPage extends StatefulWidget {
  final Pokemon pokemon;
  const PokeDetailPage({Key? key, required this.pokemon}) : super(key: key);

  @override
  State<PokeDetailPage> createState() => _PokeDetailPageState();
}

class _PokeDetailPageState extends State<PokeDetailPage> {
  Map<String, dynamic>? _details;
  List<Map<String, dynamic>> _evolutions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final dio = Dio();
    final response = await dio.get(widget.pokemon.detailsUrl);
    _details = response.data;
    await _fetchEvolutions();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchEvolutions() async {
    if (_details == null) return;
    if (_details!['species'] == null) return;
    final dio = Dio();
    final speciesResponse = await dio.get(_details!['species']['url']);
    final evoUrl = speciesResponse.data['evolution_chain']['url'];
    final evoResponse = await dio.get(evoUrl);
    List<Map<String, dynamic>> chainList = [];
    var chain = evoResponse.data['chain'];
    while (chain != null) {
      chainList.add({
        'name': chain['species']['name'],
        'imageUrl': _buildArtworkUrl(chain['species']['url'])
      });
      if (chain['evolves_to'].isNotEmpty) {
        chain = chain['evolves_to'][0];
      } else {
        chain = null;
      }
    }
    _evolutions = chainList;
  }

  String _buildArtworkUrl(String url) {
    final parts = url.split('/');
    final id = parts[parts.length - 2];
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
  }

  Color _getTypeColor() {
    if (_details == null) return Colors.grey;
    if (_details!['types'] == null) return Colors.grey;
    final types = _details!['types'] as List;
    if (types.isEmpty) return Colors.grey;
    final typeName = types[0]['type']['name'];
    switch (typeName) {
      case 'fire':
        return Colors.orange;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.yellow;
      case 'psychic':
        return Colors.pink;
      case 'ice':
        return Colors.cyan;
      case 'dragon':
        return Colors.indigo;
      case 'dark':
        return Colors.black54;
      case 'fairy':
        return Colors.pinkAccent;
      case 'poison':
        return Colors.purple;
      case 'bug':
        return Colors.lightGreen;
      case 'fighting':
        return Colors.red;
      case 'ghost':
        return Colors.deepPurple;
      case 'rock':
        return Colors.brown;
      case 'ground':
        return Colors.brown;
      case 'steel':
        return Colors.blueGrey;
      case 'flying':
        return Colors.indigoAccent;
      default:
        return Colors.grey;
    }
  }

  Icon _getTypeIcon(String typeName) {
    switch (typeName) {
      case 'water':
        return const Icon(Icons.water_drop, color: Colors.white);
      case 'fire':
        return const Icon(Icons.local_fire_department, color: Colors.white);
      case 'grass':
        return const Icon(Icons.eco, color: Colors.white);
      case 'electric':
        return const Icon(Icons.flash_on, color: Colors.white);
      default:
        return const Icon(Icons.star, color: Colors.white);
    }
  }

  Color _getStatColor(int value) {
    if (value < 20) return Colors.red;
    if (value < 60) return Colors.orange;
    if (value < 90) return Colors.yellow;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  backgroundColor: _getTypeColor(),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                      widget.pokemon.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    background: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(color: _getTypeColor()),
                        Positioned(
                          bottom: 20,
                          child: Image.network(
                            widget.pokemon.imageUrl,
                            width: 180,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildTypeRow(),
                        const SizedBox(height: 16),
                        _buildInfoRow(),
                        const SizedBox(height: 16),
                        _buildStats(),
                        const SizedBox(height: 16),
                        _buildAbilities(),
                        const SizedBox(height: 16),
                        _buildMoves(),
                        const SizedBox(height: 16),
                        _buildEvolutions(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTypeRow() {
    if (_details == null) return const SizedBox.shrink();
    if (_details!['types'] == null) return const SizedBox.shrink();
    final types = _details!['types'] as List;
    return Wrap(
      spacing: 8,
      alignment: WrapAlignment.center,
      children: types.map((typeObj) {
        final typeName = typeObj['type']['name'] as String;
        return Chip(
          avatar: _getTypeIcon(typeName),
          label: Text(
            typeName.toUpperCase(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: _getTypeColor(),
        );
      }).toList(),
    );
  }

  Widget _buildInfoRow() {
    final weightRaw = _details?['weight'] ?? 0;
    final heightRaw = _details?['height'] ?? 0;
    final weight = (weightRaw / 10).toStringAsFixed(1);
    final height = (heightRaw / 10).toStringAsFixed(1);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _infoColumn('Peso', '$weight kg'),
            _infoColumn('Altura', '$height m'),
          ],
        ),
      ),
    );
  }

  Widget _infoColumn(String title, String value) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildStats() {
    if (_details == null) return const SizedBox.shrink();
    if (_details!['stats'] == null) return const SizedBox.shrink();
    final stats = _details!['stats'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Status Básicos',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...stats.map((statObj) {
          final baseStat = statObj['base_stat'] as int;
          final statName = statObj['stat']['name'].toString().toUpperCase();
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(statName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: baseStat / 100,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade300,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(_getStatColor(baseStat)),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAbilities() {
    if (_details == null) return const SizedBox.shrink();
    if (_details!['abilities'] == null) return const SizedBox.shrink();
    final abilities = _details!['abilities'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Habilidades',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          alignment: WrapAlignment.center,
          children: abilities.map((abilityObj) {
            final abilityName =
                (abilityObj['ability']['name'] as String).toUpperCase();
            return Chip(
              label: Text(abilityName,
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: _getTypeColor(),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMoves() {
    if (_details == null) return const SizedBox.shrink();
    if (_details!['moves'] == null) return const SizedBox.shrink();
    final moves = _details!['moves'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Movimentos',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          alignment: WrapAlignment.center,
          children: moves.take(15).map((moveObj) {
            final moveName = (moveObj['move']['name'] as String).toUpperCase();
            return Chip(
              label:
                  Text(moveName, style: const TextStyle(color: Colors.white)),
              backgroundColor: _getTypeColor().withOpacity(0.8),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEvolutions() {
    if (_evolutions.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Evoluções',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _evolutions.map((e) {
              final evoName = (e['name'] as String).toUpperCase();
              final evoUrl = e['imageUrl'] as String;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Image.network(evoUrl, width: 80, height: 80),
                    ),
                    const SizedBox(height: 5),
                    Text(evoName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
