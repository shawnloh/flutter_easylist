import 'package:flutter/material.dart';

class Products extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  Products(this.products);

  Widget _buildProductItem(BuildContext context, int index) {
    return Card(
      child: Column(
        children: <Widget>[
          Image.asset(products[index]['image']),
          Text(products[index]['title']),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                child: Text('Details'),
                onPressed: () {
                  Navigator.of(context).pushNamed<bool>('/product/$index');
                },
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget productCard = Center(
      child: Text('No item, add one now'),
    );

    if (products.length > 0) {
      productCard = ListView.builder(
        itemCount: products.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildProductItem(context, index);
        },
      );
    }

    return productCard;
  }
}
