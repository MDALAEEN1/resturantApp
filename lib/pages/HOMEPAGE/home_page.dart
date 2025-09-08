import 'package:flutter/material.dart';
import 'package:resturantapp/generated/l10n.dart';
import 'package:resturantapp/pages/BAGPAGE/bagpage.dart';
import 'package:resturantapp/pages/HOMEPAGE/widgets/drawer/drawerpage.dart';
import 'package:resturantapp/pages/HOMEPAGE/widgets/title_and_cart.dart';
import 'package:resturantapp/pages/HOMEPAGE/widgets/DATAFROMFIREBASE.dart';
import 'package:resturantapp/pages/SEARCHPAGE/search_page.dart';

class FoodHomePage extends StatelessWidget {
  FoodHomePage({super.key});

  // مفتاح للتحكم بالـ Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,

      // ✅ اختار واحد من الاثنين حسب رغبتك:
      drawer: const CustomDrawer(), // يفتح من اليسار
      // endDrawer: const RightSideDrawer(), // لو تبغى من اليمين
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppBar مخصص
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.red),
                          onPressed: () {
                            // ✅ اختار حسب مكان الـ Drawer
                            _scaffoldKey.currentState!.openDrawer(); // للـ يسار
                            // _scaffoldKey.currentState!.openEndDrawer(); // للـ يمين
                          },
                        ),
                        Text(
                          S.of(context).restaurant.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
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
                  ),
                ],
              ),

              const SizedBox(height: 15),
              // العنوان و السلة
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TitleAndCart(),
                    const SizedBox(height: 15),
                    Text(
                      S.of(context).Menu,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    const Divider(
                      thickness: 0.3,
                      height: 10,
                      color: Colors.grey,
                    ),

                    // Grid للأطباق
                    const MenuGrid(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
