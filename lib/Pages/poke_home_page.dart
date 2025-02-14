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
          final index = entry.key + 1; // ID correto do Pokémon
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
      appBar: AppBar(title: const Text("Lista de Pokémon")),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isCarregando) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: listaDePokemon.length,
      itemBuilder: (context, index) {
        final pokemon = listaDePokemon[index];

        return MouseRegion(
          cursor: SystemMouseCursors
              .click, // Garante que o cursor muda para a mãozinha
          child: ListTile(
            title: Text(pokemon.name),
            leading: Image.network(pokemon.imageUrl, width: 50, height: 50),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PokeDetailPage(pokemon: pokemon),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
