import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:my_shop_app/providers/product.dart';

import '../widgets/cart_item.dart' as ci;

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  const Spacer(),
                  Chip(
                    label: StreamBuilder<DatabaseEvent>(
                        stream: FirebaseDatabase.instance
                            .ref()
                            .child('shopping carts')
                            .child(FirebaseAuth.instance.currentUser!.uid)
                            .onValue,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<Product> cart = snapshot
                                .data!.snapshot.children
                                .map((e) => Product.fromJson(
                                jsonDecode(jsonEncode(e.value))))
                                .toList();

                            return Text(
                              '\$${cart.isNotEmpty ? cart.map((e) => e.price).toList().reduce((value, element) => value + element).toStringAsFixed(2) : '0.0'}',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .primaryTextTheme
                                    .headline6
                                    ?.color,
                              ),
                            );
                          }
                          return Container();
                        }),
                    backgroundColor: Colors.purple,
                  ),
                  const OrderButton(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
                stream: FirebaseDatabase.instance
                    .ref()
                    .child('shopping carts')
                    .child(FirebaseAuth.instance.currentUser!.uid)
                    .onValue,

                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Product> cart = snapshot.data!.snapshot.children
                        .map((e) =>
                        Product.fromJson(jsonDecode(jsonEncode(e.value))))
                        .toList();

                  //  return ListView.builder(
                    //  itemCount: cart.length,
                     // itemBuilder: (ctx, i) => ci.CartItem(
                      //  product: cart[i],

                     // ),
                    //);
                  }
                  return Container();
                }),
          )
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
  }) : super(key: key);

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text('ORDER NOW'),
      onPressed: () {
        FirebaseDatabase.instance
            .ref()
            .child('shopping carts')
            .child(FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((value) {
          List<Product> shoppingCartProducts = value.children
              .map((e) => Product.fromJson(jsonDecode(jsonEncode(e.value))))
              .toList();


          shoppingCartProducts.forEach((element) {
            FirebaseDatabase.instance
                .ref()
                .child('orders')
                .child(FirebaseAuth.instance.currentUser!.uid)
                .child(element.id)
                .set(element.toJson()).then((value) {
              FirebaseDatabase.instance
                  .ref()
                  .child('shopping carts')
                  .child(FirebaseAuth.instance.currentUser!.uid).remove();


            });
          });

          return Container();
        });
      },
    );

  }
}

