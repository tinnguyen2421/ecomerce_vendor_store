import 'package:ecomerce_vendor_store/models/vendor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VendorProvider extends StateNotifier<Vendor?> {
  VendorProvider()
      : super(Vendor(
          id: '',
          fullName: '',
          email: '',
          state: '',
          city: '',
          locality: '',
          role: '',
          password: '',
          token: '',
          storeImage: '',
          storeDescription: '',
        ));
  //getter method to extract value from an object
  Vendor? get vendor => state;
  //Method to set vendor user state from json
  //purpose: updates the user state base on json String respresentation of the user vendor object
  void setVendor(String vendorJson) {
    state = Vendor.fromJson(vendorJson);
  }

  void signOut() {
    state = null;
  }
}

//make the data accisible within the application
final vendorProvider = StateNotifierProvider<VendorProvider, Vendor?>((ref) {
  return VendorProvider();
});
