import 'package:ecomerce_vendor_store/models/order.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//A class that extends StateNotifier to manage the state of total earnings

class TotalEarningsProvider extends StateNotifier<Map<String, dynamic>> {
  TotalEarningsProvider() : super({"totalEarnings": 0, "totalOrders": 0});
  //Method to calculate the total earnings based on the delivered status
  void calculateEarnings(List<Order> orders) {
    double earnings = 0;
    int orderCount = 0;

    //Loop throught each orders in the list of orders
    for (Order order in orders) {
      //Check if the orders has been delivered
      if (order.delivered) {
        orderCount++;
        earnings += order.productPrice * order.quantity;
      }
    }
    //update the state with the calculated earnings, which will notifier listeners of this state
    state = {
      'totalEarnings': earnings,
      'totalOrders': orderCount,
    };
  }
}

final totalEarningsProvider =
    StateNotifierProvider<TotalEarningsProvider, Map<String, dynamic>>((ref) {
  return TotalEarningsProvider();
});
