import 'dart:convert';
import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:ecomerce_vendor_store/global_variables.dart';
import 'package:ecomerce_vendor_store/models/product.dart';
import 'package:ecomerce_vendor_store/services/manage_http_respone.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductController {
  Future<void> uploadProduct({
    required String productName,
    required int productPrice,
    required int quantity,
    required String description,
    required String category,
    required String vendorId,
    required String fullName,
    required String subCategory,
    required List<File>? pickedImages,
    required context,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('auth_token');
    if (pickedImages != null) {
      final cloudinary = CloudinaryPublic("deotwffdz", "mcjdyao7");
      List<String> images = [];
      //Loop through each image in the pickedImages List
      for (var i = 0; i < pickedImages.length; i++) {
        CloudinaryResponse cloudinaryResponse = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(pickedImages[i].path, folder: productName),
        );
        //add the sucere url to the images list
        images.add(cloudinaryResponse.secureUrl);
      }
      if (category.isNotEmpty && subCategory.isNotEmpty) {
        final Product product = Product(
            id: '',
            productName: productName,
            productPrice: productPrice,
            quantity: quantity,
            description: description,
            category: category,
            vendorId: vendorId,
            fullName: fullName,
            subCategory: subCategory,
            images: images);
        http.Response response = await http.post(
          Uri.parse("$uri/api/add-product"),
          body: product.toJson(),
          headers: <String, String>{
            "Content-Type": 'application/json; charset=UTF-8',
            "x-auth-token": token!,
          },
        );
        manageHttpRespond(
            response: response,
            context: context,
            onSuccess: () {
              showSnackBar(context, 'Product Uploaded');
            });
      } else {
        showSnackBar(context, 'Select Category');
      }
    } else {
      showSnackBar(context, 'select image');
    }
  }

  Future<List<Product>> loadVendorsProducts(String vendorId) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? token = preferences.getString("auth_token");
      http.Response response = await http.get(
        Uri.parse('$uri/api/products/vendor/$vendorId'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
          'x-auth-token': token!,
        },
      );
      if (response.statusCode == 200) {
        //Decode the json response body into a list  of dynamic object
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        //map each items in the list to product model object which we can use

        List<Product> vendorProducts = data
            .map((product) => Product.fromMap(product as Map<String, dynamic>))
            .toList();
        return vendorProducts;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        //if status code is not 200 , throw an execption   indicating failure to load the popular products
        throw Exception('Failed to load Vendors products');
      }
    } catch (e) {
      throw Exception('Error loading Vendors product : $e');
    }
  }

  Future<void> updateProduct({
    required Product product,
    required List<File>? pickedImages,
    required BuildContext context,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString("auth_token");
    if (pickedImages != null) {
      await uploadImagesToCloudinary(pickedImages, product);
    }
    final updateDateData = product.toMap();

    http.Response response = await http.put(
      Uri.parse('$uri/api/edit-product/${product.id}'),
      body: jsonEncode(updateDateData),
      headers: <String, String>{
        "Content-Type": 'application/json; charset=UTF-8',
        'x-auth-token': token!,
      },
    );
    manageHttpRespond(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Product Updated Successfully');
        });
  }

  Future<List<String>> uploadImagesToCloudinary(
      List<File>? pickedImages, Product product) async {
    final cloudinary = CloudinaryPublic("deotwffdz", "mcjdyao7");
    List<String> uploadedImages = [];
    for (var image in pickedImages!) {
      CloudinaryResponse cloudinaryResponse = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(image.path, folder: product.productName));
      uploadedImages.add(cloudinaryResponse.secureUrl);
    }
    return uploadedImages;
  }
}
