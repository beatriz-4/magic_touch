//handle cart item across different files
class CartManager {
  CartManager._privateConstructor();
  static final CartManager instance = CartManager._privateConstructor();

  List<Map<String, dynamic>> selectedItems = [];

  void clearCart() {
    selectedItems.clear();
  }

   double getTotal() {
    return selectedItems.fold(
        0, (sum, item) => sum + (item['price'] * item['quantity']));
  }


}
