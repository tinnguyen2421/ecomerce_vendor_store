import 'package:ecomerce_vendor_store/models/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VendorProductProvider extends StateNotifier<List<Product>> {
  VendorProductProvider() : super([]);
  //set the list of products
  void setProducts(List<Product> products) {
    state = products;
  }
}

final vendorProductProvider =
    StateNotifierProvider<VendorProductProvider, List<Product>>((ref) {
  return VendorProductProvider();
});
// final productBySubCategoryProvider =
//     FutureProvider.family<List<dynamic>, String>((ref, subcategoryName) async {
//   final productController = ProductController();
//   try {
//     // Sử dụng phương thức loadProductBySubcategory của controller
//     final products =
//         await productController.loadProductBySubcategory(subcategoryName);
//     return products;
//   } catch (e) {
//     throw e;
//   }
// });
