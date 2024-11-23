import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_food.dart';
import 'update_food.dart';  // Import de la page de modification

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  // URL de l'API Flask pour récupérer la liste des aliments
  final String apiUrl = 'http://192.168.1.24:5000/allfoods';

  // Méthode pour récupérer la liste des aliments
  Future<List<Map<String, dynamic>>> fetchFoodList() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List foods = data['foods'];
        return foods.map((food) => food as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load foods');
      }
    } catch (e) {
      throw Exception('Failed to load foods: $e');
    }
  }

  // Méthode pour supprimer un aliment
  Future<void> deleteFood(int foodId) async {
    final String deleteUrl = 'http://192.168.1.24:5000/deletefood/$foodId';
    try {
      final response = await http.delete(Uri.parse(deleteUrl));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Food deleted successfully')),
        );
      } else {
        throw Exception('Failed to delete food');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Column(
          children: [
            // Titre Home Admin
            Text(
              "Home Admin",
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 30.0),  // Espacement avant le bouton "Add Food Items"

            // Bouton Add Food Items
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddFood()),
                );
              },
              child: Material(
                elevation: 10.0,
                borderRadius: BorderRadius.circular(10),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Image.asset(
                            "images/food.jpg",
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 30.0),
                        Text(
                          "Add Food Items",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30.0),  // Espacement avant le titre de la liste

            // Titre Liste Foods
            Text(
              "Liste Foods",
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20.0),  // Espacement avant la liste

            // Affichage des aliments
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchFoodList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No food items available.'));
                  } else {
                    // Afficher la liste des aliments
                    List<Map<String, dynamic>> foods = snapshot.data!;

                    return ListView.builder(
                      itemCount: foods.length,
                      itemBuilder: (context, index) {
                        var food = foods[index];

                        return Dismissible(
                          key: Key(food['id'].toString()),  // Identifiant unique pour chaque item
                          direction: DismissDirection.endToStart,  // Glissement vers la gauche
                          onDismissed: (direction) async {
                            // Appel de la méthode pour supprimer l'aliment
                            await deleteFood(food['id']);
                            // Rafraîchir la liste après suppression
                            setState(() {});
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          child: Card(
                            elevation: 5.0,
                            margin: EdgeInsets.symmetric(vertical: 10.0),
                            child: ListTile(
                              leading: Image.network(
                                food['image_url'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              title: Text(food['name']),
                              subtitle: Text('Category: ${food['category']}'),
                              trailing: Text('${food['price']} DNT'),
                              // Ajouter un bouton pour modifier l'aliment
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdateFood(
                                      foodId: food['id'],
                                      name: food['name'],
                                      description: food['description'],
                                      price: food['price'],
                                      category: food['category'],
                                      imageUrl: food['image_url'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
