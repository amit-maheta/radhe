import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:radhe/network/Repository/ApiProvider.dart';
import 'package:radhe/utils/constants.dart';

// Branch model
class Branch {
  final int id;
  final String? name;

  Branch({required this.id, required this.name});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(id: json['id'], name: json['name']);
  }

  @override
  String toString() => name ?? '';
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<State> _dialogKey = GlobalKey<State>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isObscured = true;
  bool _isLoading = false;

  List<Branch> _branches = [];
  Branch? _selectedBranch;

  @override
  void initState() {
    super.initState();
    getBranches();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> getBranches() async {
    showLoadingDialog(context, _dialogKey, '');
    try {
      final response = await ApiRepo().getBranches();
      if (_dialogKey.currentContext != null) {
        Navigator.pop(_dialogKey.currentContext!);
      }
      if (response['success'] == true) {
        List<dynamic> branches = response['data'] ?? [];
        setState(() {
          _branches = branches.map((e) => Branch.fromJson(e)).toList();
        });
      } else {
        showSnakeBar(context, 'Failed to load branches');
      }
    } catch (error) {
      if (_dialogKey.currentContext != null) {
        Navigator.pop(_dialogKey.currentContext!);
      }
      showSnakeBar(context, 'Error: ${error.toString()}');
    }
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final data = {
      "name": _fullNameController.text.trim(),
      "email": _emailController.text.trim(),
      "phone": _mobileController.text.trim(),
      "password": _passwordController.text.trim(),
      "is_admin": 'false',
      "branch_id": _selectedBranch?.id.toString(),
    };

    print("Registration Data: $data");

    try {
      final response = await ApiRepo().callRegistration(data);
      if (response['success'] == true) {
        showSnakeBar(
          context,
          'Registration successful',
          backgroundColor: Colors.blue,
        );
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        showSnakeBar(
          context,
          response['errors']['phone'][0] ?? 'Registration failed',
        );
      }
    } catch (e) {
      showSnakeBar(context, 'Error: ${e.toString()}');
    }

    setState(() => _isLoading = false);
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.grey.shade50,
      prefixIcon: Icon(icon),
    );
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
                      width: 100,
                      height: 100,
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
                    const SizedBox(height: 18),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Create account',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0B3C82),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _fullNameController,
                                decoration: _inputDecoration(
                                  'Full Name',
                                  Icons.person,
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                    ? 'Enter your name'
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _mobileController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                decoration: _inputDecoration(
                                  'Mobile Number',
                                  Icons.phone_android,
                                ).copyWith(prefixText: '+91 '),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter mobile number';
                                  }
                                  final valid = RegExp(r'^\d{10}$');
                                  return valid.hasMatch(value.trim())
                                      ? null
                                      : 'Invalid number';
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: _inputDecoration(
                                  'Email (optional)',
                                  Icons.email,
                                ),
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(value.trim())) {
                                      return 'Invalid email address';
                                    }
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<Branch>(
                                value: _selectedBranch,
                                decoration: _inputDecoration(
                                  'Branch',
                                  Icons.business,
                                ),
                                items: _branches.map((Branch branch) {
                                  return DropdownMenuItem<Branch>(
                                    value: branch,
                                    child: Text(branch.name ?? ''),
                                  );
                                }).toList(),
                                onChanged: (Branch? value) {
                                  setState(() => _selectedBranch = value);
                                },
                                validator: (value) =>
                                    value == null ? 'Select a branch' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _isObscured,
                                decoration:
                                    _inputDecoration(
                                      'Password',
                                      Icons.lock,
                                    ).copyWith(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isObscured
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () => setState(
                                          () => _isObscured = !_isObscured,
                                        ),
                                      ),
                                    ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter password';
                                  }
                                  if (value.length < 8) {
                                    return 'Password must be at least 8 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _isObscured,
                                decoration: _inputDecoration(
                                  'Confirm Password',
                                  Icons.lock_outline,
                                ),
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0B3C82),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        )
                                      : const Text(
                                          'Create Account',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Already have an account?'),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/login',
                                      );
                                    },
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Color(0xFF0B3C82),
                                      ),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
