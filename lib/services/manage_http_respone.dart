import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void manageHttpRespond({
  required http.Response response,
  required BuildContext context,
  required VoidCallback onSuccess,
}) {
  switch (response.statusCode) {
    case 200: // status code 400 indicates a successful request
      onSuccess();
      break;
    case 400: // status code 400 indicates bad request
      showSnackBar(context, json.decode(response.body)['msg']);
      break;
    case 500: //statis code 500 indicates a server error
      showSnackBar(context, json.decode(response.body)['error']);
    case 201: //status code 201 indicates a resource was created succesfully
      onSuccess();
      break;
  }
}

void showSnackBar(BuildContext context, String title) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(title)));
}
