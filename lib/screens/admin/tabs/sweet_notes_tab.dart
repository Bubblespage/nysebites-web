import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import '../../../utils/pdf_report_generator.dart';

class SweetNotesTab extends StatefulWidget {
  final List<Map<String, dynamic>> sweetNotes;

  const SweetNotesTab({super.key, required this.sweetNotes});

  @override
  State<SweetNotesTab> createState() => _SweetNotesTabState();
}

class _SweetNotesTabState extends State<SweetNotesTab> {
  static const Color brandCocoa = Color(0xFF3E2723);
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE5E7EB);

  Set<String> _selectedExportIds = {};

  Future<void> _exportPdf() async {
    final notesToExport = _selectedExportIds.isEmpty
        ? widget.sweetNotes
        : widget.sweetNotes
            .where((n) => _selectedExportIds.contains((n['docId']).toString()))
            .toList();
    final bytes = await PdfReportGenerator.generateSweetNotesReport(notesToExport);
    await Printing.sharePdf(bytes: bytes, filename: 'sweet_notes_report.pdf');
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.month}/${date.day}/${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    if (timestamp is String && timestamp.isNotEmpty) {
      return timestamp.contains('T') ? timestamp.split('T').first : timestamp;
    }
    return 'Recently';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallMobile = constraints.maxWidth < 420;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isSmallMobile
    ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sweet Notes & Customer Inquiries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
          const SizedBox(height: 3),
          const Text('Messages and customer catering inquiries received from the Sweet Note form', style: TextStyle(fontSize: 11.5, color: textMuted)),
          const SizedBox(height: 12),
          Row(
            children: [
              if (_selectedExportIds.isNotEmpty) ...[
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(color: const Color(0xFFFFF5F5), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFFFE5E5))),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          onPressed: () => _showBatchDeleteConfirmation(context),
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: Text('Delete (${_selectedExportIds.length})'),
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFFD32F2F), padding: const EdgeInsets.symmetric(horizontal: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        ),
                        Container(width: 1, height: 20, color: const Color(0xFFFFE5E5)),
                        TextButton(
                          onPressed: () => setState(() => _selectedExportIds.clear()),
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFF9CA3AF), padding: const EdgeInsets.symmetric(horizontal: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                          child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ] else
                const Spacer(),
              IconButton(
                onPressed: _exportPdf,
                icon: const Icon(Icons.download_rounded, color: brandCocoa),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFBF7F2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: borderLight)),
                ),
              ),
            ],
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
              const Text('Sweet Notes & Customer Inquiries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
              const SizedBox(height: 3),
              const Text('Messages and customer catering inquiries received from the Sweet Note form', style: TextStyle(fontSize: 11.5, color: textMuted)),
            ],
          ),
          Row(
            children: [
              if (_selectedExportIds.isNotEmpty) ...[
                Container(
                  height: 38,
                  decoration: BoxDecoration(color: const Color(0xFFFFF5F5), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFFFE5E5))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        onPressed: () => _showBatchDeleteConfirmation(context),
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: Text('Delete (${_selectedExportIds.length})'),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFFD32F2F), padding: const EdgeInsets.symmetric(horizontal: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      ),
                      Container(width: 1, height: 20, color: const Color(0xFFFFE5E5)),
                      TextButton(
                        onPressed: () => setState(() => _selectedExportIds.clear()),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF9CA3AF), padding: const EdgeInsets.symmetric(horizontal: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
              ElevatedButton.icon(
                onPressed: _exportPdf,
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('Export PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandCocoa,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
            const SizedBox(height: 18),
            if (widget.sweetNotes.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderLight),
                ),
                child: const Text(
                  'No messages match your search.',
                  style: TextStyle(color: textMuted, fontSize: 13),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.sweetNotes.length,
                itemBuilder: (context, i) {
                  final note = widget.sweetNotes[i];
                  final bool isRead = note['isRead'] == true;
                  final String docId = note['docId']?.toString() ?? '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(isSmallMobile ? 14 : 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isRead ? borderLight : brandCocoa,
                        width: isRead ? 1 : 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isSmallMobile
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Checkbox(
                                        value: _selectedExportIds.contains(docId),
                                        activeColor: brandCocoa,
                                        visualDensity: VisualDensity.compact,
                                        onChanged: (val) {
                                          setState(() {
                                            if (val == true) {
                                              _selectedExportIds.add(docId);
                                            } else {
                                              _selectedExportIds.remove(docId);
                                            }
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          note['name'] ?? 'Customer',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: textDark,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (docId.isNotEmpty)
                                        InkWell(
                                          onTap: () {
                                            FirebaseFirestore.instance
                                                .collection('sweet_notes')
                                                .doc(docId)
                                                .update({'isRead': !isRead});
                                          },
                                          child: Icon(
                                            isRead
                                                ? Icons.mark_email_read_outlined
                                                : Icons.mark_email_unread,
                                            size: 16,
                                            color: isRead ? textMuted : brandCocoa,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatDate(note['createdAt'] ?? note['date']),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: textMuted,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        value: _selectedExportIds.contains(docId),
                                        activeColor: brandCocoa,
                                        visualDensity: VisualDensity.compact,
                                        onChanged: (val) {
                                          setState(() {
                                            if (val == true) {
                                              _selectedExportIds.add(docId);
                                            } else {
                                              _selectedExportIds.remove(docId);
                                            }
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        note['name'] ?? 'Customer',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: textDark,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _formatDate(note['createdAt'] ?? note['date']),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: textMuted,
                                        ),
                                      ),
                                      if (docId.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        InkWell(
                                          onTap: () {
                                            FirebaseFirestore.instance
                                                .collection('sweet_notes')
                                                .doc(docId)
                                                .update({'isRead': !isRead});
                                          },
                                          child: Icon(
                                            isRead
                                                ? Icons.mark_email_read_outlined
                                                : Icons.mark_email_unread,
                                            size: 16,
                                            color: isRead ? textMuted : brandCocoa,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                        const SizedBox(height: 4),
                        Text(
                          note['email'] ?? '',
                          style: const TextStyle(fontSize: 11, color: brandCocoa),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          note['subject'] ?? 'Inquiry',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          note['message'] ?? '',
                          style: const TextStyle(fontSize: 12, color: textMuted),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  void _showBatchDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: Text(
            'Delete ${_selectedExportIds.length} Messages?',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)),
          ),
          content: const Text(
            'Are you sure you want to permanently delete the selected messages? This action cannot be undone.',
            style: TextStyle(color: textDark),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final batch = FirebaseFirestore.instance.batch();
                  for (final id in _selectedExportIds) {
                    final docRef = FirebaseFirestore.instance.collection('sweet_notes').doc(id);
                    batch.delete(docRef);
                  }
                  await batch.commit();
                  
                  if (context.mounted) {
                    setState(() {
                      _selectedExportIds.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Messages successfully deleted'), backgroundColor: Color(0xFF4CAF50)),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete: $e'), backgroundColor: const Color(0xFFD32F2F)),
                    );
                  }
                }
              },
              child: const Text('Delete All', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}