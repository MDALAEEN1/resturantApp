import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantCheckoutPage extends StatefulWidget {
  final String cartId; // معرف السلة من الصفحة السابقة

  const RestaurantCheckoutPage({Key? key, required this.cartId})
    : super(key: key);

  @override
  State<RestaurantCheckoutPage> createState() => _RestaurantCheckoutPageState();
}

class _RestaurantCheckoutPageState extends State<RestaurantCheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _paymentMethod = 'Cash on delivery';
  bool _isSubmitting = false;

  List<Map<String, dynamic>> _cartItems = [];
  double _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  // جلب عناصر السلة من Firebase باستخدام cartId
  Future<void> _fetchCartItems() async {
    final cartSnapshot = await FirebaseFirestore.instance
        .collection('carts')
        .doc(widget.cartId)
        .collection('items')
        .get();

    List<Map<String, dynamic>> items = [];
    double total = 0;

    for (var doc in cartSnapshot.docs) {
      final data = doc.data();
      items.add(data);
      final price = (data['price'] as num?)?.toDouble() ?? 0;
      final quantity = (data['quantity'] as int?) ?? 1;
      total += price * quantity;
    }

    setState(() {
      _cartItems = items;
      _totalAmount = total;
    });
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate() || _cartItems.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final orderRef = FirebaseFirestore.instance.collection('orders').doc();

      // إضافة عناصر الطلب
      for (var item in _cartItems) {
        await orderRef.collection('items').add(item);
      }

      // إضافة بيانات الطلب
      await orderRef.set({
        'customerName': _nameController.text,
        'customerPhone': _phoneController.text,
        'customerAddress': _addressController.text,
        'total': _totalAmount,
        'status': 'قيد التحضير',
        'paymentMethod': _paymentMethod,
        'notes': _notesController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'cartId': widget.cartId,
      });

      // حذف عناصر السلة بعد الطلب
      final cartDocs = await FirebaseFirestore.instance
          .collection('carts')
          .doc(widget.cartId)
          .collection('items')
          .get();
      for (var doc in cartDocs.docs) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تأكيد الطلب بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في تأكيد الطلب: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildTextField(
    IconData icon,
    String label,
    TextEditingController controller,
    String validatorMsg, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validatorMsg.isEmpty
          ? null
          : (value) {
              if (value == null || value.isEmpty) return validatorMsg;
              return null;
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = (width / 375).clamp(0.8, 1.3);
    TextStyle labelStyle(double size, [FontWeight fw = FontWeight.normal]) =>
        TextStyle(fontSize: size * scale, fontWeight: fw);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('check out', style: labelStyle(20, FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _cartItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16 * scale),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Basket',
                        style: labelStyle(18, FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _cartItems.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              '${item['name']} x${item['quantity']} - ${(item['price'] * item['quantity']).toStringAsFixed(2)} JD',
                              style: labelStyle(16),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Customer Information',
                        style: labelStyle(18, FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        Icons.person,
                        'full name',
                        _nameController,
                        "Please enter name",
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        Icons.phone,
                        'phone number',
                        _phoneController,
                        'Please enter your phone number.',
                        keyboard: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        Icons.home,
                        'address',
                        _addressController,
                        'Please enter the address',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        Icons.note,
                        'Notes (optional)',
                        _notesController,
                        '',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'payment method',
                        style: labelStyle(18, FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _paymentMethod,
                        items: ['Cash on delivery']
                            .map(
                              (method) => DropdownMenuItem(
                                value: method,
                                child: Text(method, style: labelStyle(14)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _paymentMethod = value!),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12 * scale,
                            horizontal: 12 * scale,
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Total', style: labelStyle(14)),
                    const SizedBox(height: 6),
                    Text(
                      '${_totalAmount.toStringAsFixed(2)} JD',
                      style: labelStyle(18, FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Confirm order',
                          style: labelStyle(
                            16,
                            FontWeight.bold,
                          ).copyWith(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
