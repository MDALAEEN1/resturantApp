import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class MealSize {
  final String name;
  final double price;

  MealSize({required this.name, required this.price});

  factory MealSize.fromMap(Map<String, dynamic> map) {
    return MealSize(
      name: map["name"],
      price: double.tryParse(map["price"].toString()) ?? 0.0,
    );
  }
}

class RestaurantMealPage extends StatefulWidget {
  const RestaurantMealPage({
    super.key,
    required this.title,
    required this.image,
    required this.category,
    required this.time,
    required this.rating,
    required this.ingredients,
    required this.instructions,
    required this.sizes,
  });

  final String title;
  final String image;
  final String category;
  final String time;
  final double rating;
  final List<String> ingredients;
  final List<MealSize> sizes;
  final String instructions;

  @override
  State<RestaurantMealPage> createState() => _RestaurantMealPageState();
}

class _RestaurantMealPageState extends State<RestaurantMealPage> {
  late MealSize selectedSize;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _deviceId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedSize = widget.sizes.first;
    _getDeviceId();
  }

  // الحصول على معرف الجهاز أو إنشاء واحد جديد
  Future<void> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');

    if (deviceId == null) {
      deviceId = const Uuid().v4(); // إنشاء معرف فريد
      await prefs.setString('device_id', deviceId);
    }

    setState(() {
      _deviceId = deviceId;
    });
  }

  // إرسال الطلب إلى Firebase
  Future<void> _addToCart() async {
    if (_deviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("جاري تهيئة التطبيق..."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // إضافة المنتج إلى سلة المستخدم في Firebase
      await _firestore
          .collection('carts')
          .doc(_deviceId)
          .collection('items')
          .add({
            'name': widget.title,
            'image': widget.image,
            'size': selectedSize.name,
            'price': selectedSize.price,
            'quantity': 1,
            'addedAt': FieldValue.serverTimestamp(),
            'category': widget.category,
            'instructions': widget.instructions,
            'ingredients': widget.ingredients,
            'sizes': widget.sizes
                .map((s) => {'name': s.name, 'price': s.price})
                .toList(),
          });

      // تحديث معلومات السلة الرئيسية
      await _firestore.collection('carts').doc(_deviceId).set({
        'lastUpdated': FieldValue.serverTimestamp(),
        'deviceId': _deviceId,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "تمت الإضافة إلى السلة 🛒 (${selectedSize.name}) - ${selectedSize.price} jd",
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Error adding to cart: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("حدث خطأ أثناء الإضافة إلى السلة"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomBar(context),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 280,
              pinned: false,
              elevation: 0,
              title: innerBoxIsScrolled
                  ? Text(
                      widget.title,
                      style: const TextStyle(color: Colors.black),
                    )
                  : null,
              backgroundColor: innerBoxIsScrolled
                  ? Colors.white
                  : Colors.black.withOpacity(0.3),
              iconTheme: IconThemeData(
                color: innerBoxIsScrolled ? Colors.black : Colors.white,
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  widget.image,
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.25),
                  colorBlendMode: BlendMode.darken,
                ),
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                title: !innerBoxIsScrolled
                    ? Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
          ];
        },
        body: _buildBodyContent(
          widget.category,
          widget.title,
          widget.rating,
          widget.time,
          widget.instructions,
          widget.ingredients,
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _isLoading ? null : _addToCart,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                "Order now • ${selectedSize.price.toStringAsFixed(2)} jd",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildBodyContent(
    String category,
    String title,
    double rating,
    String time,
    String instructions,
    List<String> ingredients,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category
            Text(
              category,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 4),

            // Title
            Text(
              title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Rating + Time
            Row(
              children: [
                Icon(Icons.star, color: Colors.orange[400], size: 20),
                const SizedBox(width: 4),
                Text(
                  "$rating",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.timer, size: 20, color: Colors.grey),
                const SizedBox(width: 4),
                Text(time, style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 25),

            // اختيار الحجم
            const Text(
              "Choose size",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: widget.sizes.map((mealSize) {
                return ChoiceChip(
                  label: Text("${mealSize.name} (${mealSize.price} jd)"),
                  selected: selectedSize.name == mealSize.name,
                  onSelected: (_) {
                    setState(() {
                      selectedSize = mealSize;
                    });
                  },
                  selectedColor: Colors.red,
                  backgroundColor: Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color: selectedSize.name == mealSize.name
                        ? Colors.white
                        : Colors.black,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 25),

            // Instructions
            const Text(
              "About this dish",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              instructions,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 25),

            // Ingredients
            const Text(
              "components",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                final item = ingredients[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check, size: 18, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(item, style: const TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
