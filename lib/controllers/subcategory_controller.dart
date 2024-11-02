import 'dart:convert';

import 'package:ecomerce_vendor_store/global_variables.dart';
import 'package:ecomerce_vendor_store/models/subcategory.dart';
import 'package:http/http.dart' as http;

class SubcategoryController {
  Future<List<Subcategory>> getSubcategoriesByCategoryName(
      String categoryName) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/category/$categoryName/subcategories'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8'
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return data
              .map((subcategory) => Subcategory.fromJson(subcategory))
              .toList();
        } else {
          print("subcategories not found");
          return [];
        }
      } else if (response.statusCode == 404) {
        print("subcategories not found");
        return [];
      } else {
        print("failed to fetch categories");
        return [];
      }
    } catch (e) {
      print('Error fetching categories $e');
      return [];
    }
  }
}
