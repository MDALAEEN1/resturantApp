import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resturantapp/pages/MEALPAGE/meal_page.dart';

class OrderItemWidget extends StatefulWidget {
  final String docId;
  final String cartId;
  final String name;
  final String image;
  final double price;
  final int quantity;
  final List<String> ingredients;
  final List<Map<String, dynamic>> sizes;
  final String category;
  final String Instructions;

  const OrderItemWidget({
    super.key,
    required this.docId,
    required this.cartId,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    required this.ingredients,
    required this.sizes,
    required this.category,
    required this.Instructions,
  });

  @override
  State<OrderItemWidget> createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = widget.quantity;
  }

  /// دالة لحساب المجموع الكلي للعنصر
  double calculateTotal() {
    return widget.price * quantity;
  }

  void updateQuantity(int newQuantity) async {
    setState(() {
      quantity = newQuantity;
    });

    try {
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(widget.cartId)
          .collection('items')
          .doc(widget.docId)
          .update({'quantity': quantity});
    } catch (e) {
      print("Error updating quantity: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RestaurantMealPage(
                title: widget.name,
                image: widget.image,
                category: widget.category,
                time: "30-40 min",
                rating: 4.5,
                ingredients: widget.ingredients,
                instructions: widget.Instructions,
                sizes: widget.sizes.map((s) => MealSize.fromMap(s)).toList(),
              ),
            ),
          );
        },
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                /// صورة الوجبة
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.image,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),

                /// النصوص
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Category: ${widget.category}",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),

                      /// استخدام دالة calculateTotal() لعرض المجموع
                      Text(
                        "\$${calculateTotal().toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                /// أدوات التحكم بالكمية
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (quantity > 1) updateQuantity(quantity - 1);
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                      color: Colors.red,
                    ),
                    Text(
                      "$quantity",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        updateQuantity(quantity + 1);
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      color: Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
