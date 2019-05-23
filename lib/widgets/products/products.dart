import 'package:flutter/material.dart';
import 'product_card.dart';
import '../../models/product.dart';

class Products extends StatelessWidget {
  final List<Product> products;

  Products(this.products);

  Widget _buildProductList() {
    Widget productCard = Container();
    if (products.length > 0) {
      productCard = ListView.builder(
        itemCount: products.length,
        itemBuilder: (BuildContext context, int index) {
          return ProductCard(products[index], index);
        },
      );
    }
    return productCard;
  }

  @override
  Widget build(BuildContext context) {
    return _buildProductList();
  }
}
