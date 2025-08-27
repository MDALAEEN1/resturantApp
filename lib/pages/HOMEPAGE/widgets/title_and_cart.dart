import 'dart:async';

import 'package:flutter/material.dart';

class TitleAndCart extends StatefulWidget {
  const TitleAndCart({super.key});

  @override
  State<TitleAndCart> createState() => _TitleAndCartState();
}

class _TitleAndCartState extends State<TitleAndCart>
    with SingleTickerProviderStateMixin {
  final List<FoodCategory> categories = [
    FoodCategory(name: "Spaghetti", isSelected: true),
    FoodCategory(name: "Steak", isSelected: false),
    FoodCategory(name: "Pizza", isSelected: false),
    FoodCategory(name: "Soups", isSelected: false),
  ];

  final List<String> foodImages = [
    "https://static01.nyt.com/images/2025/01/17/multimedia/CR-Lemony-Hummus-Pasta-wtkj/CR-Lemony-Hummus-Pasta-wtkj-jumbo.jpg",
    "https://images.unsplash.com/photo-1544025162-d76694265947",
    "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38",
    "https://images.unsplash.com/photo-1476224203421-9ac39bcb3327",
  ];

  final List<String> foodDescriptions = [
    "Pasta Spaghetti\nwith zucchini, basil, cream\nand cheese...",
    "Juicy Steak\nwith mashed potatoes\nand vegetables...",
    "Italian Pizza\nwith mozzarella, tomato\nand basil...",
    "Creamy Soup\nwith fresh vegetables\nand herbs...",
  ];

  int currentIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;
  late Timer _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    // بدء الحركة التلقائية
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextPage = currentIndex + 1;
        if (nextPage >= categories.length) {
          nextPage = 0;
        }

        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoScroll() {
    if (_autoScrollTimer.isActive) {
      _autoScrollTimer.cancel();
    }
  }

  void _restartAutoScroll() {
    _stopAutoScroll();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _stopAutoScroll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // العنوان مع تأثير تكبير بسيط
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.95, end: 1.0),
          duration: Duration(milliseconds: 300),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: RichText(
                text: TextSpan(
                  text: "Looking for your\n",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    height: 1.2,
                  ),
                  children: [
                    TextSpan(
                      text: "   Favourite Meal?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        SizedBox(height: 20),

        // الصف الذي يحتوي على التصنيفات وبطاقة الطعام
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // التصنيفات (عمودية)
            Column(
              children: List.generate(categories.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      for (var category in categories) {
                        category.isSelected = false;
                      }
                      categories[index].isSelected = true;
                      currentIndex = index;
                      _pageController.animateToPage(
                        index,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                      _restartAutoScroll(); // إعادة تشغيل التمرير التلقائي بعد النقر
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 65),
                    child: RotatedBox(
                      quarterTurns: -1,
                      child: AnimatedDefaultTextStyle(
                        duration: Duration(milliseconds: 300),
                        style: TextStyle(
                          color: categories[index].isSelected
                              ? Colors.black
                              : Colors.grey,
                          fontWeight: categories[index].isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: categories[index].isSelected ? 18 : 16,
                        ),
                        child: Text(categories[index].name),
                      ),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(width: 16),

            // بطاقات الطعام مع تأثير التمرير
            Expanded(
              child: SizedBox(
                height: 460,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: categories.length,
                  onPageChanged: (index) {
                    setState(() {
                      for (var category in categories) {
                        category.isSelected = false;
                      }
                      categories[index].isSelected = true;
                      currentIndex = index;
                      _restartAutoScroll(); // إعادة تشغيل التمرير التلقائي عند التمرير
                    });
                  },
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double value = 1.0;
                        if (_pageController.position.haveDimensions) {
                          value = _pageController.page! - index;
                          value = (1 - (value.abs() * 0.2)).clamp(0.8, 1.0);
                        }
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value.clamp(0.5, 1.0),
                            child: child,
                          ),
                        );
                      },
                      child: _buildFoodCard(index),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFoodCard(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(foodImages[index]),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.2),
                BlendMode.darken,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 15,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            alignment: Alignment.bottomLeft,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  foodDescriptions[index],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 8),
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  width: categories[index].isSelected ? 100 : 0,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FoodCategory {
  String name;
  bool isSelected;

  FoodCategory({required this.name, required this.isSelected});
}
