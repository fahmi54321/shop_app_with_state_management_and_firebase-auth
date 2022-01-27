import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './cart_providers.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class OrderProvider with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    const url = 'https://firstflutter-e43f3-default-rtdb.firebaseio.com/orders.json';
    final response = await http.post(Uri.parse(url),
        body: json.encode({
          'amount': total,
          'dateTime': DateTime.now().toIso8601String(),
          'products': cartProducts
              .map((element) =>
          {
            'id': element.id,
            'title': element.title,
            'quantity': element.quantity,
            'price': element.price,
          })
              .toList()
        }));

    _orders.insert(
      0,
      OrderItem(
        id: jsonDecode(response.body)['name'],
        amount: total,
        products: cartProducts,
        dateTime: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  //todo 1 (next cart_screen)
  Future<void> fetchAndSetOrders() async {
    const url = 'https://firstflutter-e43f3-default-rtdb.firebaseio.com/orders.json';
    final response = await http.get(Uri.parse(url));
    List<OrderItem> _loadedOrders = [];
    var extractedData = jsonDecode(response.body) as Map<String, dynamic>;

    if(extractedData == null){
      return;
    }

    extractedData.forEach((key, value) {
      _loadedOrders.add(OrderItem(
        id: key,
        amount: value['amount'],
        products: (value['products'] as List<dynamic>).map((element) =>
            CartItem(id: element['id'],
              title: element['title'],
              quantity: element['quantity'],
              price: element['price'],),).toList(),
        dateTime: DateTime.parse(value['dateTime'],),));
    });

    _orders = _loadedOrders;
    notifyListeners();

  }
}
