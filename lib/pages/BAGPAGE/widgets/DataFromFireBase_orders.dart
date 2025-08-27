import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resturantapp/pages/DEATILSEPAGE/deatilse_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:resturantapp/pages/BAGPAGE/widgets/orders.dart';

class CartGrid extends StatefulWidget {
  const CartGrid({super.key});

  @override
  State<CartGrid> createState() => _CartGridState();
}

class _CartGridState extends State<CartGrid> {
  String? _cartId;

  @override
  void initState() {
    super.initState();
    _loadCartId();
  }

  Future<void> _loadCartId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');

    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString('device_id', deviceId);
    }

    setState(() {
      _cartId = deviceId;
    });
  }

  // دالة لحساب المجموع الكلي
  double calculateTotal(List<QueryDocumentSnapshot> items) {
    double total = 0.0;
    for (var item in items) {
      final price = (item['price'] as num?)?.toDouble() ?? 0.0;
      final quantity = (item['quantity'] as int?) ?? 1;
      total += price * quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (_cartId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('carts')
          .doc(_cartId)
          .collection('items')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("سلة الشراء فارغة"));
        }

        final allItems = snapshot.data!.docs;
        final totalAmount = calculateTotal(allItems);

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: allItems.length,
                itemBuilder: (context, index) {
                  final item = allItems[index];

                  final List<String> ingredients = item['ingredients'] != null
                      ? List<String>.from(item['ingredients'])
                      : [];

                  List<Map<String, dynamic>> sizes = [];
                  final dynamic rawSizes = item['sizes'];
                  if (rawSizes is Map<String, dynamic>) {
                    sizes = rawSizes.entries
                        .map(
                          (e) => {
                            "name": e.key.toString(),
                            "price": (e.value as num?)?.toDouble() ?? 0.0,
                          },
                        )
                        .toList();
                  } else if (rawSizes is List) {
                    sizes = rawSizes
                        .map((e) => Map<String, dynamic>.from(e))
                        .toList();
                  }

                  return Dismissible(
                    key: Key(item.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) async {
                      await FirebaseFirestore.instance
                          .collection('carts')
                          .doc(_cartId)
                          .collection('items')
                          .doc(item.id)
                          .delete();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${item['name']} تم حذفه من السلة"),
                        ),
                      );
                    },
                    child: OrderItemWidget(
                      docId: item.id,
                      name: item['name']?.toString() ?? "بدون اسم",
                      image:
                          item['image']?.toString() ??
                          "https://via.placeholder.com/150",
                      price: (item['price'] as num?)?.toDouble() ?? 0.0,
                      quantity: (item['quantity'] as int?) ?? 1,
                      ingredients: ingredients,
                      sizes: sizes,
                      category: item['category']?.toString() ?? "",
                      Instructions: item['instructions']?.toString() ?? "",
                      cartId: '$_cartId',
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total: \$${totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      double totalAmount = calculateTotal(
                        allItems,
                      ); // استخدم المجموع الكلي المحسوب
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutFormPage(
                            totalAmount: totalAmount,
                            cartId: _cartId!,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "Checkout",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
