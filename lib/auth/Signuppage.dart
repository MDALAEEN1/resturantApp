import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resturantapp/auth/loginpage.dart';
import 'package:resturantapp/pages/HOMEPAGE/home_page.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late String email = '';
  late String pass = '';
  late String firstName = '';
  late String lastName = '';

  // متغير لتخزين التاريخ المختار

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            alignment: Alignment.topCenter,
            height: double.infinity,
            color: Colors.yellow.shade700,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Image.asset(
                "images/d797705758050aa1b2c18410a7ec5c6c.png",
                height: 200,
              ),
            ),
          ),
          Container(
            alignment: Alignment.topCenter,
            height: 550,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(45),
                topRight: Radius.circular(45),
              ),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // اسم المستخدم
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: TextStyle(color: Colors.black),
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            firstName = value;
                          },
                          decoration: const InputDecoration(
                            hintText: "First Name",
                            hintStyle: TextStyle(color: Colors.black),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          style: TextStyle(color: Colors.black),
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            lastName = value;
                          },
                          decoration: const InputDecoration(
                            hintText: "Last Name",
                            hintStyle: TextStyle(color: Colors.black),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Email textField
                  TextField(
                    style: TextStyle(color: Colors.black),
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      email = value;
                    },
                    decoration: const InputDecoration(
                      hintText: "Enter your Email",
                      hintStyle: TextStyle(color: Colors.black),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Password textField
                  TextField(
                    style: TextStyle(color: Colors.black),
                    obscureText: true,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      pass = value;
                    },
                    decoration: const InputDecoration(
                      hintText: "Enter your Password",
                      hintStyle: TextStyle(color: Colors.black),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Sign-up button
                  TextButton(
                    onPressed: () async {
                      if (email.isEmpty ||
                          pass.isEmpty ||
                          firstName.isEmpty ||
                          lastName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please fill all fields"),
                          ),
                        );
                        return;
                      }

                      try {
                        UserCredential userCredential = await _auth
                            .createUserWithEmailAndPassword(
                              email: email,
                              password: pass,
                            );

                        bool isNewUser =
                            userCredential.additionalUserInfo?.isNewUser ??
                            false;

                        await _firestore
                            .collection('users')
                            .doc(userCredential.user?.uid)
                            .set({
                              'firstName': firstName,
                              'lastName': lastName,
                              'email': email,
                            });

                        if (isNewUser) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FoodHomePage(),
                            ), // توجيه المستخدم الجديد إلى صفحة إدخال الطول والوزن
                            (Route<dynamic> route) => false,
                          );
                        } else {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FoodHomePage(),
                            ), // توجيه المستخدم القديم إلى الصفحة الرئيسية
                            (Route<dynamic> route) => false,
                          );
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Sign-up successful!")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Colors.yellow.shade700,
                      ),
                    ),
                    child: const Text(
                      "Sign up",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Row for login and password recovery
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Do you have an account? ",
                        style: TextStyle(color: Colors.black),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                        child: const Text(
                          "Sign in",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
