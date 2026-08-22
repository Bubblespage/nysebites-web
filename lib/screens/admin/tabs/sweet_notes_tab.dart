import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SweetNotesTab extends StatelessWidget {
  final List<Map<String, dynamic>> sweetNotes;

  const SweetNotesTab({super.key, required this.sweetNotes});

  static const Color brandCocoa = Color(0xFF8C4A27);
  static const Color textDark = Color(0xFF3A2312);
  static const Color textMuted = Color(0xFF6E5D53);
  static const Color borderLight = Color(0xFFEFE3D5);

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
            const Text(
              'Sweet Notes & Customer Inquiries',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'Messages and customer catering inquiries received from the Sweet Note form',
              style: TextStyle(fontSize: 11.5, color: textMuted),
            ),
            const SizedBox(height: 18),
            if (sweetNotes.isEmpty)
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
                itemCount: sweetNotes.length,
                itemBuilder: (context, i) {
                  final note = sweetNotes[i];
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
}