import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import '../../../utils/pdf_report_generator.dart';

class CustomerReviewsTab extends StatefulWidget {
  const CustomerReviewsTab({super.key});

  @override
  State<CustomerReviewsTab> createState() => _CustomerReviewsTabState();
}

class _CustomerReviewsTabState extends State<CustomerReviewsTab> {
  static const Color _espresso = Color(0xFF251811);
  static const Color _cocoa = Color(0xFF8C4A27);
  static const Color _muted = Color(0xFF7A6559);
  static const Color _border = Color(0xFFEFE4D6);

  final Set<String> _selectedReviewIds = {};
  bool _isExporting = false;

  // Helper to draw stars
  Widget _buildStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star_rounded : Icons.star_border_rounded,
          size: 16,
          color: index < rating ? const Color(0xFFF5A623) : _border,
        );
      }),
    );
  }

  // ── PDF EXPORT ──
  // Fetches review docs from Firestore, builds the PDF via PdfReportGenerator,
  // then hands the bytes off to the system print/save/share sheet.
  // If _selectedReviewIds has entries, only those reviews are exported.
    Future<void> _exportPdf() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('reviews').get();

      var reviews = snapshot.docs.map((d) => d.data()).toList();

      // If the user has selected specific reviews via checkbox, filter to those.
      if (_selectedReviewIds.isNotEmpty) {
        final selectedDocs = snapshot.docs
            .where((d) => _selectedReviewIds.contains(d.id))
            .map((d) => d.data())
            .toList();
        if (selectedDocs.isNotEmpty) {
          reviews = selectedDocs;
        }
      }

      // Newest first, same as the on-screen list.
      reviews.sort((a, b) {
        final aTime = a['createdAt'];
        final bTime = b['createdAt'];
        if (aTime is Timestamp && bTime is Timestamp) {
          return bTime.compareTo(aTime);
        }
        return 0;
      });

      final filterInfo =
          _selectedReviewIds.isNotEmpty ? 'Selected (${reviews.length})' : '';

      final bytes = await PdfReportGenerator.generateReviewsReport(
        reviews,
        filterInfo: filterInfo,
      );

      await Printing.sharePdf(
        bytes: bytes,
        filename: 'customer_reviews_report.pdf',
      );
    } catch (e) {
      debugPrint('Error generating reviews PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  // Helper to mark review as "read"
  Future<void> _markAsRead(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('reviews').doc(docId).update({
        'status': 'read',
      });
    } catch (e) {
      debugPrint('Error updating review status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ──
            isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer Reviews',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _espresso),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Feedback and ratings from your sweet customers',
                        style: TextStyle(
                            fontSize: 13, color: _muted.withOpacity(0.8)),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: _isExporting ? null : _exportPdf,
                          icon: _isExporting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: _cocoa),
                                )
                              : const Icon(Icons.download_rounded,
                                  color: _cocoa),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFFBF7F2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: _border),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Customer Reviews',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: _espresso),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Feedback and ratings from your sweet customers',
                            style: TextStyle(
                                fontSize: 13, color: _muted.withOpacity(0.8)),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _isExporting ? null : _exportPdf,
                        icon: _isExporting
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.download_rounded, size: 16),
                        label: Text(
                            _isExporting ? 'Generating...' : 'Export PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _espresso,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 24),

            // ── REVIEWS LIST ──
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream:
                  FirebaseFirestore.instance.collection('reviews').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading reviews: ${snapshot.error}',
                        style: const TextStyle(color: _muted)),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(48.0),
                      child: CircularProgressIndicator(color: _cocoa),
                    ),
                  );
                }

                final docs = snapshot.data?.docs.toList() ?? [];

                // Safe Local Sorting (Newest First)
                try {
                  docs.sort((a, b) {
                    final aTime = a.data()['createdAt'];
                    final bTime = b.data()['createdAt'];
                    if (aTime is Timestamp && bTime is Timestamp) {
                      return bTime.compareTo(aTime);
                    }
                    return 0;
                  });
                } catch (e) {
                  debugPrint('Sorting error: $e');
                }

                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(64.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🌟', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 16),
                          const Text('No reviews yet!',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: _espresso)),
                          const SizedBox(height: 8),
                          Text('Customer ratings will appear here.',
                              style:
                                  TextStyle(color: _muted.withOpacity(0.8))),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final docId = doc.id;

                    final customerName =
                        data['userName']?.toString() ?? 'Anonymous';
                    final productName =
                        data['productName']?.toString() ?? 'Unknown Product';
                    final comment = data['comment']?.toString() ?? '';
                    final rating = data['rating'] is num
                        ? (data['rating'] as num).toInt()
                        : 5;
                    final status = data['status']?.toString() ?? 'new';
                    final isNew = status == 'new';
                    final isSelected = _selectedReviewIds.contains(docId);

                    String dateStr = '';
                    if (data['createdAt'] is Timestamp) {
                      final dt = (data['createdAt'] as Timestamp).toDate();
                      dateStr =
                          '${dt.month}/${dt.day}/${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.all(isMobile ? 14 : 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        // Matches the bold border for unread items from Sweet Notes
                        border: Border.all(
                          color: isNew ? _espresso : _border,
                          width: isNew ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Interactive Checkbox, Customer Name, Date, and Mail Icon
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Checkbox(
                                      value: isSelected,
                                      activeColor: _espresso,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      onChanged: (val) {
                                        setState(() {
                                          if (val == true) {
                                            _selectedReviewIds.add(docId);
                                          } else {
                                            _selectedReviewIds.remove(docId);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    customerName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: isNew ? _espresso : _muted,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    dateStr,
                                    style: const TextStyle(
                                        fontSize: 11, color: _muted),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    isNew
                                        ? Icons.mark_email_unread_rounded
                                        : Icons.mark_email_read_rounded,
                                    size: 16,
                                    color: _muted,
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Middle Row: Product Name & Stars Rating (Aligned with Sweet Notes body indentation)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 32, top: 10, bottom: 6),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 12,
                              runSpacing: 6,
                              children: [
                                Text(
                                  productName,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: _espresso,
                                  ),
                                ),
                                _buildStars(rating),
                              ],
                            ),
                          ),

                          // Bottom Row: Review Comment Body
                          Padding(
                            padding: const EdgeInsets.only(left: 32),
                            child: Text(
                              comment.isNotEmpty
                                  ? comment
                                  : 'No written feedback provided.',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: comment.isNotEmpty
                                    ? _muted
                                    : _muted.withOpacity(0.5),
                                height: 1.5,
                                fontStyle: comment.isNotEmpty
                                    ? FontStyle.normal
                                    : FontStyle.italic,
                              ),
                            ),
                          ),

                          // Mark as Read Button (Only shows if new)
                          if (isNew) ...[
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton.icon(
                                onPressed: () => _markAsRead(docId),
                                icon: const Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 14),
                                label: const Text('Mark Read',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _cocoa,
                                  side: const BorderSide(color: _border),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  minimumSize: Size.zero,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}