import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:radhe/customer_form_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:radhe/models/customer.dart';
import 'package:radhe/screens/full_screen_image_viewer.dart';

import '../network/Repository/ApiProvider.dart';
import '../utils/constants.dart';

class CustomerDetailScreen extends StatelessWidget {
  final Customer customer;
  String _selectedStatus = '';
  final List<String> _statusOptions = [
    'Not Done',
    'Done',
    'Cancel',
    'In Progress',
  ];
  final TextEditingController _feedbackController = TextEditingController();

  CustomerDetailScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              print('Save button pressed');
              final newFeedback = _feedbackController.text.trim();
              if (newFeedback.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please enter next follow up update to save changes.',
                    ),
                  ),
                );
              }

              if (newFeedback.isNotEmpty) {
                final data = {
                  'name': customer.name,
                  'address': customer.address,
                  'source': customer.source,
                  'latitude': customer.latitude,
                  'longitude': customer..longitude,
                  'contact_no': customer.contactNo,
                  'contact_no_1': customer.contactNo1,
                  'status': _selectedStatus,
                  'grade': customer.grade,
                  'visiting_date': customer.visitingDate,
                  'requirement': customer.requirement,
                  'specific_note': customer.specificNote,
                  'mistri_name': customer.mistriName,
                  'last_follow_up_date': customer.lastFollowUpDate,
                  'estimate_image': customer.estimateImageUrls,
                  'last_feedback': "${customer.lastFeedback}[ ${newFeedback} ]",
                };
                print(data);
                final GlobalKey<State> _dialogKey = GlobalKey<State>();
                try {
                  showLoadingDialog(context, _dialogKey, '');
                  final response = await ApiRepo().customerUpdate(
                    customer.id.toString(),
                    data,
                    [],
                  );
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
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Basic Information'),
            _buildInfoRow(context, 'Name', customer.name),
            _buildInfoRow(context, 'Salesman', customer.user.name),
            _buildInfoRow(context, 'Address', customer.address),
            _buildInfoRow(context, 'Source', customer.source),
            // _buildInfoRow(context, 'Status', customer.status),
            _buildDropdownField(
              label: 'Status *',
              value: _selectedStatus.isNotEmpty
                  ? _selectedStatus
                  : customer.status,
              items: _statusOptions,
              icon: Icons.flag_outlined,
              onChanged: (value) {
                _selectedStatus = value!;
                // setState(() {
                //   _selectedStatus = value!;
                // });
              },
            ),
            _buildInfoRow(context, 'Grade', customer.grade),

            const SizedBox(height: 16),
            _buildSectionHeader('Contact Information'),
            _buildInfoRow(context, 'Primary Contact', customer.contactNo),
            if (customer.contactNo1 != null && customer.contactNo1!.isNotEmpty)
              _buildInfoRow(context, 'Secondary Contact', customer.contactNo!),
            _buildInfoRow(context, 'Mistri Name', customer.mistriName),

            const SizedBox(height: 16),
            _buildSectionHeader('Visit & Follow-up'),
            _buildInfoRow(
              context,
              'Visiting Date',
              _formatDate(customer.visitingDate),
            ),
            _buildInfoRow(
              context,
              'Last Follow-up',
              _formatDate(customer.lastFollowUpDate),
            ),

            const SizedBox(height: 16),
            _buildSectionHeader('Requirements & Notes'),
            _buildInfoRow(
              context,
              'Requirement',
              customer.requirement,
              isMultiLine: true,
            ),
            _buildInfoRow(
              context,
              'Specific Note',
              customer.specificNote,
              isMultiLine: true,
            ),
            _buildInfoRow(
              context,
              'Next follow up update',
              customer.lastFeedback,
              isMultiLine: true,
            ),

            if (customer.estimateImageUrls != null &&
                customer.estimateImageUrls!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSectionHeader('Estimate Images'),
              _buildImageGrid(customer.estimateImageUrls!),
            ],

            if ((customer.latitude?.isNotEmpty ?? false) &&
                (customer.longitude?.isNotEmpty ?? false)) ...[
              const SizedBox(height: 16),
              _buildSectionHeader('Location'),
              _buildLocationInfo(context),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool isMultiLine = false,
  }) {
    final bool isPhoneNumber =
        label == 'Primary Contact' || label == 'Secondary Contact';
    final String displayValue = value.isNotEmpty ? value : 'Not specified';
    final bool isClickable = isPhoneNumber && value.isNotEmpty;

    Widget? content, contentEditInput;

    if (label == 'Next follow up update') {
      print(displayValue);

      contentEditInput = TextFormField(
        controller: _feedbackController,
        // initialValue: '',
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Enter next follow up feedback...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        onChanged: (newValue) {
          // Update the feedback in the customer object
          // You can add your save logic here
        },
      );
    }

    if (label == 'Next follow up update') {
      final String rawString = displayValue;

      // Use RegExp to extract everything inside square brackets
      final RegExp regExp = RegExp(r'\[([^\]]+)\]');
      final List<String> matches = regExp
          .allMatches(rawString)
          .map((match) => match.group(1)!)
          .toList();

      print(matches);
      final List<Widget> textWidgets = matches.map((item) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.comment, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList();

      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: textWidgets,
      );
    } else {
      content = Text(
        displayValue,
        style: TextStyle(
          fontSize: 16,
          color: value.isEmpty ? Colors.grey.shade400 : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        maxLines: isMultiLine ? null : 1,
        overflow: isMultiLine ? null : TextOverflow.ellipsis,
      );
    }

    if (isClickable) {
      final String phoneNumber = value.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      ); // Remove any non-numeric characters
      final String formattedNumber = '+91$phoneNumber';

      content = Row(
        children: [
          Expanded(
            child: Text(
              displayValue,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              // Call Button
              IconButton(
                icon: const Icon(Icons.phone, color: Colors.green, size: 24),
                onPressed: () =>
                    _makePhoneCall('tel:$formattedNumber', context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Call',
              ),
              const SizedBox(width: 8),
              // WhatsApp Button
              IconButton(
                icon: SvgPicture.asset(
                  'assets/svg/whatsapp.svg',
                  width: 24,
                  height: 24,
                  // colorFilter: const ColorFilter.mode(Color(0xFF25D366), BlendMode.srcIn),
                ),
                onPressed: () => _openWhatsApp(value, context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'WhatsApp',
              ),
            ],
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          content ?? SizedBox(),
          SizedBox(height: 10),
          contentEditInput ?? SizedBox(),
          const Divider(height: 24, thickness: 1),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String urlString, BuildContext context) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone app')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error making phone call')));
    }
  }

  Future<void> _openWhatsApp(String phoneNumber, BuildContext context) async {
    // print(phoneNumber);
    final url =
        'whatsapp://send?phone="$phoneNumber"&text="Hello Radhe Tiles World Here.."';
    final whatsApp = Uri.parse('https://wa.me/$phoneNumber');
    await launchUrl(whatsApp);
  }

  Widget _buildImageGrid(List<String> imageUrls) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenImageGallery(
                  // imageUrl: imageUrls[index],
                  // heroTag: 'image_$index',
                  imageUrls: imageUrls,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: Hero(
            tag: 'image_$index',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imageUrls[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationInfo(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Location',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLocationRow(
                        context,
                        'Latitude',
                        customer.latitude ?? 'N/A',
                      ),
                      const SizedBox(height: 6),
                      _buildLocationRow(
                        context,
                        'Longitude',
                        customer.longitude ?? 'N/A',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    if (customer.latitude != null &&
                        customer.longitude != null) {
                      _openMap(
                        customer.latitude!,
                        customer.longitude!,
                        context,
                      );
                    }
                  },
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('View On Map'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade700,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.blue.shade200),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(BuildContext context, String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87, fontSize: 14),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  Future<void> _openMap(
    String? latitude,
    String? longitude,
    BuildContext context,
  ) async {
    final double? lat = double.tryParse(latitude ?? '');
    final double? lng = double.tryParse(longitude ?? '');

    // final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    await launchUrl(Uri.parse('geo:$lat,$lng?q=$lat,$lng'));
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
}
