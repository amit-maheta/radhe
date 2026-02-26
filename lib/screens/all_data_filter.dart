// import 'package:flutter/material.dart';
// import 'package:radhe/network/Repository/ApiProvider.dart';
// import 'package:radhe/screens/all_data_filter_wise_list.dart';
// import '../models/customer.dart';
// import '../widgets/common_app_bar.dart';
// import '../utils/constants.dart';

// class AllDataFilterScreen extends StatefulWidget {
//   const AllDataFilterScreen({super.key});

//   @override
//   State<AllDataFilterScreen> createState() => _AllDataFilterScreenState();
// }

// class _AllDataFilterScreenState extends State<AllDataFilterScreen> {
//   final GlobalKey<State> _dialogKey = GlobalKey<State>();

//   List<Customer> customersList = [];

//   /// 🔹 Track expand / collapse state per user
//   final Map<String, bool> _expandedUsers = {};

//   @override
//   void initState() {
//     super.initState();
//     getCustomers();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CommonAppBar(title: 'All List'),
//       body: customersList.isEmpty
//           ? const Center(child: CircularProgressIndicator())
//           : ListView(
//               padding: const EdgeInsets.all(16),
//               children: getAllUsers().map((user) => userSection(user)).toList(),
//             ),
//     );
//   }

//   // ================= API =================

//   Future<void> getCustomers() async {
//     showLoadingDialog(context, _dialogKey, '');
//     try {
//       final response = await ApiRepo().getAllList();

//       if (_dialogKey.currentContext != null) {
//         Navigator.pop(_dialogKey.currentContext!);
//       }

//       if (response['success'] == true) {
//         final List<Customer> customers = (response['data'] as List).map((e) {
//           return Customer.fromJson(e);
//         }).toList();

//         setState(() {
//           customersList = customers;

//           /// Expand first user by default
//           if (customersList.isNotEmpty) {
//             _expandedUsers[getAllUsers().first] = true;
//           }
//            _expandedUsers.clear(); // collapse all
//         });
//       } else {
//         showSnakeBar(context, 'Failed to load customers');
//       }
//     } catch (e) {
//       if (_dialogKey.currentContext != null) {
//         Navigator.pop(_dialogKey.currentContext!);
//       }
//       showSnakeBar(context, e.toString());
//     }
//   }

//   // ================= DATA HELPERS =================

//   List<String> getAllUsers() {
//     return customersList
//         .map((e) => e.user?.name)
//         .whereType<String>()
//         .toSet()
//         .toList();
//   }

//   List<Customer> customersByUser(String userName) {
//     return customersList.where((c) => c.user?.name == userName).toList();
//   }

//   Map<String, int> statusCount(List<Customer> list) {
//     return {
//       'In Progress': list.where((e) => e.status == 'In Progress').length,
//       'Done': list.where((e) => e.status == 'Done').length,
//       'Not Done': list.where((e) => e.status == 'Not Done').length,
//       'Cancel': list.where((e) => e.status == 'Cancel').length,
//     };
//   }

//   List<Customer> getSelectedCustomers({
//     required String userName,
//     required String status,
//   }) {
//     return customersList.where((c) {
//       return c.user?.name == userName && c.status == status;
//     }).toList();
//   }

//   // ================= UI =================

//   void _toggleUser(String userName) {
//     setState(() {
//       final isCurrentlyExpanded = _expandedUsers[userName] ?? false;

//       _expandedUsers.clear(); // collapse all

//       // only expand if it was NOT already expanded
//       if (!isCurrentlyExpanded) {
//         _expandedUsers[userName] = true;
//       }
//     });
//   }

//   Widget statusRow({
//     required String title,
//     required int count,
//     bool selected = false,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(30),
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 6),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: selected ? Colors.green.withOpacity(0.15) : Colors.black12,
//           borderRadius: BorderRadius.circular(30),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 if (selected)
//                   const Icon(Icons.check, size: 18, color: Colors.green),
//                 if (selected) const SizedBox(width: 6),
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: selected ? Colors.green : Colors.black,
//                   ),
//                 ),
//               ],
//             ),
//             CircleAvatar(
//               radius: 14,
//               backgroundColor: Colors.grey,
//               child: Text(
//                 count.toString(),
//                 style: const TextStyle(color: Colors.white, fontSize: 12),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget userSection(String userName) {
//     final list = customersByUser(userName);
//     final count = statusCount(list);
//     final isExpanded = _expandedUsers[userName] ?? false;

//     void onStatusTap(String status) {
//       final selectedList = getSelectedCustomers(
//         userName: userName,
//         status: status,
//       );

//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) =>
//               AllDataFilterWiseListScreen(customersList: selectedList),
//         ),
//       );
//     }

//     return Card(
//       elevation: 2,
//       shadowColor: Colors.black12,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         children: [
//           /// 🔹 USER HEADER
//           InkWell(
//             borderRadius: BorderRadius.circular(16),
//             onTap: () => _toggleUser(userName),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//               child: Row(
//                 children: [
//                   AnimatedRotation(
//                     turns: isExpanded ? 0.5 : 0.0,
//                     duration: const Duration(milliseconds: 200),
//                     child: const Icon(Icons.keyboard_arrow_down, size: 26),
//                   ),
//                   const SizedBox(width: 8),

