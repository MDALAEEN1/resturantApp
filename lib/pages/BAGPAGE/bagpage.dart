import 'package:flutter/material.dart';
import 'package:resturantapp/pages/BAGPAGE/widgets/DataFromFireBase_orders.dart';

class MyOrderPage extends StatefulWidget {
  @override
  State<MyOrderPage> createState() => _MyOrderPageState();
}

class _MyOrderPageState extends State<MyOrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "my orders".toUpperCase(),
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // القائمة قابلة للتمرير وتملأ المساحة المتبقية
            Expanded(child: CartGrid()),
          ],
        ),
      ),
    );
  }
}
