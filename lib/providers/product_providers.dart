import 'dart:convert';

import 'package:flutter/material.dart';
import 'product.dart';
import 'package:http/http.dart' as http;

class ProductProvider with ChangeNotifier {
  List<Product> itemProducts = [];

  final String authToken;
  final String userId;

  ProductProvider({
    required this.authToken,
    required this.userId,
    required this.itemProducts,
  });

  List<Product> get favoritesItems {
    return itemProducts.where((element) => element.isFavorite).toList();
  }

  List<Product> get items {
    return [...itemProducts];
  }

  Product findById(String id) {
    return itemProducts.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetProducts() async{
    var url = 'https://firstflutter-e43f3-default-rtdb.firebaseio.com/products.json?auth=$authToken';

    try{
        final response = await http.get(Uri.parse(url));
        final extractedData = jsonDecode(response.body) as Map<String,dynamic>;

        url = 'https://firstflutter-e43f3-default-rtdb.firebaseio.com/usersFavorites/$userId.json?auth=$authToken'; //todo 6
        final favoriteResponse = await http.get(Uri.parse(url)); //todo 7
        final favoriteData = json.decode(favoriteResponse.body); //todo 8

        final List<Product> _loadedProduct = [];

        if(extractedData == null){
          return;
        }

        extractedData.forEach((key, value) {
        _loadedProduct.add(
          Product(
            id: key,
            title: value['title'],
            description: value['description'],
            price: value['price'],
            imageUrl: value['imageUrl'],
            isFavorite: favoriteData == null ? false : favoriteData[key]??false, //todo 9 finish (jadi get favorite sesuai dengan usernya)
          ),
        );
      });

      itemProducts = _loadedProduct;
      notifyListeners();

    }catch(error){
      throw error;
    }

  }

  Future<void> addProduct(Product product) async {
    final url = 'https://firstflutter-e43f3-default-rtdb.firebaseio.com/products.json?auth=$authToken'; //todo 1

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price, //todo 6 (remove isFavorite)
          },
        ),
      );

      final newProduct = Product(
        id: jsonDecode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      itemProducts.add(newProduct);
      notifyListeners();

    }catch(error){
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = itemProducts.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {

      final url = 'https://firstflutter-e43f3-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken'; //todo 2
      await http.patch(Uri.parse(url),body : json.encode({
        'title' : newProduct.title,
        'description' : newProduct.description,
        'imageUrl' : newProduct.imageUrl,
        'price' : newProduct.price,
      }));

      itemProducts[prodIndex] = newProduct;
      notifyListeners();
    } else {}
  }

  Future<void> deleteProduct(String id) async {
    final url = 'https://firstflutter-e43f3-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken'; //todo 3 (finish)

    final existingProductIndex = itemProducts.indexWhere((element) => element.id == id);
    final existingProduct = itemProducts[existingProductIndex];

    itemProducts.removeAt(existingProductIndex); // item di aplikasi dihapus
    notifyListeners();

    var response = await http.delete(Uri.parse(url)); // melakukan delete pada database

    if (response.statusCode >= 400) { // error maka item di aplikasi dikembalikan
      itemProducts.insert(
        existingProductIndex,
        existingProduct,
      );
      notifyListeners();
      throw Exception();
    }

    existingProduct == null; // tidak error maka item di aplikasi sudah null
  }
}
