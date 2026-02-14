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

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  // DateTime selectedDate = DateTime.now();
  final GlobalKey<State> _dialogKey = GlobalKey<State>();
  List<Customer> customersList = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';
  String _gradeFilter = 'All';
  String startDateGlobal = '';
  String endDateGlobal = '';
  DateTimeRange? _selectedDateRange;

  Future<void> _selectDate(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;

        final startDate = DateFormat('yyyy-MM-dd').format(picked.start);
        final endDate = DateFormat('yyyy-MM-dd').format(picked.end);
        setState(() {
          customersList.clear(); // Clear existing data
        });
        startDateGlobal = startDate;
        endDateGlobal = endDate;
        getCustomers(
          startDate,
          endDate,
        ); // Re-fetch data based on selected date
      });
    }
  }

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: selectedDate,
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime.now(),
  //   );
  //   if (picked != null && picked != selectedDate) {
  //     setState(() {
  //       selectedDate = picked;
  //     });
  //     final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
  //     setState(() {
  //       customersList.clear(); // Clear existing data
  //     });
  //     getCustomers(formattedDate); // Re-fetch data based on selected date
  //   }
  // }

  Future<void> getCustomers(startdate, endDate) async {
    showLoadingDialog(
      context,
      _dialogKey,
      '',
    ); // Show loading dialog while fetching data
    try {
      final response = await ApiRepo().getCustomers(
        startdate,
        endDate,
      ); // Assume your API call method is getCustomers
      if (_dialogKey.currentContext != null) {
        Navigator.pop(_dialogKey.currentContext!); // Close loading dialog
      }

      if (response['success'] == true) {
        // Get the data from the response
        List<dynamic> customersJson = response['data'] ?? [];

        // Map the response data to Customer model
        List<Customer> customers = customersJson
            .map(
              (json) => Customer.fromJson(json),
            ) // Convert each JSON object to a Customer model
            .toList();

        // Now you can use the 'customers' list as needed in your app
        setState(() {
          customersList =
              customers; // Store the list in your state (assuming _customers is a list of Customer)
        });
      } else {
        showSnakeBar(context, 'Failed to load customers');
      }
    } catch (error) {
      if (_dialogKey.currentContext != null) {
        Navigator.pop(
          _dialogKey.currentContext!,
        ); // Close loading dialog on error
      }
      showSnakeBar(context, 'Error: ${error.toString()}');
    }
  }

  @override
  void initState() {
    super.initState();
    // final now = DateTime.now();
    // final formattedDate = DateFormat('yyyy-MM-dd').format(now);
    // startDateGlobal = formattedDate;
    // endDateGlobal = formattedDate;

    final DateTime endDateTime = DateTime.now();
    final DateTime startDateTime = endDateTime.subtract(
      const Duration(days: 365),
    );

    final String startDate = DateFormat('yyyy-MM-dd').format(startDateTime);
    final String endDate = DateFormat('yyyy-MM-dd').format(endDateTime);

    getCustomers(startDate, endDate);
  }

  List<Customer> get _filteredCustomers {
    return customersList.where((customer) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          customer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          customer.contactNo.contains(_searchQuery);

      final matchesStatus =
          _statusFilter == 'All' || customer.status == _statusFilter;

      final matchesGrade =
          _gradeFilter == 'All' || customer.grade == _gradeFilter;

      return matchesSearch && matchesStatus && matchesGrade;
    }).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Customers',
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _showPdfOptions,
            tooltip: 'PDF Generate',
          ),
          const SizedBox(width: 25),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
            tooltip: 'Pick a Date',
          ),
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
                // const SizedBox(height: 12),
                // Filter Chips
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       _buildFilterChip(
                //         label: 'Status: $_statusFilter',
                //         onTap: () => _showStatusFilter(),
                //       ),
                //       const SizedBox(width: 8),
                //       _buildFilterChip(
                //         label: 'Grade: $_gradeFilter',
                //         onTap: () => _showGradeFilter(),
                //       ),
                //     ],
                //   ),
                // ),
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
                        if (_searchQuery.isNotEmpty ||
                            _statusFilter != 'All' ||
                            _gradeFilter != 'All')
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                                _statusFilter = 'All';
                                _gradeFilter = 'All';
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Navigate to add new customer
      //   },
      //   backgroundColor: Theme.of(context).colorScheme.primary,
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
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
                        setState(() {
                          // Update text or reload data here
                          getCustomers(startDateGlobal, endDateGlobal);
                        });
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

  void _showPdfOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'PDF Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Print PDF'),
              onTap: () {
                Navigator.pop(context);
                _generatePdf(print: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share PDF'),
              onTap: () {
                Navigator.pop(context);
                _generatePdf(print: false);
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Future<void> _generatePdf({required bool print}) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Customer List Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'S.No.',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Name',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Salesman',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Address',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Source',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Status',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Grade',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Contact',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Visiting Date',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ...customersList.asMap().entries.map(
                  (entry) => pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text((entry.key + 1).toString()),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(entry.value.name),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(entry.value.user.name),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(entry.value.address),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(entry.value.source),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(entry.value.status),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(entry.value.grade),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.UrlLink(
                          destination: 'tel:${entry.value.contactNo}',
                          child: pw.Text(
                            entry.value.contactNo,
                            style: pw.TextStyle(
                              color: PdfColors.blue,
                              decoration: pw.TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(_formatDate(entry.value.visitingDate)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    if (print) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } else {
      // Share the PDF
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'customer_list.pdf',
      );
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
