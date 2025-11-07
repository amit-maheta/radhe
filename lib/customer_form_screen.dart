import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:radhe/network/Repository/ApiProvider.dart';
import 'package:radhe/utils/constants.dart';
import 'dart:io';

import 'package:radhe/widgets/common_app_bar.dart';

class CustomerFormScreen extends StatefulWidget {
  const CustomerFormScreen({super.key});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final GlobalKey<State> _dialogKey = GlobalKey<State>();
  final _formKey = GlobalKey<FormState>();
  final _salesmanController = TextEditingController();
  final _mistriController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactNumber1Controller = TextEditingController();
  final _contactNumber2Controller = TextEditingController();
  final _requirementController = TextEditingController();
  final _specificNoteController = TextEditingController();
  final _lastFeedbackController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  String _selectedSource = 'Direct';
  String _selectedStatus = 'Not Done';
  String _selectedGrade = 'Normal';
  DateTime? _visitingDate = DateTime.now();
  DateTime? _lastFollowUpDate = DateTime.now();
  List<File> _estimateImages = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _sourceOptions = ['Direct', 'Field'];
  final List<String> _statusOptions = [
    'Not Done',
    'Done',
    'Cancel',
    'In Progress',
  ];
  final List<String> _gradeOptions = ['Normal', 'IMP', 'Most IMP'];

  bool get _isDirectSource => _selectedSource == 'Direct';

