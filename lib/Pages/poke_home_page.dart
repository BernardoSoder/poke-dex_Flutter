import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/Pages/poke_detail_page.dart';
import 'package:pokedex/models/pokemon_summary.dart';

class PokeHomePage extends StatefulWidget {
  const PokeHomePage({super.key});

  @override
  State<PokeHomePage> createState() => _PokeHomePageState();
}

class _PokeHomePageState extends State<PokeHomePage> {
  bool isCarregando = true;
  List<Pokemon> listaDePokemon = [];

  @override
  void initState() {
    super.initState();
    _carregaDados();
  }

  Future<void> _carregaDados() async {
    try {
      final dio = Dio();
      final response =
          await dio.get('https://pokeapi.co/api/v2/pokemon?limit=20');

      setState(() {
        listaDePokemon =
            (response.data['results'] as List).asMap().entries.map((entry) {
          final index = entry.key + 1;
          final data = entry.value as Map<String, dynamic>;
          return Pokemon(
            name: data['name'],
            detailsUrl: data['url'],
            imageUrl:
                "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$index.png",
          );
        }).toList();

        isCarregando = false;
      });
    } catch (e) {
      print("Erro ao carregar Pokémon: $e");
      setState(() {
        isCarregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Lista de Pokémon"),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isCarregando) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        itemCount: listaDePokemon.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (context, index) {
          final pokemon = listaDePokemon[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PokeDetailPage(pokemon: pokemon),
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orangeAccent.shade100,
                      Colors.yellowAccent.shade100
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: pokemon.name,
                      child: Image.network(
                        pokemon.imageUrl,
                        width: 80,
                        height: 80,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      pokemon.name.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
