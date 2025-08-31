import 'package:flutter/material.dart';
import 'package:resturantapp/pages/BAGPAGE/bagpage.dart';
import 'package:resturantapp/pages/HOMEPAGE/widgets/title_and_cart.dart';
import 'package:resturantapp/pages/HOMEPAGE/widgets/DATAFROMFIREBASE.dart';
import 'package:resturantapp/pages/SEARCHPAGE/search_page.dart';

class FoodHomePage extends StatelessWidget {
  const FoodHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppBar مخصص
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "restaurant".toUpperCase(),
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: Colors.red,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SearchPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.red,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyOrderPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 15),
              // العنوان و السلة
              const TitleAndCart(),

              const SizedBox(height: 15),
              Text(
                "Menu",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              const Divider(thickness: 0.3, height: 10, color: Colors.grey),

              // Grid للأطباق
              const MenuGrid(),
            ],
          ),
        ),
      ),
    );
  }
}
