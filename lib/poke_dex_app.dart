import 'package:flutter/material.dart';
import 'package:pokedex/Pages/poke_home_page.dart';

class PokeDexApp extends StatelessWidget {
  const PokeDexApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poke Dex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PokeHomePage(),
    );
  }
}
