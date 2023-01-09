import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //  id: 'p1',
    //  title: 'Red Shirt',
    // description: 'A red shirt - it is pretty red!',
    // price: 29.99,
    // imageUrl:
    //     'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //  id: 'p2',
    // title: 'Trousers',
    // description: 'A nice pair of trousers.',
    // price: 59.99,
    // imageUrl:
    //    'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    //),
    // Product(
    //  id: 'p3',
    //  title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //  imageUrl:
    //     'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    //),
    //Product(
    // id: 'p4',
    // title: 'A Pan',
    // description: 'Prepare any meal you want.',
    // price: 49.99,
    // imageUrl:
    //     'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    //),
  ];


  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product? findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
    // if (_items.isNotEmpty) {
    //  return _items.firstWhere((prod) => prod.id == id);
    // }
    // return null;
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    FirebaseDatabase.instance.ref().child('products').get().then((value) {
      _items.clear();
      for (var element in value.children) {
        Product product =
            Product.fromJson(jsonDecode(jsonEncode(element.value)));
        _items.add(product);
      }
    });

    /*const url =
        'https://shop-app-78398-default-rtdb.firebaseio.com/products.json';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          isFavorite: prodData['isFavorite'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }*/
  }

  Future<void> addProduct(Product product) async {
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    final Product newProduct = Product(
      id: id,
      title: product.title,
      description: product.description,
      imageUrl: product.imageUrl,
      price: product.price,
      isFavorite: false,


    );

    FirebaseDatabase.instance
        .ref()
        .child('products')
        .child(id)
        .set(newProduct.toJson());

    /*const  url = 'https://shop-app-78398-default-rtdb.firebaseio.com/products.json';
    try {
      final response = await http.post(Uri.parse(url), body: json.encode({

        'title': product.title,
        'price': product.price,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'isFavorite': product.isFavorite,
      }),
      );
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
      );
      _items.add(newProduct);
      notifyListeners();

    } catch (error) {
      print(error);
      throw(error);
    }*/
  }

  //uuid.v4

  Future<void> updateProduct(String id, Product newProduct) async {
    FirebaseDatabase.instance
        .ref()
        .child('products')
        .child(id)
        .set(newProduct.toJson());
    notifyListeners();
  }
}

Future<void> deleteProduct(String id) async {
  FirebaseDatabase.instance.ref().child('Products').child(id).remove();
}
