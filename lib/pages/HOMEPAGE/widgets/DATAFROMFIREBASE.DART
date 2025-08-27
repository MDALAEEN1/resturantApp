import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fooditem.dart';

class MenuGrid extends StatelessWidget {
  const MenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('menu').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("لا توجد أطباق متاحة"));
        }

        final allDishes = snapshot.data!.docs;
        final categories =
            allDishes.map((d) => d['category'] ?? 'عام').toSet().toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categories.map((category) {
              final dishesOfCategory =
                  allDishes.where((d) => d['category'] == category).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      category,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: dishesOfCategory.length,
                    itemBuilder: (context, index) {
                      final dish = dishesOfCategory[index];

                      // المكونات
                      final ingredients =
                          List<String>.from(dish['ingredients'] ?? []);

                      // معالجة sizes لتدعم Map أو List
                      List<Map<String, dynamic>> sizes = [];
                      final dynamic rawSizes = dish['sizes'];
                      if (rawSizes is Map<String, dynamic>) {
                        sizes = rawSizes.entries
                            .map((e) => {"name": e.key, "price": e.value})
                            .toList();
                      } else if (rawSizes is List) {
                        sizes = List<Map<String, dynamic>>.from(rawSizes);
                      }

                      return foodItem(
                        context,
                        dish['image'] ?? "",
                        dish['name'] ?? "",
                        dish['description'] ?? "لا يوجد وصف",
                        dish['preparation_time'] ?? "غير متوفر",
                        dish['category'] ?? "عام",
                        dish['rating']?.toDouble() ?? 0.0,
                        dish['instructions'] ?? "لا توجد تعليمات",
                        ingredients,
                        sizes,
                      );
                    },
                  ),
                  
                  const Divider(thickness: 0.3, height: 10, color: Colors.grey),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
