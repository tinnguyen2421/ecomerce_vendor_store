import 'dart:convert';

import 'package:ecomerce_vendor_store/global_variables.dart';
import 'package:ecomerce_vendor_store/models/order.dart';
import 'package:ecomerce_vendor_store/services/manage_http_respone.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderController {
  //method to GET Orders by vendorId
  Future<List<Order>> loadOrders({required String vendorId}) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? token = sharedPreferences.getString('auth_token');
      //Send an HTTP GET request to get the orders by the buyerId
      http.Response response = await http.get(
        Uri.parse('$uri/api/orders/vendors/$vendorId'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
          "x-auth-token": token!,
        },
      );
      //Check if the response status code is 200(Ok).
      if (response.statusCode == 200) {
        //Parse the json response body into dynamic List
        //This convert the json data into a formate that can be further processed in Dart.
        List<dynamic> data = jsonDecode(response.body);
        //Map the dynamic list to list of orders object using the fromJson factory method
        //this step convert the raw data into list of the orders instance, which are easier to work with
        List<Order> orders =
            data.map((order) => Order.fromJson(order)).toList();
        return orders;
      } else {
        //throw an exception if the server responded with an erro status code
        throw Exception('Failed to load Orders');
      }
    } catch (e) {
      throw Exception('Rrror loading Orders');
    }
  }

  //DELETE order by Id
  Future<void> deleteOrder({required String id, required context}) async {
    try {
      //send HTTP delete request to delete the order by _id
      http.Response response = await http.delete(
        Uri.parse('$uri/api/orders/vendors/$id'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8'
        },
      );
      //handle the HTTP response
      manageHttpRespond(
          response: response,
          context: context,
          onSuccess: () {
            showSnackBar(context, 'Order Deleted successfully');
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> updateDeliveryStatus(
      {required String id, required context}) async {
    try {
      http.Response response = await http.patch(
        Uri.parse('$uri/api/orders/$id/delivered'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8'
        },
        body: jsonEncode({
          "delivered": true,
          "processing": false,
        }),
      );
      manageHttpRespond(
          response: response,
          context: context,
          onSuccess: () {
            showSnackBar(context, 'Order Updated');
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> cancelOrder({required String id, required context}) async {
    try {
      http.Response response = await http.patch(
        Uri.parse('$uri/api/orders/$id/processing'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8'
        },
        body: jsonEncode({
          "processing": false,
          "delivered": false,
        }),
      );
      manageHttpRespond(
          response: response,
          context: context,
          onSuccess: () {
            showSnackBar(context, 'Order Cancel');
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
