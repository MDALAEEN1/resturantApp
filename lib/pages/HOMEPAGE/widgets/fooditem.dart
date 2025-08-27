import 'package:flutter/material.dart';
import 'package:resturantapp/pages/MEALPAGE/meal_page.dart';

Widget foodItem(
  BuildContext context,
  String image,
  String title,
  String subtitle,
  String time,
  String category,
  double rating,
  String instructions,
  List<String> ingredients,
  List<Map<String, dynamic>> sizes,
) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RestaurantMealPage(
            title: title,
            image: image,
            category: category,
            time: time,
            rating: rating,
            ingredients: ingredients,
            instructions: instructions,
            sizes: sizes.map((sizeMap) => MealSize.fromMap(sizeMap)).toList(),
          ),
        ),
      );
    },
    child: Container(
      width: 170,
      margin: EdgeInsets.only(
        right: 16,
        top: 20,
      ), // زيادة الهامش العلوي لإفساح المجال للصورة
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Color.fromARGB(255, 136, 13, 33), // لون كحلي داكن
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 100,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none, // يسمح للعناصر بالخروج من حدود الـ Stack
        children: [
          // الصورة تخرج من الأعلى بشكل واضح
          Positioned(
            top: -18,
            left: 45,
            child: Container(
              width: 110, // نفس حجم الصورة
              height: 110, // نفس حجم الصورة
              child: ClipOval(
                child: Image.network(
                  image,
                  height: 110,
                  width: 110,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // النصوص في الأسفل
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                color: Color.fromARGB(255, 136, 13, 33).withOpacity(0.9),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
