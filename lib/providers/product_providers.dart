import 'dart:convert';

import 'package:flutter/material.dart';
import 'product.dart';
import 'package:http/http.dart' as http;

class ProductProvider with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  List<Product> get favoritesItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  List<Product> get items {
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetProducts() async{
    const url = 'https://firstflutter-e43f3-default-rtdb.firebaseio.com/products.json';

    try{
        final response = await http.get(Uri.parse(url));
        final extractedData = jsonDecode(response.body) as Map<String,dynamic>;

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
            isFavorite: value['isFavorite'],
          ),
        );
      });

      _items = _loadedProduct;
      notifyListeners();

    }catch(error){
      throw error;
    }

  }

  Future<void> addProduct(Product product) async {
    const url = 'https://firstflutter-e43f3-default-rtdb.firebaseio.com/products.json';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'isFavorite': product.isFavorite,
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
      _items.add(newProduct);
      notifyListeners();

    }catch(error){
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {

      final url = 'https://firstflutter-e43f3-default-rtdb.firebaseio.com/products/$id.json';
      await http.patch(Uri.parse(url),body : json.encode({
        'title' : newProduct.title,
        'description' : newProduct.description,
        'imageUrl' : newProduct.imageUrl,
        'price' : newProduct.price,
      }));

      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {}
  }

  //todo 1 (next user_product_item_widget)
  Future<void> deleteProduct(String id) async {
    final url = 'https://firstflutter-e43f3-default-rtdb.firebaseio.com/products/$id.json';

    final existingProductIndex = _items.indexWhere((element) => element.id == id);
    final existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex); // item di aplikasi dihapus
    notifyListeners();

    var response = await http.delete(Uri.parse(url)); // melakukan delete pada database

    if (response.statusCode >= 400) { // error maka item di aplikasi dikembalikan
      _items.insert(
        existingProductIndex,
        existingProduct,
      );
      notifyListeners();
      throw Exception();
    }

    existingProduct == null; // tidak error maka item di aplikasi sudah null
  }
}
