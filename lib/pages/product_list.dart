import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_edit.dart';

class ProductListPage extends StatelessWidget {
  final List<Product> products;
  final Function editProduct;
  final Function deleteProduct;

  ProductListPage(this.products, this.editProduct, this.deleteProduct);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: products.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: Key(products[index].title),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(products[index].image),
                  ),
                  title: Text(products[index].title),
                  subtitle: Text('\$${products[index].price.toString()}'),
                  trailing: _buildEditButton(context, index),
                ),
                Divider(),
              ],
            ),
            background: Container(
              color: Colors.red,
            ),
            onDismissed: (DismissDirection direction) {
              if (direction == DismissDirection.endToStart) {
                deleteProduct(index);
              }
            },
          );
        });
  }

  Widget _buildEditButton(BuildContext context, int index) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return ProductEditPage(
            product: products[index],
            updateProduct: editProduct,
            productIndex: index,
          );
        }));
      },
    );
  }
}
