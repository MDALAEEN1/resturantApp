import 'package:flutter/material.dart';
import 'package:resturantapp/generated/l10n.dart';
import 'package:resturantapp/pages/SEARCHPAGE/widgets/DataFromFirebase_ForCatagory.dart';
import 'package:resturantapp/pages/SEARCHPAGE/widgets/search_page_coustem.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // العنوان + زر الفلترة
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.pop(context); // يرجع للشاشة السابقة
                          },
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ],
                ),
                Text(
                  S.of(context).Search_product,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // مربع البحث
            SimpleSearchWidget(),
            const SizedBox(height: 20),
            CategoryGrid(),
          ],
        ),
      ),
    );
  }
}
