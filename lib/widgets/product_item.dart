import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:my_shop_app/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
//import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({super.key, required this.product});

  final Product product;



  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem(
  //  this.id,
  // this.title,
  //  this.imageUrl,
  // );

  @override
  Widget build(BuildContext context) {
    //final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          child:  Hero(
            tag: product.id,
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, _) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black54,
          leading: IconButton(
            onPressed: () {
              product.toggleFavoriteStatus(product.id);


            },
            icon: StreamBuilder<DatabaseEvent>(
                stream: FirebaseDatabase.instance
                    .ref()
                    .child('products')
                    .child(product.id)
                    .onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Product product = Product.fromJson(
                        jsonDecode(jsonEncode(snapshot.data!.snapshot.value)));
                    return Icon(
                      product.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.deepOrange,
                    );
                  }
                  return Container();
                }),
          ),
          title: Text(product.title, textAlign: TextAlign.center),
          trailing: IconButton(
            icon: Icon(
              Icons.add_shopping_cart,
              color: Theme.of(context).secondaryHeaderColor,

            ),
            onPressed: () {
              FirebaseDatabase.instance
                  .ref()
                  .child('shopping carts')
                  .child(FirebaseAuth.instance.currentUser!.uid)
                  .child(product.id)
                  .set(product.toJson());
              cart.addItem(product.id, product.price, product.title);
              ScaffoldMessenger.of(context).removeCurrentSnackBar();

              ScaffoldMessenger.of(context).showSnackBar(

                SnackBar(
                  content: Text('Added item to cart!'),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        FirebaseDatabase.instance
                            .ref()
                            .child('shopping carts')
                            .child(FirebaseAuth.instance.currentUser!.uid)
                            .child(product.id)
                            .remove();
                        cart.removeSingleItem(product.id);

                      }),
                ),
              );

            },

          ),

        ),
      ),
    );
  }
}
