import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resturantapp/pages/SEARCHPAGE/widgets/meals_search_cusom.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('menu').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("لا توجد بيانات للتصنيفات"));
        }

        // 🔹 تحويل البيانات للتصنيفات
        final dishes = snapshot.data!.docs;
        final Map<String, Map<String, dynamic>> categories = {};

        for (var dish in dishes) {
          final category = dish['category'] ?? "عام";
          final image = dish['image'] ?? "";
          if (categories.containsKey(category)) {
            categories[category]!['count'] += 1;
          } else {
            categories[category] = {'image': image, 'count': 1};
          }
        }

        final categoryList = categories.entries.toList();

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // عمودين
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.9,
          ),
          itemCount: categoryList.length,
          itemBuilder: (context, index) {
            final category = categoryList[index];
            final name = category.key;
            final data = category.value;
            final image = data['image'];

            return MealsCard(
              title: name,
              imageUrl: image,
              onTap: () {
                // هنا يمكنك إضافة منطق عند الضغط على البطاقة
                print("تم الضغط على التصنيف: $name");
              },
            );
          },
        );
      },
    );
  }
}
