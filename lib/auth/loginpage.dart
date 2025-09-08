import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resturantapp/auth/Signuppage.dart';
import 'package:resturantapp/pages/HOMEPAGE/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  bool isLoading = false;
  bool obscurePass = true;

  void _signIn() async {
    if (emailController.text.isEmpty || passController.text.isEmpty) {
      _showSnackBar("Please enter both email and password", Colors.red);
      return;
    }

    setState(() => isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FoodHomePage()),
      );
      _showSnackBar("Sign-in successful!", Colors.green);
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}", Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _resetPassword() async {
    if (emailController.text.isEmpty) {
      _showSnackBar("Please enter your email", Colors.red);
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());
      _showSnackBar("Check your email to reset password", Colors.blue);
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // ✅ القسم العلوي مع صورة الشيف
          Container(
            alignment: Alignment.topCenter,
            height: double.infinity,
            color: Colors.red,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Image.asset(
                "images/d797705758050aa1b2c18410a7ec5c6c.png",
                height: 200,
              ),
            ),
          ),

          // ✅ القسم السفلي (حقل الإدخال والأزرار)
          Container(
            alignment: Alignment.topCenter,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(45),
                topRight: Radius.circular(45),
              ),
              color: Colors.white,
            ),
            height: 550,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    // 🟢 حقل إدخال البريد الإلكتروني
                    _buildTextField(
                      controller: emailController,
                      hint: "Enter your Email",
                      icon: Icons.email,
                      isPassword: false,
                    ),

                    const SizedBox(height: 15),

                    // 🔴 حقل إدخال كلمة المرور مع زر إظهار/إخفاء
                    _buildTextField(
                      controller: passController,
                      hint: "Enter your Password",
                      icon: Icons.lock,
                      isPassword: true,
                    ),

                    const SizedBox(height: 20),

                    // 🟢 زر تسجيل الدخول
                    ElevatedButton(
                      onPressed: isLoading ? null : _signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Sign in",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                    ),

                    const SizedBox(height: 10),

                    // 🔹 رابط "نسيت كلمة المرور"
                    TextButton(
                      onPressed: _resetPassword,
                      child: const Text(
                        "Forgot your password?",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),

                    // 🟢 تسجيل حساب جديد
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(color: Colors.black),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Signup(),
                              ),
                            );
                          },
                          child: const Text(
                            "Signup",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 مكون حقل إدخال مخصص
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isPassword,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? obscurePass : false,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black54),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 20,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscurePass ? Icons.visibility_off : Icons.visibility,
                  color: Colors.red,
                ),
                onPressed: () {
                  setState(() {
                    obscurePass = !obscurePass;
                  });
                },
              )
            : null,
      ),
    );
  }
}
