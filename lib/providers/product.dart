import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.isFavorite = false,
  });

//from json
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      price: double.parse(json['price'].toString()),
      isFavorite: json['isFavorite'],
    );
  }

//to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'isFavorite': isFavorite,
    };
  }

  Product copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? imageUrl,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Future<void> toggleFavoriteStatus(String id) async {
    FirebaseDatabase.instance
        .ref()
        .child('products')
        .child(id)
        .get()
        .then((value) {
      print("ID: $id");
      print(jsonDecode(jsonEncode(value.value))[id]);
      Product product = Product.fromJson(jsonDecode(jsonEncode(value.value))[id]);
      Product newProduct = Product(
          id: product.id,
          title: product.title,
          description: product.description,
          imageUrl: product.imageUrl,
          price: product.price,
          isFavorite: !product.isFavorite);
      FirebaseDatabase.instance
          .ref()
          .child('products')
          .child(id)
          .set(newProduct.toJson());
    });
  }
}
