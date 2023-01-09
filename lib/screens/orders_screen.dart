import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:my_shop_app/providers/product.dart';
import 'package:my_shop_app/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final ordersData = Provider.of<Orders>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Yours Orders'),
        ),
        drawer: AppDrawer(),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : StreamBuilder<DatabaseEvent>(
                stream: FirebaseDatabase.instance
                    .ref()
                    .child('orders')
                    .child(FirebaseAuth.instance.currentUser!.uid)
                    .onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Product> ordersData = snapshot.data!.snapshot.children
                        .map((e) =>
                            Product.fromJson(jsonDecode(jsonEncode(e.value))))
                        .toList();
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        Product product = ordersData[index];
                        return ListTile(
                          leading: Image.network(product.imageUrl),
                          title: Text(product.title),
                        );
                      },
                      itemCount: ordersData.length,
                    );
                  }
                  return Container();
                })
        /*ListView(
        itemCount: ordersData.orders.length,
        itemBuilder: (ctx, i) => OrderItem(ordersData.orders[i]),
      )*/

        );
  }
}
