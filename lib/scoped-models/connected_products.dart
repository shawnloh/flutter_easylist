import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

import '../models/product.dart';
import '../models/user.dart';
import '../models/auth.dart';
import '../models/location_data.dart';

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

  String get selectedProductId => _selProductId;

  int get selectedProductIndex =>
      _products.indexWhere((Product product) => product.id == _selProductId);

  Product get selectedProduct {
    if (_selProductId == null) {
      return null;
    }
    return _products
        .firstWhere((Product product) => product.id == _selProductId);
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  Future<Map<String, dynamic>> uploadImage(File image,
      {String imagePath}) async {
    final mimeTypeData = lookupMimeType(image.path).split('/');
    final imageUploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://us-central1-flutter-product-fe28f.cloudfunctions.net/storeImage'));
    final file = await http.MultipartFile.fromPath('image', image.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
    imageUploadRequest.files.add(file);
    if (imagePath != null) {
      imageUploadRequest.fields['imagePath'] = Uri.encodeComponent(imagePath);
    }

    imageUploadRequest.headers['Authorization'] =
        'Bearer ${_authenticatedUser.token}';

    try {
      final streamResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamResponse);
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Something went wrong');
        print(json.decode(response.body));
        return null;
      }

      final responseData = json.decode(response.body);
      return responseData;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<bool> addProduct(String title, String description, File image,
      double price, LocationData locData) async {
    _isLoading = true;
    notifyListeners();
    final uploadData = await uploadImage(image);
    if (uploadData == null) {
      print('Upload fail');
      return false;
    }

    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'imagePath': uploadData['imagePath'],
      'imageUrl': uploadData['imageUrl'],
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
      'loc_lat': locData.latitude,
      'loc_lng': locData.longitude,
      'loc_address': locData.address,
    };

    try {
      final http.Response response = await http.post(
          'https://flutter-product-fe28f.firebaseio.com/products.json?auth=${_authenticatedUser.token}',
          body: json.encode(productData));
      print(response.body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final Map<String, dynamic> responseData = json.decode(response.body);

      final Product newProduct = Product(
        id: responseData['name'],
        title: title,
        description: description,
        image: uploadData['imageUrl'],
        imagePath: uploadData['imagePath'],
        price: price,
        userEmail: _authenticatedUser.email,
        userId: _authenticatedUser.id,
        location: locData,
      );
      _products.add(newProduct);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(String title, String description, File image,
      double price, LocationData locData) async {
    _isLoading = true;
    notifyListeners();
    String imageUrl = selectedProduct.image;
    String imagePath = selectedProduct.imagePath;
    if (image != null) {
      final uploadData = await uploadImage(image);
      if (uploadData == null) {
        print('Upload fail');
        return false;
      }
      imageUrl = uploadData['imageUrl'];
      imagePath = uploadData['imagePath'];
    }

    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'price': price,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId,
      'loc_address': locData.address,
      'loc_lat': locData.latitude,
      'loc_lng': locData.longitude,
    };
    try {
      await http.put(
          'https://flutter-product-fe28f.firebaseio.com/products/${selectedProduct.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(updateData));

      _isLoading = false;
      final Product updatedProduct = Product(
          id: selectedProduct.id,
          title: title,
          description: description,
          image: imageUrl,
          imagePath: imagePath,
          price: price,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId,
          location: locData);

      _products[selectedProductIndex] = updatedProduct;

      notifyListeners();
      return true;
    } catch (err) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct() {
    _isLoading = true;
    final deletedProductId = selectedProduct.id;

    final int selectedProductIndex =
        _products.indexWhere((Product product) => product.id == _selProductId);
    _products.removeAt(selectedProductIndex);
    _selProductId = null;
    notifyListeners();

    return http
        .delete(
            'https://flutter-product-fe28f.firebaseio.com/products/$deletedProductId.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      _isLoading = false;

      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  void selectProduct(String productId) {
    _selProductId = productId;
    if (productId != null) {
      notifyListeners();
    }
  }

  Future<Null> fetchProducts({onlyForUser = false, clearExisting = false}) {
    _isLoading = true;
    if (clearExisting) {
      _products = [];
    }
    return http
        .get(
            'https://flutter-product-fe28f.firebaseio.com/products.json?auth=${_authenticatedUser.token}')
        .then<Null>((http.Response response) {
      final Map<String, dynamic> productListData = json.decode(response.body);
      final List<Product> fetchedProductList = [];

      if (productListData == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      productListData.forEach((String productId, dynamic productData) {
        final Product product = Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            image: productData['imageUrl'],
            imagePath: productData['imagePath'],
            price: productData['price'],
            location: LocationData(productData['loc_lat'],
                productData['loc_lng'], productData['loc_address']),
            userEmail: productData['userEmail'],
            userId: productData['userId'],
            isFavorite: productData['wishlistUsers'] == null
                ? false
                : (productData['wishlistUsers'] as Map<String, dynamic>)
                    .containsKey(_authenticatedUser.id));
        fetchedProductList.add(product);
      });
      _products = fetchedProductList;
      if (onlyForUser) {
        _products = fetchedProductList.where((Product product) {
          return product.userId == _authenticatedUser.id;
        }).toList();
      }
      _isLoading = false;
      notifyListeners();
      _selProductId = null;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return;
    });
  }

  void toggleProductFavourite() async {
    final bool isCurrentlyFavourite = selectedProduct.isFavorite;
    final bool newFavouriteStatus = !isCurrentlyFavourite;
    final Product updatedProduct = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        location: selectedProduct.location,
        image: selectedProduct.image,
        imagePath: selectedProduct.imagePath,
        isFavorite: newFavouriteStatus,
        userId: selectedProduct.userId,
        userEmail: selectedProduct.userEmail);
    _products[selectedProductIndex] = updatedProduct;
    notifyListeners();

    http.Response response;
    if (newFavouriteStatus) {
      response = await http.put(
        'https://flutter-product-fe28f.firebaseio.com/products/${selectedProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
        body: json.encode(true),
      );
    } else {
      response = await http.delete(
          'https://flutter-product-fe28f.firebaseio.com/products/${selectedProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}');
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Product updatedProduct = Product(
          id: selectedProduct.id,
          title: selectedProduct.title,
          description: selectedProduct.description,
          price: selectedProduct.price,
          location: selectedProduct.location,
          image: selectedProduct.image,
          imagePath: selectedProduct.imagePath,
          isFavorite: !newFavouriteStatus,
          userId: selectedProduct.userId,
          userEmail: selectedProduct.userEmail);
      _products[selectedProductIndex] = updatedProduct;

      notifyListeners();
    }
    _selProductId = null;
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}

mixin UserModel on ConnectedProductsModel {
  Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject<bool>();

  User get user {
    return _authenticatedUser;
  }

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    _isLoading = true;
    notifyListeners();
    Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    };

    http.Response response;
    if (mode == AuthMode.Login) {
      response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyCjttT_uoD6BWCKpUoZPDapz-P9u7HdDWs',
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(authData),
      );
    } else {
      response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyCjttT_uoD6BWCKpUoZPDapz-P9u7HdDWs',
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(authData),
      );
    }

    final Map<String, dynamic> responseData = json.decode(response.body);
    bool success = false;
    String message = 'Something went wrong';

    if (responseData.containsKey('idToken')) {
      success = true;
      message = 'Authentication succeeded!';
      _authenticatedUser = User(
        id: responseData['localId'],
        email: email,
        token: responseData['idToken'],
      );
      setAuthTimeout(int.parse(responseData['expiresIn']));
      _userSubject.add(true);
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', responseData['idToken']);
      prefs.setString('email', email);
      prefs.setString('userId', responseData['localId']);
      prefs.setString('expiryTime', expiryTime.toIso8601String());
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'This email was not found';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'Password is invalid';
    } else if (responseData['error']['message'] == 'USER_DISABLED') {
      message = 'Account is disabled';
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'Email already exists';
    }

    _isLoading = false;
    notifyListeners();

    return {
      'success': success,
      'message': message,
    };
  }

  void autoAuthenticate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    final String expiryTimeString = prefs.getString('expiryTime');
    if (token != null) {
      final DateTime now = DateTime.now();
      final DateTime parsedExpiryTime = DateTime.parse(expiryTimeString);
      if (parsedExpiryTime.isBefore(now)) {
        _authenticatedUser = null;
        notifyListeners();
        return;
      }
      final String userEmail = prefs.getString('email');
      final String userId = prefs.getString('userId');
      final int tokenLifeSpan = parsedExpiryTime.difference(now).inSeconds;
      _userSubject.add(true);
      setAuthTimeout(tokenLifeSpan);
      _authenticatedUser = User(
        id: userId,
        email: userEmail,
        token: token,
      );
      notifyListeners();
    }
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), logout);
  }

  void logout() async {
    _authenticatedUser = null;
    _authTimer.cancel();
    _userSubject.add(false);
    _selProductId = null;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userEmail');
    prefs.remove('userId');
  }
}

mixin ConnectedProductsModel on Model {
  List<Product> _products = [];
  String _selProductId;
  User _authenticatedUser;
  bool _isLoading = false;
}

mixin UtilityModel on ConnectedProductsModel {
  bool get isLoading => _isLoading;
}
