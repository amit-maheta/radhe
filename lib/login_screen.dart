import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:radhe/network/Repository/ApiProvider.dart';
import 'package:radhe/utils/constants.dart';
import 'package:radhe/utils/shared_pref.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscured = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    ApiRepo()
        .postLogin(_mobileController.text, _passwordController.text)
        .then((response) async {
          setState(() => _isLoading = false);

          if (response['success'] == true) {
            AppConstants.LOGIN_TOKEN = response['data']['token'].toString();
            AppConstants.userID = response['data']['user']['id'].toString();
            AppConstants.LOGIN_USER_NAME = response['data']['user']['name']
                .toString();
            AppConstants.LOGIN_USER_EMAIL = response['data']['user']['email']
                .toString();
            AppConstants.LOGIN_USER_IS_ADMIN =
                response['data']['user']['is_admin'].toString();

            await SharedPref.saveString(
              loginToken,
              response['data']['token'].toString(),
            );
            await SharedPref.saveString(
              userId,
              response['data']['user']['id'].toString(),
            );
            await SharedPref.saveString(
              userEmail,
              response['data']['user']['email'].toString(),
            );
            await SharedPref.saveString(
              userName,
              response['data']['user']['name'].toString(),
            );
            await SharedPref.saveString(
              isAdmin,
              response['data']['user']['is_admin'].toString(),
            );

            Navigator.pushReplacementNamed(context, '/home');
          } else {
            showSnakeBar(context, response['message'] ?? 'Login failed');
          }
        })
        .catchError((error) {
          setState(() => _isLoading = false);
          print('Login error: $error');
          showSnakeBar(context, 'Login error: ${error.toString()}');
        });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B3C82), Color(0xFF1E90FF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: size.width > 600 ? 520 : size.width - 40,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset(
                          'assets/png/app_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 22,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 8),

                              // Mobile Number Field
                              TextFormField(
                                controller: _mobileController,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                enabled: !_isLoading,
                                decoration: InputDecoration(
                                  labelText: 'Mobile Number',
                                  hintText: 'Enter 10-digit mobile number',
                                  prefixIcon: const Icon(Icons.phone_android),
                                  prefixText: '+91 ',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  counterText: '',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter mobile number';
                                  }
                                  if (value.length != 10) {
                                    return 'Enter a valid 10-digit number';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),

                              // Password
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _isObscured,
                                enabled: !_isLoading,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isObscured
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: _isLoading
                                        ? null
                                        : () => setState(
                                            () => _isObscured = !_isObscured,
                                          ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 18),

                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    backgroundColor: const Color(0xFF0B3C82),
                                    disabledBackgroundColor: const Color(
                                      0xFF0B3C82,
                                    ).withOpacity(0.6),
                                  ),
                                  onPressed: _isLoading ? null : _login,
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : const Text(
                                          'Login',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Don\'t have an account? ',
                                    style: TextStyle(color: Color(0xFF374151)),
                                  ),
                                  TextButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () => Navigator.pushNamed(
                                            context,
                                            '/register',
                                          ),
                                    child: const Text(
                                      'Register',
                                      style: TextStyle(
                                        color: Color(0xFF0B3C82),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : () => Navigator.pushNamed(
                                        context,
                                        '/forgot-password',
                                      ),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Color(0xFF0B3C82),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
