import 'package:flutter/material.dart';
import 'pages/product.dart';

class Products extends StatelessWidget {
  final List<Map<String, String>> _products;
  final Function(int index) deleteProduct;

  Products(this._products, {this.deleteProduct});

  Function _onDeleteProduct(int index) {
    return () {
      deleteProduct(index);
    };
  }

  Widget _buildProductItem(BuildContext context, Map<String, String> product,
      Function deleteProduct) {
    return Card(
      child: Column(
        children: <Widget>[
          Image.asset(product['image']),
          Text(product['title']),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                child: Text('Details'),
                onPressed: () {
                  var route =
                      MaterialPageRoute<bool>(builder: (BuildContext context) {
                    return ProductPage(product['title'], product['image']);
                  });

                  Navigator.of(context)
                      .push<bool>(route)
                      .then((bool shouldDelete) {
                    if (shouldDelete != null && shouldDelete) {
                      deleteProduct();
                    }
                  });
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

    if (_products.length > 0) {
      productCard = ListView.builder(
        itemCount: _products.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildProductItem(
              context, _products[index], _onDeleteProduct(index));
        },
      );
    }

    return productCard;
  }
}
