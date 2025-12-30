import 'package:flutter/material.dart';
import 'package:radhe/utils/constants.dart';
import 'package:radhe/utils/shared_pref.dart';
import 'widgets/common_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CommonAppBar(
        title: 'Home',
        // showBackButton: false,
      ),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back ${AppConstants.LOGIN_USER_NAME}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF122B84),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Text(
                  //   AppConstants.LOGIN_USER_EMAIL,
                  //   style: TextStyle(
                  //     fontSize: 16,
                  //     color: Colors.grey[600],
                  //     fontStyle: FontStyle.italic,
                  //   ),
                  // ),
                  const SizedBox(height: 8),
                  Text(
                    'What would you like to do today?',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildActionCard(
                        icon: Icons.people_outline,
                        title: 'Customers',
                        subtitle: 'View all customers',
                        color: const Color(0xFF122B84),
                        onTap: () {
                          Navigator.pushNamed(context, '/customer-list');
                        },
                      ),
                      _buildActionCard(
                        icon: Icons.add_circle_outline,
                        title: 'Add Customer',
                        subtitle: 'Create new customer',
                        color: Colors.green,
                        onTap: () {
                          Navigator.pushNamed(context, '/customer-form');
                        },
                      ),
                      _buildActionCard(
                        icon: Icons.analytics_outlined,
                        title: 'My Task',
                        subtitle: 'View Task',
                        color: Colors.purple,
                        onTap: () {
                          Navigator.pushNamed(context, '/customer-list-status');
                        },
                      ),
                      // _buildActionCard(
                      //   icon: Icons.settings_outlined,
                      //   title: 'Settings',
                      //   subtitle: 'App settings',
                      //   color: Colors.orange,
                      //   onTap: () {},
                      // ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // const Text(
                  //   'Recent Activity',
                  //   style: TextStyle(
                  //     fontSize: 20,
                  //     fontWeight: FontWeight.bold,
                  //     color: Color(0xFF122B84),
                  //   ),
                  // ),
                  const SizedBox(height: 16),
                  // Container(
                  //   padding: const EdgeInsets.all(20),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(12),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.grey.withOpacity(0.1),
                  //         spreadRadius: 1,
                  //         blurRadius: 10,
                  //         offset: const Offset(0, 2),
                  //       ),
                  //     ],
                  //   ),
                  //   child: Column(
                  //     children: [
                  //       Icon(Icons.history, size: 48, color: Colors.grey[300]),
                  //       const SizedBox(height: 12),
                  //       const Text(
                  //         'No recent activity',
                  //         style: TextStyle(
                  //           fontSize: 16,
                  //           fontWeight: FontWeight.bold,
                  //           color: Colors.grey,
                  //         ),
                  //       ),
                  //       const SizedBox(height: 8),
                  //       Text(
                  //         'Your recent activities will appear here',
                  //         style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  //         textAlign: TextAlign.center,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(
      //         content: Text('Add new item'),
      //         behavior: SnackBarBehavior.floating,
      //       ),
      //     );
      //   },
      //   backgroundColor: const Color(0xFF122B84),
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(
                    color.r.toInt(),
                    color.g.toInt(),
                    color.b.toInt(),
                    0.2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF122B84), Color(0xFF1E3A8A)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/png/app_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Radhe',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Customer Management',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.home_outlined,
                    color: Color(0xFF122B84),
                  ),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.person_add_outlined,
                    color: Color(0xFF122B84),
                  ),
                  title: const Text('Add Customer'),
                  subtitle: const Text('Create new customer record'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/customer-form');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.people_outline,
                    color: Color(0xFF122B84),
                  ),
                  title: const Text('Customer List'),
                  subtitle: const Text('View all customers'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/customer-list');
                  },
                ),
                const Divider(),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFE53E3E)),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFFE53E3E),
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                      TextButton(
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Color(0xFFE53E3E)),
                        ),
                        onPressed: () async {
                          // Navigate to login screen and remove all previous routes

                          await SharedPref.resetData();
                          AppConstants.userID = '';
                          AppConstants.LOGIN_USER_NAME = '';
                          AppConstants.LOGIN_USER_EMAIL = '';
                          AppConstants.LOGIN_USER_IS_ADMIN = '';
                          AppConstants.LOGIN_USER_CONTACT_NUMBER = '';
                          AppConstants.LOGIN_TOKEN = '';
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (Route<dynamic> route) => false,
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
