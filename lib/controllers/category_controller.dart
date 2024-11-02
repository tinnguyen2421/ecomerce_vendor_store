import 'dart:convert';

import 'package:ecomerce_vendor_store/global_variables.dart';
import 'package:ecomerce_vendor_store/models/category.dart';
import 'package:http/http.dart' as http;

class CategoryController {
  //load the uploaded category

  Future<List<Category>> loadCategories() async {
    try {
      //send an http get request to load the categories
      http.Response response = await http.get(
        Uri.parse('$uri/api/categories'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8'
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<Category> categories =
            data.map((category) => Category.fromJson(category)).toList();
        return categories;
      } else {
        throw Exception('Fail to load categories');
      }
    } catch (e) {
      throw Exception('Error loading Category: $e');
    }
  }
}
