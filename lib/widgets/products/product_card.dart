import 'package:flutter/material.dart';
import 'price_tag.dart';
import '../ui_elements/title_default.dart';
import 'address_tag.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final int productIndex;

  ProductCard(this.product, this.productIndex);

  Widget _buildTitlePriceRow() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TitleDefault(product['title']),
          SizedBox(
            width: 8.0,
          ),
          PriceTag(product['price'].toString())
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
        IconButton(
          icon: Icon(Icons.favorite_border),
          color: Colors.red,
          onPressed: () {
            Navigator.of(context)
                .pushNamed<bool>('/product/${productIndex.toString()}');
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
          Image.asset(product['image']),
          SizedBox(
            height: 20.0,
          ),
          _buildTitlePriceRow(),
          AddressTag('Union Square, San Francisco'),
          _buildActionButtons(context),
        ],
      ),
    );
  }
}