  @override
  void dispose() {
    _salesmanController.dispose();
    _mistriController.dispose();
    _customerNameController.dispose();
    _addressController.dispose();
    _contactNumber1Controller.dispose();
    _contactNumber2Controller.dispose();
    _requirementController.dispose();
    _specificNoteController.dispose();
    _lastFeedbackController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isVisitingDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF122B84),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isVisitingDate) {
          _visitingDate = picked;
        } else {
          _lastFollowUpDate = picked;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF122B84),
                ),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    setState(() {
                      _estimateImages.add(File(image.path));
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera,
                  color: Color(0xFF122B84),
                ),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (image != null) {
                    setState(() {
                      _estimateImages.add(File(image.path));
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeImage(int index) {
    setState(() {
      _estimateImages.removeAt(index);
    });
  }

  void _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isDirectSource &&
        (_latitudeController.text.isEmpty ||
            _longitudeController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Latitude and Longitude are required for Field sources',
          ),
        ),
      );
      return;
    }

    // Collect data into a map
    String formattedText = "[ ${_lastFeedbackController.text} ]";
    final data = {
      // 'name': _salesmanController.text,
      'name': _customerNameController.text,
      'address': _addressController.text,
      'source': _selectedSource,
      'latitude': _latitudeController.text,
      'longitude': _longitudeController.text,
      'contact_no': _contactNumber1Controller.text,
      'contact_no_1': _contactNumber2Controller.text,
      'status': _selectedStatus,
      'grade': _selectedGrade,
      'visiting_date': _visitingDate?.toIso8601String(),
      'requirement': _requirementController.text,
      'specific_note': _specificNoteController.text,
      'mistri_name': _mistriController.text.isNotEmpty ? _mistriController.text : '-',
      'last_follow_up_date': _lastFollowUpDate?.toIso8601String(),
      'last_feedback': formattedText,
    };

    try {
      showLoadingDialog(context, _dialogKey, '');
      final response = await ApiRepo().customerCreate(data, _estimateImages);
      if (_dialogKey.currentContext != null) {
        Navigator.pop(_dialogKey.currentContext!);
      }
      if (response['success'] == true) {
        showSnakeBar(
          context,
          'Customer Added successfully',
          backgroundColor: Colors.blue,
        );
        // await Future.delayed(const Duration(seconds: 1));
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        showSnakeBar(
          context,
          response['errors']['phone'][0] ?? 'Customer Add failed',
        );
      }
    } catch (e) {
      if (_dialogKey.currentContext != null) {
        Navigator.pop(_dialogKey.currentContext!);
      }
      showSnakeBar(context, 'Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CommonAppBar(title: 'Customer Form'),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextFormField(
                controller: _salesmanController,
                label: AppConstants.LOGIN_USER_NAME,
                icon: Icons.person_outline,
                // validator: (value) => value == null || value.isEmpty
                //     ? 'Please enter salesman name'
                //     : null,
                enabled: false,
              ),
              const SizedBox(height: 12),
              _buildTextFormField(
                controller: _customerNameController,
                label: 'Customer Name *',
                icon: Icons.account_circle_outlined,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter customer name'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _addressController,
                label: 'Address *',
                icon: Icons.location_on_outlined,
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter address'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Source *',
                value: _selectedSource,
                items: _sourceOptions,
                icon: Icons.source_outlined,
                onChanged: (value) {
                  setState(() {
                    _selectedSource = value!;
                    if (_isDirectSource) {
                      _latitudeController.clear();
                      _longitudeController.clear();
                    }
                  });
                },
              ),

              Visibility(
                visible: !_isDirectSource,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextFormField(
                            controller: _latitudeController,
                            label: 'Lat *',
                            icon: Icons.location_on_outlined,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: !_isDirectSource
                                ? (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Latitude is required';
                                    }
                                    final lat = double.tryParse(value);
                                    if (lat == null || lat < -90 || lat > 90) {
                                      return 'Enter valid latitude (-90 to 90)';
                                    }
                                    return null;
                                  }
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextFormField(
                            controller: _longitudeController,
                            label: 'Long *',
                            icon: Icons.location_on_outlined,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: !_isDirectSource
                                ? (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Longitude is required';
                                    }
                                    final lng = double.tryParse(value);
                                    if (lng == null ||
                                        lng < -180 ||
                                        lng > 180) {
                                      return 'Enter valid longitude (-180 to 180)';
                                    }
                                    return null;
                                  }
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _contactNumber1Controller,
                label: 'Contact Number 1 *',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                addCountryCodePrefix: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact number';
                  }
                  if (value.length != 10) {
                    // Check for exactly 10 digits
                    return 'Please enter a valid 10-digit number';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Only allow digits
                  LengthLimitingTextInputFormatter(10), // Limit to 10 digits
                ],
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _contactNumber2Controller,
                label: 'Contact Number 2', // <-- updated here
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                addCountryCodePrefix: true,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length != 10) {
                    // Check for exactly 10 digits
                    return 'Please enter a valid 10-digit number';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Only allow digits
                  LengthLimitingTextInputFormatter(10), // Limit to 10 digits
                ],
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Status *',
                value: _selectedStatus,
                items: _statusOptions,
                icon: Icons.flag_outlined,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Grade *',
                value: _selectedGrade,
                items: _gradeOptions,
                icon: Icons.grade_outlined,
                onChanged: (value) {
                  setState(() {
                    _selectedGrade = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDateField(
                label: 'Visiting Date *',
                date: _visitingDate,
                onTap: () => _selectDate(context, true),
                validator: (value) => _visitingDate == null
                    ? 'Please select visiting date'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _requirementController,
                label: 'Requirement *',
                icon: Icons.list_alt_outlined,
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter requirement'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _specificNoteController,
                label: 'Specific Note *',
                icon: Icons.note_outlined,
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter specific note'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildImagePicker(),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _mistriController,
                label: 'Mistri/Thekedar Name',
                icon: Icons.engineering_outlined,
                // validator: (value) => value == null || value.isEmpty
                //     ? 'Please enter Mistri/Thekedar Name'
                //     : null,
              ),
              const SizedBox(height: 16),
              _buildDateField(
                label: 'Last Follow-up Date *',
                date: _lastFollowUpDate,
                onTap: () => _selectDate(context, false),
                validator: (value) => _lastFollowUpDate == null
                    ? 'Please select follow-up date'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _lastFeedbackController,
                label: 'Next follow up update *',
                icon: Icons.feedback_outlined,
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter next follow up update'
                    : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF122B84),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Customer Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Widgets Below

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool? enabled = true,
    List<TextInputFormatter>? inputFormatters,
    bool addCountryCodePrefix = false, // new optional param
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black87, fontSize: 16),
      enabled: enabled,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        label: Text.rich(buildLabelWithAsterisk(label)),
        prefixIcon: Icon(icon, color: const Color(0xFF122B84)),
        prefix: addCountryCodePrefix
            ? const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Text(
                  '+91',
                  style: TextStyle(color: Colors.black87, fontSize: 16),
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        label: Text.rich(buildLabelWithAsterisk(label)),
        prefixIcon: Icon(icon, color: const Color(0xFF122B84)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: Color(0xFF122B84)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 16,
                      color: date != null ? Colors.black : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.image_outlined, color: Color(0xFF122B84)),
              SizedBox(width: 12),
              Text(
                'Estimate Pictures',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_estimateImages.isNotEmpty)
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _estimateImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(_estimateImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 18,
                            ),
                            onPressed: () => _removeImage(index),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(
                Icons.add_a_photo_outlined,
                color: Color(0xFF122B84),
              ),
              label: Text(
                'Add Pictures',
                style: const TextStyle(color: Color(0xFF122B84)),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF122B84)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

TextSpan buildLabelWithAsterisk(String label) {
  if (label.contains('*')) {
    final parts = label.split('*');
    return TextSpan(
      children: [
        TextSpan(
          text: parts[0],
          style: const TextStyle(color: Colors.black54),
        ),
        const TextSpan(
          text: '*',
          style: TextStyle(color: Colors.red),
        ),
      ],
    );
  }
  return TextSpan(
    text: label,
    style: const TextStyle(color: Colors.black54),
  );
}
