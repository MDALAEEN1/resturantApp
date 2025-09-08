import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFE63946)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟦 Header مع الصورة والاسم
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.transparent),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: NetworkImage(
                  "https://i.pravatar.cc/150?img=3", // صورة افتراضية
                ),
                radius: 40,
              ),
              accountName: const Text(
                "Grace Jensen",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              accountEmail: const Text("(856) 352-5140"),
            ),

            // 🟦 العناصر في القائمة
            drawerItem(Icons.store, "Market"),
            drawerItem(Icons.category, "Categories"),
            drawerItem(Icons.shopping_cart, "My Cart", badge: "2"),
            drawerItem(Icons.visibility, "Watch List", badge: "5"),
            drawerItem(Icons.rss_feed, "Feed"),
            drawerItem(Icons.photo, "Gallery"),
            drawerItem(Icons.settings, "Settings"),
            drawerItem(Icons.logout, "Logout"),

            const Spacer(),

            // 🟦 نسخة التطبيق في الأسفل
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Version v 10.11.12",
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🟦 عنصر مخصص للDrawer
  Widget drawerItem(IconData icon, String title, {String? badge}) {
    return ListTile(
      leading: Stack(
        children: [
          Icon(icon, color: Colors.white),
          if (badge != null)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
        ],
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {},
    );
  }
}
