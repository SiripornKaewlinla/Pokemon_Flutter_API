import 'package:flutter/material.dart';
import 'package:pokemon_app/pokemondetail/pokemondetail_view.dart';
import 'package:pokemon_app/pokemonlist/models/pokemonlist_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemonList extends StatefulWidget {
  const PokemonList({super.key});

  @override
  State<PokemonList> createState() => _PokemonListState();
}

class _PokemonListState extends State<PokemonList> {
  List<PokemonListItem> _pokemonList = [];
  int _offset = 0;
  final int _limit = 20;
  bool _isLoading = false;
  bool _hasMore = true;
  Map<String, Color> _typeColors = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse(
        'https://pokeapi.co/api/v2/pokemon?offset=$_offset&limit=$_limit'));
    if (response.statusCode == 200) {
      final PokemonListResponse data =
          PokemonListResponse.fromJson(jsonDecode(response.body));

      for (var pokemon in data.results) {
        await fetchPokemonType(pokemon);
      }

      setState(() {
        _offset += _limit;
        _isLoading = false;
        _hasMore = data.next != null;
        _pokemonList.addAll(data.results);
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load Pokemon');
    }
  }

  Future<void> fetchPokemonType(PokemonListItem pokemon) async {
    try {
      final response = await http.get(Uri.parse(pokemon.url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String type = data['types'][0]['type']['name'];
        _typeColors[pokemon.name] = getTypeColor(type);
      } else {
        throw Exception('Failed to load Pokémon type');
      }
    } catch (e) {
      print('Error fetching Pokémon type: $e');
    }
  }

  Color getTypeColor(String type) {
    switch (type) {
      case 'fire':
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.yellow.shade700;
      case 'ice':
        return Colors.cyan.shade200;
      case 'fighting':
        return Colors.brown;
      case 'poison':
        return Colors.purple;
      case 'ground':
        return Colors.brown.shade700;
      case 'flying':
        return Colors.blue.shade300;
      case 'psychic':
        return Colors.pink.shade200;
      case 'bug':
        return Colors.green.shade300;
      case 'rock':
        return Colors.brown.shade600;
      case 'ghost':
        return Colors.deepPurple.shade300;
      case 'dragon':
        return Colors.blue.shade800;
      case 'dark':
        return Colors.black87;
      case 'steel':
        return Colors.blueGrey.shade800;
      case 'fairy':
        return Colors.pink.shade300;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!_isLoading &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          loadData();
        }
        return true;
      },
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200, // ความกว้างสูงสุดของแต่ละบ็อกซ์
          childAspectRatio: 1.0, // ทำให้ Box เป็นสี่เหลี่ยมจัตุรัส
          crossAxisSpacing: 10, // ระยะห่างระหว่างบล็อกในแนวนอน
          mainAxisSpacing: 10, // ระยะห่างระหว่างบล็อกในแนวตั้ง
        ),
        itemCount: _pokemonList.length,
        itemBuilder: (context, index) {
          final PokemonListItem pokemon = _pokemonList[index];
          final Color backgroundColor =
              _typeColors[pokemon.name] ?? Colors.grey;

          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PokemondetailView(
                  pokemonListItem: pokemon,
                ),
              ),
            ),
            child: Card(
              color: backgroundColor, // ตั้งค่าพื้นหลังตามประเภท
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // มุมโค้งมน
              ),
              elevation: 6, // เงาที่ทำให้การ์ดลอยขึ้น
              shadowColor: Colors.black.withOpacity(0.3), // สีของเงา
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10), // ทำมุมให้โค้งมน
                    child: Image.network(
                      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${index + 1}.png',
                      width: 100, // ปรับขนาดรูปให้พอดี
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.error,
                          size: 80,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pokemon.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // เปลี่ยนชื่อเป็นสีขาว
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
