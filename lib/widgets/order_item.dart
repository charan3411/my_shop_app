import 'dart:math';

import 'package:flutter/material.dart';

import '../providers/product.dart';

class OrderItem extends StatefulWidget {
  final List<Product> order;

  OrderItem(this.order);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
                '\$${widget.order.map((e) => e.price).toList().reduce((value, element) => value + element)}'),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          if (_expanded)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: min(widget.order.length * 20.0 + 10, 100),
              child: ListView(
                children: widget.order
                    .map((prod) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      prod.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${1}x \$${prod.price}',
                      style:
                      TextStyle(fontSize: 18, color: Colors.grey),
                    )
                  ],
                ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

