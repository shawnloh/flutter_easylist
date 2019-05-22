import 'package:flutter/material.dart';
import '../product_manager.dart';
import 'products_admin.dart';

class ProductsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            AppBar(
              automaticallyImplyLeading: false,
              title: Text('Choose'),
            ),
            ListTile(
              title: Text('Manage Product'),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProductsAdminPage()));
              },
            )
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Hello world'),
      ),
      body: ProductManager(),
    );
  }
}
