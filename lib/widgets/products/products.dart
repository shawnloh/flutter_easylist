import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'product_card.dart';
import '../../models/product.dart';
import '../../scoped-models/products.dart';

class Products extends StatelessWidget {
  Widget _buildProductList(List<Product> products) {
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
    return ScopedModelDescendant<ProductsModel>(
      builder: (BuildContext context, Widget child, ProductsModel model) {
        return _buildProductList(model.products);
      },
    );
  }
}
