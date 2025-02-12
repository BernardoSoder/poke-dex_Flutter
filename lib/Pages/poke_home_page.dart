import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/pokemon_model.dart';

class PokeHomePage extends StatelessWidget {
  const PokeHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lista de Pokémon")),
      body: _buildBody(),
    );
  }

  Future<List<Pokemon>> _getPokemons() async {
    final dio = Dio();
    final response =
        await dio.get('https://pokeapi.co/api/v2/pokemon?limit=100');
    List results = response.data['results'];
    return results.map((e) => Pokemon.fromMap(e)).toList();
  }

  Widget _buildBody() {
    return FutureBuilder(
      future: _getPokemons(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var lista = snapshot.data ?? [];
          if (lista.isEmpty) {
            return Center(child: Text("Nenhum pokemon encontrado!"));
          }
          return ListView.builder(
            itemCount: lista.length,
            itemBuilder: (context, index) {
              var pokemon = lista[index];
              return ListTile(
                leading: Image.network(pokemon.imageUrl, width: 40, height: 40),
                title: Text(pokemon.name, style: TextStyle(fontSize: 18)),
                subtitle: Text(pokemon.url),
              );
            },
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
