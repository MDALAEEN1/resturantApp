import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resturantapp/generated/l10n.dart';
import 'package:resturantapp/pages/MEALPAGE/meal_page.dart';

class SimpleSearchWidget extends StatefulWidget {
  const SimpleSearchWidget({super.key});

  @override
  State<SimpleSearchWidget> createState() => _SimpleSearchWidgetState();
}

class _SimpleSearchWidgetState extends State<SimpleSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        _removeOverlay();
        return;
      }

      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('menu')
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: query + '\uf8ff')
            .limit(10)
            .get();

        _showOverlay(snapshot.docs);
      } catch (e) {
        print("Error searching: $e");
        _removeOverlay();
      }
    });
  }

  void _showOverlay(List<QueryDocumentSnapshot> items) {
    _removeOverlay();

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: Colors.grey[300]),
                itemBuilder: (BuildContext context, int index) {
                  final doc = items[index];
                  return InkWell(
                    onTap: () {
                      _searchController.text = doc['name'];
                      _removeOverlay();
                      _focusNode.unfocus();

                      // الانتقال إلى صفحة تفاصيل الطبق
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestaurantMealPage(
                            title: doc['name'] ?? 'Unknown',
                            image:
                                doc['image'] ??
                                'https://via.placeholder.com/150',
                            category: doc['category'] ?? 'General',
                            time: '30 min',
                            rating: (doc['rating'] as num?)?.toDouble() ?? 0.0,
                            instructions: doc['instructions'] ?? '',
                            ingredients: List<String>.from(
                              doc['ingredients'] ?? [],
                            ),
                            sizes: (doc['sizes'] as List<dynamic>? ?? [])
                                .map(
                                  (s) => MealSize(
                                    name: s['name'] ?? 'Standard',
                                    price:
                                        (s['price'] as num?)?.toDouble() ?? 0,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Text(
                        doc['name'],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _removeOverlay();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            hintText: S.of(context).Search_for_a_dish_or_meal,
            border: InputBorder.none,
            suffixIcon: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.search, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
