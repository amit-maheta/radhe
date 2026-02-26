import 'package:flutter/material.dart';
import 'package:radhe/network/Repository/ApiProvider.dart';
import 'package:radhe/screens/all_data_filter_wise_list.dart';
import '../models/customer.dart';
import '../utils/constants.dart';

class AllDataHotFilterScreen extends StatefulWidget {
  const AllDataHotFilterScreen({super.key});

  @override
  State<AllDataHotFilterScreen> createState() => _AllDataHotFilterScreenState();
}

class _AllDataHotFilterScreenState extends State<AllDataHotFilterScreen> {
  final GlobalKey<State> _dialogKey = GlobalKey<State>();
  final TextEditingController _searchController = TextEditingController();

  List<Customer> customersList = [];
  List<Customer> filteredCustomers = [];

  final Map<String, bool> _expandedUsers = {};

  @override
  void initState() {
    super.initState();
    getCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ================= API =================

  Future<void> getCustomers() async {
    showLoadingDialog(context, _dialogKey, '');

    try {
      final response = await ApiRepo().getAllList();

      if (_dialogKey.currentContext != null) {
        Navigator.pop(_dialogKey.currentContext!);
      }

      if (response['success'] == true) {
        final List<Customer> customers = (response['data'] as List).map((e) {
          return Customer.fromJson(e);
        }).toList();

        setState(() {
          customersList = customers;
          _expandedUsers.clear();
        });
        _applyFilters();
      } else {
        showSnakeBar(context, 'Failed to load customers');
      }
    } catch (e) {
      if (_dialogKey.currentContext != null) {
        Navigator.pop(_dialogKey.currentContext!);
      }
      showSnakeBar(context, e.toString());
    }
  }

  // ================= FILTER + SEARCH =================

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      filteredCustomers = customersList.where((customer) {
        // Always show only Hot grade
        final gradeMatch = customer.grade.toLowerCase() == 'hot';

        // Search filter
        final name = customer.name.toLowerCase();
        final contact1 = customer.contactNo.toString();
        final contact2 = customer.contactNo1?.toString() ?? '';
        final searchMatch = query.isEmpty ||
            name.contains(query) ||
            contact1.contains(query) ||
            contact2.contains(query);

        return gradeMatch && searchMatch;
      }).toList();

      _expandedUsers.clear();
    });
  }

  void _onSearchChanged(String value) => _applyFilters();

  // ================= HELPERS =================

  List<String> getAllUsers() {
    return filteredCustomers
        .map((e) => e.user?.name)
        .whereType<String>()
        .toSet()
        .toList();
  }

  List<Customer> customersByUser(String userName) {
    return filteredCustomers.where((c) => c.user?.name == userName).toList();
  }

  Map<String, int> statusCount(List<Customer> list) {
    return {
      'In Progress': list.where((e) => e.status == 'In Progress').length,
      'Done': list.where((e) => e.status == 'Done').length,
      'Not Done': list.where((e) => e.status == 'Not Done').length,
      'Cancel': list.where((e) => e.status == 'Cancel').length,
    };
  }

  List<Customer> getSelectedCustomers({
    required String userName,
    required String status,
  }) {
    return filteredCustomers.where((c) {
      return c.user?.name == userName && c.status == status;
    }).toList();
  }

  void _toggleUser(String userName) {
    setState(() {
      final isExpanded = _expandedUsers[userName] ?? false;
      _expandedUsers.clear();
      if (!isExpanded) _expandedUsers[userName] = true;
    });
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF122B84),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Hot List',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: customersList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// SEARCH BAR
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search by name or contact number',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                    ),
                  ),
                ),

                /// LIST
                Expanded(
                  child: filteredCustomers.isEmpty
                      ? const Center(child: Text('No results found'))
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: getAllUsers()
                              .map((user) => userSection(user))
                              .toList(),
                        ),
                ),
              ],
            ),
    );
  }

  Widget userSection(String userName) {
    final list = customersByUser(userName);
    final count = statusCount(list);
    final isExpanded = _expandedUsers[userName] ?? false;

    void onStatusTap(String status) async {
      final selectedList = getSelectedCustomers(
        userName: userName,
        status: status,
      );

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AllDataFilterWiseListScreen(customersList: selectedList),
        ),
      );

      if (result == 'refresh') {
        getCustomers();
      }
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          InkWell(
            onTap: () => _toggleUser(userName),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down, size: 26),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      list.length.toString(),
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 12),
                  modernStatusRow(
                    title: 'In Progress',
                    count: count['In Progress']!,
                    color: Colors.orange,
                    onTap: () => onStatusTap('In Progress'),
                  ),
                  modernStatusRow(
                    title: 'Not Done',
                    count: count['Not Done']!,
                    color: Colors.red,
                    onTap: () => onStatusTap('Not Done'),
                  ),
                  modernStatusRow(
                    title: 'Cancel',
                    count: count['Cancel']!,
                    color: Colors.grey,
                    onTap: () => onStatusTap('Cancel'),
                  ),
                  modernStatusRow(
                    title: 'Done',
                    count: count['Done']!,
                    color: Colors.green,
                    onTap: () => onStatusTap('Done'),
                  ),
                ],
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget modernStatusRow({
    required String title,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: color.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }
}
