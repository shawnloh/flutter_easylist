import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'price_tag.dart';
import 'address_tag.dart';
import '../../scoped-models/main.dart';
import '../ui_elements/title_default.dart';
import '../../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final int productIndex;

  ProductCard(this.product, this.productIndex);

  Widget _buildTitlePriceRow() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TitleDefault(product.title),
          SizedBox(
            width: 8.0,
          ),
          PriceTag(product.price.toString())
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.info),
          color: Colors.blue,
          onPressed: () {
            Navigator.of(context)
                .pushNamed<bool>('/product/${productIndex.toString()}');
          },
        ),
        ScopedModelDescendant<MainModel>(
          builder: (BuildContext context, Widget child, MainModel model) {
            return IconButton(
              icon: Icon(model.allProducts[productIndex].isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border),
              color: Colors.red,
              onPressed: () {
                model.selectProduct(productIndex);
                model.toggleProductFavourite();
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Image.asset(product.image),
          SizedBox(
            height: 20.0,
          ),
          _buildTitlePriceRow(),
          AddressTag('Union Square, San Francisco'),
          Text(product.userEmail),
          _buildActionButtons(context),
        ],
      ),
    );
  }
}
