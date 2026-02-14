import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:radhe/network/Repository/ApiProvider.dart';
import 'package:radhe/screens/full_screen_image_viewer.dart';
import 'package:radhe/screens/customer_detail_screen.dart';
import 'package:radhe/utils/constants.dart';
import '../models/customer.dart';
import '../widgets/common_app_bar.dart'; // Import the CommonAppBar widget
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AllDataFilterWiseListScreen extends StatefulWidget {
  final List<Customer> customersList;

  const AllDataFilterWiseListScreen({super.key, required this.customersList});

  @override
  State<AllDataFilterWiseListScreen> createState() =>
      _AllDataFilterWiseListScreenState();
}

class _AllDataFilterWiseListScreenState
    extends State<AllDataFilterWiseListScreen> {
  final GlobalKey<State> _dialogKey = GlobalKey<State>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  // String _statusFilter = 'All';
  // String _gradeFilter = 'All';
  // String startDateGlobal = '';
  // String endDateGlobal = '';

  @override
  void initState() {
    super.initState();
    _searchController.clear();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Inactive':
        return Colors.grey;
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return Colors.blue;
      default:
        return Colors.black;
    }
  }

  List<Customer> get _filteredCustomers {
    return widget.customersList.where((customer) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          customer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          customer.contactNo.contains(_searchQuery);

      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Customers List', actions: [
       
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Customers...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                    hintStyle: TextStyle(color: Colors.grey[500]),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ],
            ),
          ),
          // Customer List
          Expanded(
            child: _filteredCustomers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No customers found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_searchQuery.isNotEmpty
                        // ||
                        // _statusFilter != 'All' ||
                        // _gradeFilter != 'All'
                        )
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                                // _statusFilter = 'All';
                                // _gradeFilter = 'All';
                              });
                            },
                            child: const Text('Clear filters'),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = _filteredCustomers[index];
                      return _buildCustomerCard(customer);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        child: InkWell(
          onTap: () {
            // Navigate to customer details
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Name and Status Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Customer Name
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Customer: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                TextSpan(
                                  text: customer.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Salesman Name
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 14,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 4),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Salesman: ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: customer.user.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          customer.status,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor(
                            customer.status,
                          ).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Status: ${customer.status}',
                        style: TextStyle(
                          color: _getStatusColor(customer.status),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Contact Information
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      customer.contactNo,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (customer.address.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          customer.address,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lat: ${customer.latitude ?? ''} Long: ${customer.longitude ?? ''}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.black54),
                    SizedBox(width: 4),
                    Text(
                      formatDate(customer.visitingDate),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(Icons.access_time, size: 16, color: Colors.black54),
                    SizedBox(width: 4),
                    Text(
                      formatTime(customer.visitingDate),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue[100]!,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Grade: ${customer.grade}',
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green[100]!,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            customer.source,
                            style: TextStyle(
                              color: Colors.green[800],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // ✅ IMAGE VIEW SECTION
                if (customer.estimateImageUrls != null &&
                    customer.estimateImageUrls!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: customer.estimateImageUrls!.length,
                      itemBuilder: (context, index) {
                        final imageUrl = customer.estimateImageUrls![index];
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => FullScreenImageGallery(
                                imageUrls: customer.estimateImageUrls!,
                                initialIndex: index,
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                              image: DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // View Details Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) =>
                      //         CustomerDetailScreen(customer: customer),
                      //   ),
                      // );
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CustomerDetailScreen(customer: customer),
                        ),
                      );

                      // After coming back, refresh data or text
                      if (result == 'refresh') {
                       Navigator.pop(context, 'refresh');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[800],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.blue[200]!),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text(
                      'View Full Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
