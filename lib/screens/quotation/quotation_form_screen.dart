import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:radhe/models/quotation_model.dart';
import 'package:radhe/utils/constants.dart';
import 'package:radhe/widgets/common_app_bar.dart';

class QuotationFormScreen extends StatefulWidget {
  const QuotationFormScreen({super.key});

  @override
  State<QuotationFormScreen> createState() => _QuotationFormScreenState();
}

class _QuotationFormScreenState extends State<QuotationFormScreen> {
  final _customerNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _picker = ImagePicker();

  final List<QuotationCategory> _categories = [];

  @override
  void initState() {
    super.initState();
    _categories.add(QuotationCategory(name: 'FLOORING'));
  }

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  String _generateId() {
    final r = Random();
    const chars = '0123456789abcdef';
    return List.generate(8, (_) => chars[r.nextInt(chars.length)]).join();
  }

  void _addCategory() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            hintText: 'e.g., FULL BODY, MASTER BATH',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = ctrl.text.trim().toUpperCase();
              if (name.isNotEmpty) {
                setState(() => _categories.add(QuotationCategory(name: name)));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _renameCategory(int index) {
    final ctrl = TextEditingController(text: _categories[index].name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Category'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = ctrl.text.trim().toUpperCase();
              if (name.isNotEmpty) {
                setState(() => _categories[index].name = name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showItemDialog(
    QuotationCategory category, {
    QuotationItem? existing,
    int? editIndex,
  }) {
    final descCtrl = TextEditingController(text: existing?.itemDescription ?? '');
    final gradeCtrl = TextEditingController(text: existing?.grade ?? '');
    final sizeCtrl = TextEditingController(text: existing?.size ?? '');
    final boxesCtrl = TextEditingController(
      text: (existing != null && existing.boxes > 0) ? existing.boxes.toString() : '',
    );
    final sqftCtrl = TextEditingController(
      text: (existing != null && existing.sqft > 0)
          ? existing.sqft.toStringAsFixed(2)
          : '',
    );
    final rateCtrl = TextEditingController(
      text: (existing != null && existing.ratePerBox > 0)
          ? existing.ratePerBox.toStringAsFixed(2)
          : '',
    );
    File? selectedImage = existing?.image;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bsCtx) => StatefulBuilder(
        builder: (bsCtx, setBS) {
          final boxes = int.tryParse(boxesCtrl.text) ?? 0;
          final rate = double.tryParse(rateCtrl.text) ?? 0.0;
          final sqft = double.tryParse(sqftCtrl.text) ?? 0.0;
          final finalAmount = rate * boxes;
          final ratePerSqft = sqft > 0 ? finalAmount / sqft : 0.0;
          final fmt = NumberFormat('#,##,##0.00', 'en_IN');

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(bsCtx).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        editIndex != null ? 'Edit Item' : 'Add Item',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(bsCtx),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Item Description *',
                      hintText: 'e.g., IG020806',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: gradeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Grade',
                            hintText: 'PRE / OTP',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: sizeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Size',
                            hintText: '1200x1800',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Image picker
                  GestureDetector(
                    onTap: () async {
                      final source = await showDialog<ImageSource>(
                        context: context,
                        builder: (d) => AlertDialog(
                          title: const Text('Select Image Source'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.camera_alt,
                                    color: Color(0xFF122B84)),
                                title: const Text('Camera'),
                                onTap: () =>
                                    Navigator.pop(d, ImageSource.camera),
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo_library,
                                    color: Color(0xFF122B84)),
                                title: const Text('Gallery'),
                                onTap: () =>
                                    Navigator.pop(d, ImageSource.gallery),
                              ),
                            ],
                          ),
                        ),
                      );
                      if (source != null) {
                        final picked = await _picker.pickImage(
                          source: source,
                          imageQuality: 70,
                          maxWidth: 800,
                        );
                        if (picked != null) {
                          setBS(() => selectedImage = File(picked.path));
                        }
                      }
                    },
                    child: Container(
                      height: 130,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade100,
                      ),
                      child: selectedImage != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    selectedImage!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => setBS(() => selectedImage = null),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close,
                                          color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 44, color: Colors.grey.shade400),
                                const SizedBox(height: 6),
                                Text(
                                  'Tap to add tile image\n(Camera or Gallery)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: boxesCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Boxes *',
                            hintText: '0',
                            border: OutlineInputBorder(),
                            suffixText: 'Box',
                          ),
                          onChanged: (_) => setBS(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: sqftCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Total SQFT',
                            hintText: '0.00',
                            border: OutlineInputBorder(),
                            suffixText: 'SQFT',
                          ),
                          onChanged: (_) => setBS(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: rateCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Rate per Box (Incl. Tax) *',
                      hintText: '0.00',
                      border: OutlineInputBorder(),
                      prefixText: '₹ ',
                    ),
                    onChanged: (_) => setBS(() {}),
                  ),
                  if (finalAmount > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (ratePerSqft > 0)
                            Text(
                              '₹${ratePerSqft.toStringAsFixed(2)}/SQFT',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.blue.shade700),
                            ),
                          Text(
                            'Total: ₹${fmt.format(finalAmount)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF122B84),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (descCtrl.text.trim().isEmpty) {
                          showSnakeBar(
                              context, 'Please enter item description');
                          return;
                        }
                        final b = int.tryParse(boxesCtrl.text) ?? 0;
                        if (b <= 0) {
                          showSnakeBar(
                              context, 'Please enter number of boxes');
                          return;
                        }
                        final item = QuotationItem(
                          itemDescription: descCtrl.text.trim(),
                          grade: gradeCtrl.text.trim(),
                          size: sizeCtrl.text.trim(),
                          image: selectedImage,
                          boxes: b,
                          sqft: double.tryParse(sqftCtrl.text) ?? 0.0,
                          ratePerBox: double.tryParse(rateCtrl.text) ?? 0.0,
                        );
                        setState(() {
                          if (editIndex != null) {
                            category.items[editIndex] = item;
                          } else {
                            category.items.add(item);
                          }
                        });
                        Navigator.pop(bsCtx);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        editIndex != null ? 'Update Item' : 'Add Item',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _generatePdf() async {
    if (_customerNameCtrl.text.trim().isEmpty) {
      showSnakeBar(context, 'Please enter customer name');
      return;
    }
    final validCats =
        _categories.where((c) => c.items.isNotEmpty).toList();
    if (validCats.isEmpty) {
      showSnakeBar(context, 'Please add at least one item');
      return;
    }

    final quotation = QuotationModel(
      id: _generateId(),
      date: DateTime.now(),
      generatedBy: AppConstants.LOGIN_USER_NAME,
      customerName: _customerNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      categories: validCats,
    );

    Navigator.pushNamed(context, '/quotation-preview', arguments: quotation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Create Quotation'),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer info card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer Information',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF122B84)),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _customerNameCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Customer Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _addressCtrl,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Categories
            ..._categories.asMap().entries.map((e) =>
                _buildCategoryCard(e.value, e.key)),

            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _addCategory,
              icon: const Icon(Icons.add, color: Color(0xFF122B84)),
              label: const Text('Add Category',
                  style: TextStyle(color: Color(0xFF122B84))),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: Color(0xFF122B84)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generatePdf,
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Generate PDF'),
        backgroundColor: const Color(0xFF122B84),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildCategoryCard(QuotationCategory category, int catIndex) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _renameCategory(catIndex),
                    child: Row(
                      children: [
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF122B84),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.edit_outlined,
                            size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                if (_categories.length > 1)
                  IconButton(
                    onPressed: () =>
                        setState(() => _categories.removeAt(catIndex)),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Remove category',
                  ),
              ],
            ),
            const Divider(),
            if (category.items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Text('No items yet. Tap "Add Item" to start.',
                      style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...category.items.asMap().entries.map(
                    (e) => _buildItemCard(category, e.value, e.key),
                  ),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: () =>
                  _showItemDialog(category),
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(
      QuotationCategory category, QuotationItem item, int index) {
    final fmt = NumberFormat('#,##,##0.00', 'en_IN');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: item.image != null
                ? Image.file(item.image!,
                    width: 56, height: 56, fit: BoxFit.cover)
                : Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_outlined,
                        color: Colors.grey, size: 28),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.itemDescription,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${item.grade}  |  ${item.size}',
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 12),
                ),
                Text(
                  '${item.boxes} Box  |  ${item.sqft} SQFT',
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 12),
                ),
                Text(
                  '₹${fmt.format(item.finalAmount)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF122B84),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () =>
                    _showItemDialog(category, existing: item, editIndex: index),
                icon: const Icon(Icons.edit_outlined,
                    color: Colors.blue, size: 20),
              ),
              IconButton(
                onPressed: () =>
                    setState(() => category.items.removeAt(index)),
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
