import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resturantapp/pages/MEALPAGE/meal_page.dart';

class CategoryProductsPage extends StatefulWidget {
  final String categoryName;

  const CategoryProductsPage({super.key, required this.categoryName});

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  String selectedFilter = "All";

  Query<Map<String, dynamic>> _getQuery() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('menu')
        .where("category", isEqualTo: widget.categoryName);

    if (selectedFilter == "Type of meal") {
      query = query.where(
        "type",
        isEqualTo: "وجبة", // عدّل القيمة حسب بياناتك
      );
    }

    return query;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: Text(
          widget.categoryName,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 الفلاتر
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text("All"),
                  selected: selectedFilter == "All",
                  onSelected: (_) {
                    setState(() => selectedFilter = "All");
                  },
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: Colors.red,
                  labelStyle: TextStyle(
                    color: selectedFilter == "All"
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text("Type of meal"),
                  selected: selectedFilter == "Type of meal",
                  onSelected: (_) {
                    setState(() => selectedFilter = "Type of meal");
                  },
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: Colors.red,
                  labelStyle: TextStyle(
                    color: selectedFilter == "Type of meal"
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // 🔹 المنتجات
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("لا توجد منتجات"));
                }

                final products = snapshot.data!.docs;

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product =
                        products[index].data() as Map<String, dynamic>;

                    // 🔹 تحويل sizes مباشرة إلى MealSize
                    List<MealSize> mealSizes = [];
                    if (product['sizes'] != null && product['sizes'] is List) {
                      mealSizes = (product['sizes'] as List)
                          .map(
                            (sizeMap) => MealSize.fromMap(
                              sizeMap as Map<String, dynamic>,
                            ),
                          )
                          .toList();
                    }

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RestaurantMealPage(
                              title: product['name'] ?? "بدون اسم",
                              image: product['image'] ?? "",
                              category: product['category'] ?? "",
                              time: product['time']?.toString() ?? "0",
                              rating: (product['rating'] is num)
                                  ? (product['rating'] as num).toDouble()
                                  : 0.0,
                              ingredients: product['ingredients'] != null
                                  ? List<String>.from(product['ingredients'])
                                  : [],
                              instructions: product['instructions'] ?? "",
                              sizes: mealSizes,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          ClipOval(
                            child: Image.network(
                              product['image'] ?? "",
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product['name'] ?? "بدون اسم",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 4),
                              Text(
                                product['price']?.toString() ?? "0.0",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.green,
                                ),
                              ),
                              const Text(
                                " jd",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
