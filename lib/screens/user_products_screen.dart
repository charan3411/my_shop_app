import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import './edit_product_screen.dart';
import '../providers/product.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Products'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return EditProductScreen();
              }));
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: StreamBuilder<DatabaseEvent>(
            stream: FirebaseDatabase.instance.ref().child('products').onValue,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Product> productsData = snapshot.data!.snapshot.children
                    .map((e) =>
                        Product.fromJson(jsonDecode(jsonEncode(e.value))))
                    .toList();
                return ListView.builder(
                  itemCount: productsData.length,
                  itemBuilder: (_, i) => Column(
                    children: [
                      UserProductItem(
                        productsData[i].id,
                        productsData[i].title,
                        productsData[i].imageUrl,
                      ),
                      Divider(),
                    ],
                  ),
                );
              }
              return Container();
            }),
      ),
      drawer: AppDrawer(),
    );
  }
}
