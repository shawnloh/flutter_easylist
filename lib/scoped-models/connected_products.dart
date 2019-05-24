import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';
import '../models/user.dart';

mixin ProductsModel on ConnectedProductsModel {
  bool _showFavorites = false;

  List<Product> get allProducts => List.from(_products);

  List<Product> get displayedProducts {
    if (_showFavorites) {
      return List.from(_products.where((Product product) {
        return product.isFavorite;
      }).toList());
    }
    return List.from(_products);
  }

  int get selectedProductIndex => _selProductIndex;

  Product get selectedProduct =>
      selectedProductIndex == null ? null : _products[selectedProductIndex];

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  Future<Null> updateProduct(
      String title, String description, String image, double price) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'image':
          'https://www.capetownetc.com/wp-content/uploads/2018/06/Choc_1.jpeg',
      'price': price,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId,
    };
    return http
        .put(
            'https://flutter-product-fe28f.firebaseio.com/products/${selectedProduct.id}.json',
            body: json.encode(updateData))
        .then((http.Response response) {
      _isLoading = false;
      final Product updatedProduct = Product(
        id: selectedProduct.id,
        title: title,
        description: description,
        image: image,
        price: price,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
      );
      _products[selectedProductIndex] = updatedProduct;

      notifyListeners();
    });
  }

  void deleteProduct() {
    _isLoading = true;
    final deletedProductId = selectedProduct.id;
    _products.removeAt(selectedProductIndex);
    _selProductIndex = null;
    notifyListeners();
    http
        .delete(
            'https://flutter-product-fe28f.firebaseio.com/products/${deletedProductId}.json')
        .then((http.Response response) {
      _isLoading = false;

      notifyListeners();
    });
  }

  void selectProduct(int index) {
    _selProductIndex = index;
//    if (index != null) {
//    }
    notifyListeners();
  }

  void fetchProducts() async {
    _isLoading = true;
    try {
      http.Response response = await http
          .get('https://flutter-product-fe28f.firebaseio.com/products.json');

      final Map<String, dynamic> productListData = json.decode(response.body);
      final List<Product> fetchedProductList = [];
      if (productListData != null) {
        productListData.forEach((String productId, dynamic productData) {
          final Product product = Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            image: productData['image'],
            price: productData['price'],
            userEmail: productData['userEmail'],
            userId: productData['userId'],
          );
          fetchedProductList.add(product);
        });
      }

      _products = fetchedProductList;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  void toggleProductFavourite() {
    final bool isCurrentlyFavourite = selectedProduct.isFavorite;
    final bool newFavouriteStatus = !isCurrentlyFavourite;
    final Product updatedProduct = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        isFavorite: newFavouriteStatus,
        userId: _authenticatedUser.id,
        userEmail: _authenticatedUser.email);
    _products[selectedProductIndex] = updatedProduct;

    notifyListeners();
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
    _selProductIndex = null;
  }
}

mixin UserModel on ConnectedProductsModel {
  void login(String email, String password) {
    _authenticatedUser = User(
      id: 'dasdjasnda',
      email: email,
      password: password,
    );
  }
}

mixin ConnectedProductsModel on Model {
  List<Product> _products = [];
  int _selProductIndex;
  User _authenticatedUser;
  bool _isLoading = false;

  Future<Null> addProduct(
      String title, String description, String image, double price) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image':
          'https://www.capetownetc.com/wp-content/uploads/2018/06/Choc_1.jpeg',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
    };

    try {
      http.Response response = await http.post(
          'https://flutter-product-fe28f.firebaseio.com/products.json',
          body: json.encode(productData));

      final Map<String, dynamic> responseData = json.decode(response.body);

      final Product newProduct = Product(
          id: responseData['name'],
          title: title,
          description: description,
          image: image,
          price: price,
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.id);
      _products.add(newProduct);
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (error) {
      print(error);
    }
    ;
  }
}

mixin UtilityModel on ConnectedProductsModel {
  bool get isLoading => _isLoading;
}