//                   /// User name
//                   Expanded(
//                     child: Text(
//                       userName,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                   /// Total count badge
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.blue.shade50,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       list.length.toString(),
//                       style: TextStyle(
//                         color: Colors.blue.shade700,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           /// 🔹 COLLAPSIBLE CONTENT
//           AnimatedCrossFade(
//             firstChild: const SizedBox.shrink(),
//             secondChild: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//               child: Column(
//                 children: [
//                   const Divider(height: 1),
//                   const SizedBox(height: 12),

//                   modernStatusRow(
//                     title: 'In Process',
//                     count: count['In Progress']!,
//                     color: Colors.orange,
//                     onTap: () => onStatusTap('In Progress'),
//                   ),
//                   modernStatusRow(
//                     title: 'Not Done',
//                     count: count['Not Done']!,
//                     color: Colors.red,
//                     onTap: () => onStatusTap('Not Done'),
//                   ),
//                   modernStatusRow(
//                     title: 'Cancel',
//                     count: count['Cancel']!,
//                     color: Colors.grey,
//                     onTap: () => onStatusTap('Cancel'),
//                   ),
//                   modernStatusRow(
//                     title: 'Done',
//                     count: count['Done']!,
//                     color: Colors.green,
//                     onTap: () => onStatusTap('Done'),
//                   ),
//                 ],
//               ),
//             ),
//             crossFadeState: isExpanded
//                 ? CrossFadeState.showSecond
//                 : CrossFadeState.showFirst,
//             duration: const Duration(milliseconds: 200),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget modernStatusRow({
//     required String title,
//     required int count,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 10),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: color.withOpacity(0.25)),
//         ),
//         child: Row(
//           children: [
//             /// Color indicator
//             Container(
//               width: 8,
//               height: 8,
//               decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//             ),
//             const SizedBox(width: 10),

//             /// Title
//             Expanded(
//               child: Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),

//             /// Count badge
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(
//                 count.toString(),
//                 style: TextStyle(
//                   color: color,
//                   fontWeight: FontWeight.w700,
//                   fontSize: 12,
//                 ),
//               ),
//             ),

//             const SizedBox(width: 6),
//             Icon(
//               Icons.arrow_forward_ios,
//               size: 14,
//               color: color.withOpacity(0.8),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:radhe/network/Repository/ApiProvider.dart';
import 'package:radhe/screens/all_data_filter_wise_list.dart';
import '../models/customer.dart';
import '../utils/constants.dart';

class AllDataFilterScreen extends StatefulWidget {
  const AllDataFilterScreen({super.key});

  @override
  State<AllDataFilterScreen> createState() => _AllDataFilterScreenState();
}

class _AllDataFilterScreenState extends State<AllDataFilterScreen> {
  final GlobalKey<State> _dialogKey = GlobalKey<State>();
  final TextEditingController _searchController = TextEditingController();

  List<Customer> customersList = [];
  List<Customer> filteredCustomers = [];

  String _selectedGrade = 'All';
  static const List<String> _grades = ['All', 'Hot', 'Warm', 'Cold'];

  /// Expand / collapse state
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
        // Grade filter
        final gradeMatch = _selectedGrade == 'All' ||
            customer.grade.toLowerCase() == _selectedGrade.toLowerCase();

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

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'Hot':
        return Colors.red;
      case 'Warm':
        return Colors.orange;
      case 'Cold':
        return Colors.blue;
      default:
        return Colors.white;
    }
  }

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

      if (!isExpanded) {
        _expandedUsers[userName] = true;
      }
    });
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    const appBarColor = Color(0xFF122B84);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'All List',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            color: appBarColor,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _grades
                    .map((grade) => _buildFilterChip(grade))
                    .toList(),
              ),
            ),
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

  Widget _buildFilterChip(String grade) {
    final isSelected = _selectedGrade == grade;
    final color = _gradeColor(grade);
    final selectedColor = grade == 'All' ? Colors.white : color;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedGrade = grade);
        _applyFilters();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: grade == 'All' ? 1.0 : 0.9)
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? selectedColor
                : Colors.white.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Text(
          grade,
          style: TextStyle(
            color: isSelected && grade != 'All'
                ? Colors.white
                : isSelected
                    ? const Color(0xFF122B84)
                    : Colors.white.withValues(alpha: 0.85),
            fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
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

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) =>
      //         AllDataFilterWiseListScreen(customersList: selectedList),
      //   ),
      // );
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AllDataFilterWiseListScreen(customersList: selectedList),
        ),
      );

      // ✅ After coming back, refresh API
      if (result == 'refresh') {
        getCustomers(); // call your API again
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
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      list.length.toString(),
                      style: TextStyle(
                        color: Colors.blue.shade700,
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
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
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
                color: color.withOpacity(0.15),
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
              color: color.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );
  }
}
