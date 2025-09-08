import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:resturantapp/auth/loginpage.dart';
import 'package:resturantapp/generated/l10n.dart';
import 'package:resturantapp/pages/HOMEPAGE/widgets/drawer/pages/settings/ContactPage.dart';
import 'package:resturantapp/pages/HOMEPAGE/widgets/drawer/pages/settings/LanguagePage.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false; // حالة الثيم
  bool isNotificationOn = true; // حالة الإشعارات
  String? fcmToken;

  @override
  void initState() {
    super.initState();
    _checkInitialNotificationPermission();
  }

  // تحقق من إذن الإشعارات عند فتح الصفحة
  Future<void> _checkInitialNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.getNotificationSettings();
    setState(() {
      isNotificationOn =
          settings.authorizationStatus == AuthorizationStatus.authorized;
    });
  }

  Future<void> _getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    setState(() {
      fcmToken = token;
    });
    print("FCM Token: $token");
  }

  // طلب إذن الإشعارات
  Future<void> _requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      await _getFCMToken(); // ← هنا نأخذ التوكين
    } else {
      print('User declined or has not accepted permission');
    }

    setState(() {
      isNotificationOn =
          settings.authorizationStatus == AuthorizationStatus.authorized;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        title: Text(
          S.of(context).Settings,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _sectionTitle(S.of(context).Account),
            _buildCard(
              icon: Icons.person,
              iconColor: Colors.blue,
              title: S.of(context).Profile,
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                );
              },
            ),
            _buildCard(
              icon: Icons.language,
              iconColor: Colors.pink,
              title: S.of(context).Language,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LanguagePage()),
                );
              },
            ),
            SizedBox(height: 20),
            _sectionTitle(S.of(context).Notification),
            Card(
              color: isDarkMode ? Colors.grey[850] : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 3,
              shadowColor: Colors.grey[300],
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.withOpacity(0.2),
                  child: Icon(Icons.notifications, color: Colors.green),
                ),
                title: Text(
                  S.of(context).pushNotification,
                  style: TextStyle(
                    fontSize: 18,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                trailing: Switch(
                  value: isNotificationOn,
                  onChanged: (val) async {
                    if (val) {
                      await _requestNotificationPermission(); // طلب الإذن
                      if (isNotificationOn) {
                        // الاشتراك في topic بعد قبول الإذن
                        await FirebaseMessaging.instance.subscribeToTopic(
                          "all_users",
                        );
                        print("Subscribed to topic: all_users");
                      }
                    } else {
                      // إلغاء الاشتراك عند إيقاف الإشعارات
                      await FirebaseMessaging.instance.unsubscribeFromTopic(
                        "all_users",
                      );
                      setState(() {
                        isNotificationOn = false;
                      });
                      print("Unsubscribed from topic: all_users");
                    }
                  },
                  activeColor: Colors.green,
                ),
              ),
            ),
            SizedBox(height: 20),
            _sectionTitle(S.of(context).Support),
            _buildCard(
              icon: Icons.phone,
              iconColor: Colors.red,
              title: S.of(context).contactUs,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ContactPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      shadowColor: Colors.grey[300],
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDarkMode ? Colors.white : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
