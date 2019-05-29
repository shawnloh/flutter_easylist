import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'price_tag.dart';
import 'address_tag.dart';
import '../../scoped-models/main.dart';
import '../ui_elements/title_default.dart';
import '../../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  ProductCard(this.product);

  Widget _buildTitlePriceRow() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: TitleDefault(product.title),
          ),
          SizedBox(
            width: 8.0,
          ),
          Flexible(
            child: PriceTag(product.price.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ButtonBar(
        alignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.info),
            color: Colors.blue,
            onPressed: () {
              model.selectProduct(product.id);
              Navigator.of(context)
                  .pushNamed<bool>('/product/${product.id}')
                  .then((_) => model.selectProduct(null));
            },
          ),
          IconButton(
            icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border),
            color: Colors.red,
            onPressed: () {
              model.selectProduct(product.id.toString());
              model.toggleProductFavourite();
              model.selectProduct(null);
            },
          )
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Hero(
            tag: product.id,
            child: FadeInImage(
              image: NetworkImage(product.image),
              height: 300.0,
              fit: BoxFit.cover,
              placeholder: AssetImage('assets/food.jpg'),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          _buildTitlePriceRow(),
          SizedBox(
            height: 10.0,
          ),
          AddressTag(product.location.address),
          Text(product.userEmail),
          _buildActionButtons(context),
        ],
      ),
    );
  }
}
