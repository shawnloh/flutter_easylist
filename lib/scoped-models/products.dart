import 'package:scoped_model/scoped_model.dart';
import '../models/product.dart';

class ProductsModel extends Model {
  List<Product> _products = [];
  int _selectedProductIndex;
  bool _showFavorites = false;

  List<Product> get products => List.from(_products);

  List<Product> get displayedProducts {
    if (_showFavorites) {
      return List.from(_products.where((Product product) {
        return product.isFavorite;
      }).toList());
    }
    return List.from(_products);
  }

  int get selectedProductIndex => _selectedProductIndex;

  Product get selectedProduct =>
      _selectedProductIndex == null ? null : _products[selectedProductIndex];

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  void addProduct(Product product) {
    _products.add(product);
    _selectedProductIndex = null;
  }

  void updateProduct(Product product) {
    _products[_selectedProductIndex] = product;
    _selectedProductIndex = null;
  }

  void deleteProduct() {
    _products.removeAt(_selectedProductIndex);
  }

  void selectProduct(int index) {
    _selectedProductIndex = index;
    notifyListeners();
  }

  void toggleProductFavourite() {
    final bool isCurrentlyFavourite = selectedProduct.isFavorite;
    final bool newFavouriteStatus = !isCurrentlyFavourite;
    final Product updatedProduct = Product(
      title: selectedProduct.title,
      description: selectedProduct.description,
      price: selectedProduct.price,
      image: selectedProduct.image,
      isFavorite: newFavouriteStatus,
    );
    _products[_selectedProductIndex] = updatedProduct;
    _selectedProductIndex = null;
    notifyListeners();
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}
