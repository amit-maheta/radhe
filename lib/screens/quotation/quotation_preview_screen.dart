import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:radhe/models/quotation_model.dart';
import 'package:radhe/screens/quotation/quotation_pdf_generator.dart';
import 'package:radhe/widgets/common_app_bar.dart';

class QuotationPreviewScreen extends StatefulWidget {
  const QuotationPreviewScreen({super.key});

  @override
  State<QuotationPreviewScreen> createState() => _QuotationPreviewScreenState();
}

class _QuotationPreviewScreenState extends State<QuotationPreviewScreen> {
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  bool _isSharing = false;
  late QuotationModel _quotation;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _quotation =
          ModalRoute.of(context)!.settings.arguments as QuotationModel;
      _generatePdf();
    }
  }

  Future<void> _generatePdf() async {
    try {
      final bytes = await QuotationPdfGenerator.generate(_quotation);
      if (mounted) {
        setState(() {
          _pdfBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e')),
        );
      }
    }
  }

  String _buildShareText() {
    final fmt = NumberFormat('#,##,##0.00', 'en_IN');
    final q = _quotation;
    return '🙏 Namaste ${q.customerName}! ✨ Aapka Radhe Tiles World ka quotation taiyar hai. '
        '📋 Quotation ID: ${q.id} | '
        '💰 Total Amount: Rs.${fmt.format(q.grandTotal)} | '
        '😊 Koi sawaal ho toh batayein. - Radhe Tiles World';
  }

  // Shares PDF file + message text together in one native share sheet
  Future<void> _shareAll() async {
    if (_pdfBytes == null || _isSharing) return;
    setState(() => _isSharing = true);
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/Quotation_${_quotation.id}.pdf');
      await file.writeAsBytes(_pdfBytes!);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/pdf')],
          text: _buildShareText(),
          subject: 'Radhe Tiles World – Quotation ${_quotation.id}',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  // Opens WhatsApp directly with the pre-filled text (no PDF)
  Future<void> _openWhatsApp() async {
    final url = Uri.parse(
        'https://wa.me/?text=${Uri.encodeComponent(_buildShareText())}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _copyText();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('WhatsApp not found. Message copied to clipboard!')),
        );
      }
    }
  }

  void _copyText() {
    Clipboard.setData(ClipboardData(text: _buildShareText()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share message copied to clipboard!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showShareOptions() {
    if (_pdfBytes == null) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share Quotation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Message preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                _buildShareText(),
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
            // Share PDF + text together
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _shareAll();
                },
                icon: const Icon(Icons.share),
                label: const Text('Share PDF + Message Together'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openWhatsApp();
                    },
                    icon: const Icon(Icons.chat_bubble_outline,
                        color: Color(0xFF25D366)),
                    label: const Text('WhatsApp Text Only'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF25D366)),
                      foregroundColor: const Color(0xFF25D366),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _copyText();
                    },
                    icon: const Icon(Icons.content_copy),
                    label: const Text('Copy Text'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareFab() {
    if (_isSharing) {
      return FloatingActionButton.extended(
        onPressed: null,
        icon: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
        label: const Text('Sharing...'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      );
    }
    return FloatingActionButton.extended(
      onPressed: _showShareOptions,
      icon: const Icon(Icons.share),
      label: const Text('Share'),
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Quotation Preview',
        actions: [
          if (!_isLoading && _pdfBytes != null)
            IconButton(
              onPressed: _isSharing ? null : _showShareOptions,
              icon: _isSharing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.share),
              tooltip: 'Share',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF122B84)),
                  SizedBox(height: 16),
                  Text('Generating PDF...'),
                ],
              ),
            )
          : _pdfBytes == null
              ? const Center(child: Text('Failed to generate PDF'))
              : PdfPreview(
                  build: (_) => _pdfBytes!,
                  allowPrinting: true,
                  allowSharing: false,
                  canChangePageFormat: false,
                  pdfFileName: 'Quotation_${_quotation.id}.pdf',
                  actions: const [],
                ),
      floatingActionButton:
          (!_isLoading && _pdfBytes != null) ? _buildShareFab() : null,
    );
  }
}
