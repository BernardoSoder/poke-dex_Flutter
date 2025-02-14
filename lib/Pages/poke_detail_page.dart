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
      appBar: AppBar(
        title: Text(widget.pokemon.name),
        leading: MouseRegion(
          cursor: SystemMouseCursors.click, // Cursor de clique garantido
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop(); // Volta para a tela anterior
            },
            child: const Icon(Icons.arrow_back),
          ),
        ),
      ),
      body: _details == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.network(widget.pokemon.imageUrl,
                        width: 150, height: 150),
                  ),
                  const SizedBox(height: 20),
                  _infoBox("Altura", "${_details!['height']} dm"),
                  _infoBox("Peso", "${_details!['weight']} hg"),
                  _buildAbilities(),
                  _infoBox("Slots", "${_details!['order']}"),
                ],
              ),
            ),
    );
  }

  Widget _infoBox(String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildAbilities() {
    var abilities = _details!['abilities'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Habilidades",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        for (var e in abilities)
          ListTile(
            leading: Image.network(
              "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/${e['ability']['name']}.png",
              width: 40,
              height: 40,
              errorBuilder: (_, __, ___) => const Icon(Icons.warning),
            ),
            title: Text(e['ability']['name']),
          ),
      ],
    );
  }
}
