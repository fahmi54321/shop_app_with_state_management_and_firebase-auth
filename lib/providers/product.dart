import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite; // status field dinamis

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue){
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token, String userId) async { //todo 1
    final oldStatus = isFavorite;

    isFavorite = !isFavorite;
    notifyListeners();

    final url = 'https://firstflutter-e43f3-default-rtdb.firebaseio.com/usersFavorites/$userId/$id.json?auth=$token'; //todo 2 (next product_item)

    try {
      var response = await http.put(
        Uri.parse(url),
        body: json.encode(
            isFavorite, //todo 3
        ),
      );

      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (error) {
      _setFavValue(oldStatus);
    }
  }
}
