import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SecurityPermissionsTab extends StatefulWidget {
  final String currentRole;
  final String adminEmail;

  const SecurityPermissionsTab({
    super.key,
    required this.currentRole,
    required this.adminEmail,
  });

  @override
  State<SecurityPermissionsTab> createState() => _SecurityPermissionsTabState();
}

class _SecurityPermissionsTabState extends State<SecurityPermissionsTab> {
  static const Color brandCocoa = Color(0xFF8C4A27);
  static const Color darkEspresso = Color(0xFF251811);
  static const Color textDark = Color(0xFF3A2312);
  static const Color textMuted = Color(0xFF6E5D53);
  static const Color borderLight = Color(0xFFEFE3D5);
  static const Color wellBg = Color(0xFFF4EDE6);

  final CollectionReference<Map<String, dynamic>> _usersCollection =
      FirebaseFirestore.instance.collection('users');

  String _normalizeRole(String? role) {
    if (role == null) return 'baker_admin';
    final lower = role.toLowerCase().trim();
    if (lower.contains('super')) return 'super_admin';
    if (lower.contains('dispatch') || lower.contains('rider'))
      return 'order_dispatcher';
    return 'baker_admin';
  }

  String _formatRoleLabel(String roleKey) {
    switch (roleKey) {
      case 'super_admin':
        return 'Super Admin';
      case 'order_dispatcher':
        return 'Order Dispatcher';
      case 'baker_admin':
      default:
        return 'Baker Admin';
    }
  }

  void _showAddAccountDialog(BuildContext context) {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    String selectedRole = 'baker_admin';
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: const Color(0xFFFDFBF7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.person_add_alt_1_outlined,
                  color: brandCocoa,
                  size: 22,
                ),
                SizedBox(width: 8),
                Text(
                  'Add Staff Account',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Staff Email Address *',
                      hintText: 'e.g. baker2@nysebites.com',
                      prefixIcon: Icon(Icons.email_outlined, size: 18),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Staff Full Name / Label',
                      hintText: 'e.g. Morning Shift Baker',
                      prefixIcon: Icon(Icons.badge_outlined, size: 18),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Assign Role & Permissions:',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'super_admin',
                        child: Text('Super Admin (Full Access / Owner)'),
                      ),
                      DropdownMenuItem(
                        value: 'baker_admin',
                        child: Text('Baker Admin (Kitchen & Daily Drops)'),
                      ),
                      DropdownMenuItem(
                        value: 'order_dispatcher',
                        child: Text('Order Dispatcher (Rider / Delivery)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedRole = val);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(dialogCtx),
                child: const Text('Cancel', style: TextStyle(color: textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandCocoa,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final email = emailController.text.trim().toLowerCase();
                        final name = nameController.text.trim();
                        if (email.isEmpty || !email.contains('@')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please enter a valid email address',
                              ),
                            ),
                          );
                          return;
                        }

                        setModalState(() => isSubmitting = true);
                        try {
                          String desc = 'Kitchen & Daily Drops Desk';
                          if (selectedRole == 'super_admin') {
                            desc = 'Full Access (Owner)';
                          } else if (selectedRole == 'order_dispatcher') {
                            desc = 'Delivery & Handover Logistics';
                          }

                          await _usersCollection.doc(email).set({
                            'email': email,
                            'name': name.isEmpty
                                ? email.split('@').first
                                : name,
                            'role': selectedRole,
                            'description': desc,
                            'createdAt': FieldValue.serverTimestamp(),
                          }, SetOptions(merge: true));

                          if (!dialogCtx.mounted) return;
                          Navigator.pop(dialogCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF2E7D32),
                              content: Text('✨ Added $email successfully!'),
                            ),
                          );
                        } catch (e) {
                          setModalState(() => isSubmitting = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFFD32F2F),
                              content: Text('Failed to add account: $e'),
                            ),
                          );
                        }
                      },
                child: Text(isSubmitting ? 'Saving...' : 'Add Account'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditRoleDialog(BuildContext context, String email, String rawRole) {
    String selectedRole = _normalizeRole(rawRole);
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: const Color(0xFFFDFBF7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.manage_accounts_outlined,
                  color: brandCocoa,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Change Role for $email',
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select updated role & permissions:',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'super_admin',
                      child: Text('Super Admin (Full Access / Owner)'),
                    ),
                    DropdownMenuItem(
                      value: 'baker_admin',
                      child: Text('Baker Admin (Kitchen & Daily Drops)'),
                    ),
                    DropdownMenuItem(
                      value: 'order_dispatcher',
                      child: Text('Order Dispatcher (Rider / Delivery)'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedRole = val);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(dialogCtx),
                child: const Text('Cancel', style: TextStyle(color: textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandCocoa,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: isSubmitting
                    ? null
                    : () async {
                        setModalState(() => isSubmitting = true);
                        try {
                          String desc = 'Kitchen & Daily Drops Desk';
                          if (selectedRole == 'super_admin') {
                            desc = 'Full Access (Owner)';
                          } else if (selectedRole == 'order_dispatcher') {
                            desc = 'Delivery & Handover Logistics';
                          }

                          await _usersCollection.doc(email).set({
                            'role': selectedRole,
                            'description': desc,
                            'updatedAt': FieldValue.serverTimestamp(),
                          }, SetOptions(merge: true));

                          if (!dialogCtx.mounted) return;
                          Navigator.pop(dialogCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF2E7D32),
                              content: Text(
                                '✨ Updated $email to ${_formatRoleLabel(selectedRole)}!',
                              ),
                            ),
                          );
                        } catch (e) {
                          setModalState(() => isSubmitting = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFFD32F2F),
                              content: Text('Failed to update role: $e'),
                            ),
                          );
                        }
                      },
                child: Text(isSubmitting ? 'Updating...' : 'Update Role'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteAccount(String email) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFDFBF7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Revoke Account Access?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: textDark,
          ),
        ),
        content: Text(
          'Are you sure you want to remove "$email"? This staff member will immediately lose access to the bakery console.',
          style: const TextStyle(fontSize: 12.5, color: textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Access'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _usersCollection.doc(email).delete();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF2E7D32),
            content: Text('Access revoked for $email'),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFD32F2F),
            content: Text('Failed to remove account: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSuperAdmin =
        _normalizeRole(widget.currentRole) == 'super_admin';

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 750;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Active Session Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderLight),
                boxShadow: [
                  BoxShadow(
                    color: darkEspresso.withOpacity(0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAF2E9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE5D5C5),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.shield_outlined,
                                color: brandCocoa,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.adminEmail,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13.5,
                                      color: textDark,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSuperAdmin
                                          ? const Color(0xFFE8F5E9)
                                          : const Color(0xFFFFF3E0),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _formatRoleLabel(
                                        _normalizeRole(widget.currentRole),
                                      ).toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                        color: isSuperAdmin
                                            ? const Color(0xFF2E7D32)
                                            : const Color(0xFFE65100),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Role-Based Access Control (RBAC) enforced via Firebase Authentication & Firestore.',
                          style: TextStyle(fontSize: 11, color: textMuted),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAF2E9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE5D5C5),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.shield_outlined,
                                color: brandCocoa,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Active Session: ${widget.adminEmail}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14.5,
                                        color: textDark,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSuperAdmin
                                            ? const Color(0xFFE8F5E9)
                                            : const Color(0xFFFFF3E0),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        _formatRoleLabel(
                                          _normalizeRole(widget.currentRole),
                                        ).toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: isSuperAdmin
                                              ? const Color(0xFF2E7D32)
                                              : const Color(0xFFE65100),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  'Role-Based Access Control (RBAC) enforced via Firebase Authentication & Firestore.',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock_clock,
                                size: 14,
                                color: Color(0xFF2E7D32),
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Auth Token Valid',
                                style: TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 22),

            // 2. RBAC Permission Matrix (Full width on Web, Scrollable on Mobile)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderLight),
              ),
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Role Permission Matrix',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Detailed breakdown of accessible modules, view states, and action restrictions per role.',
                    style: TextStyle(fontSize: 11.5, color: textMuted),
                  ),
                  const SizedBox(height: 18),

                  isMobile
                      ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: 650,
                            child: _buildPermissionTable(),
                          ),
                        )
                      : _buildPermissionTable(),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // 3. Registered Staff Accounts Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderLight),
              ),
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Registered Staff Accounts',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Authorized accounts granted backend bakery access.',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: textMuted,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (isSuperAdmin)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: brandCocoa,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 11,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () =>
                                      _showAddAccountDialog(context),
                                  icon: const Icon(Icons.person_add, size: 16),
                                  label: const Text(
                                    'Add Staff Account',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Registered Staff Accounts (Firestore `users`)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: textDark,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Authorized accounts granted access to backend bakery consoles.',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: textMuted,
                                  ),
                                ),
                              ],
                            ),
                            if (isSuperAdmin)
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: brandCocoa,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 11,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () => _showAddAccountDialog(context),
                                icon: const Icon(Icons.person_add, size: 16),
                                label: const Text(
                                  'Add Staff Account',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                  const SizedBox(height: 16),

                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _usersCollection.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: CircularProgressIndicator(color: brandCocoa),
                          ),
                        );
                      }

                      final docs = snapshot.data?.docs ?? [];

                      if (docs.isEmpty) {
                        final defaultUsers = [
                          {
                            'email': 'superadmin@nysebites.com',
                            'role': 'super_admin',
                            'description': 'Full Access (Owner)',
                          },
                          {
                            'email': 'admin@nysebites.com',
                            'role': 'baker_admin',
                            'description': 'Kitchen & Daily Drops Desk',
                          },
                          {
                            'email': 'rider@nysebites.com',
                            'role': 'order_dispatcher',
                            'description': 'Delivery & Handover Logistics',
                          },
                        ];

                        return Column(
                          children: defaultUsers.map((u) {
                            return Column(
                              children: [
                                _buildAccountRow(
                                  email: u['email']!,
                                  role: u['role']!,
                                  desc: u['description']!,
                                  isSuperAdminViewer: isSuperAdmin,
                                  isMobile: isMobile,
                                ),
                                const Divider(color: borderLight, height: 20),
                              ],
                            );
                          }).toList(),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) =>
                            const Divider(color: borderLight, height: 20),
                        itemBuilder: (context, index) {
                          final data = docs[index].data();
                          final email = data['email'] ?? docs[index].id;
                          final role =
                              data['role']?.toString() ?? 'baker_admin';
                          final desc =
                              data['description'] ?? 'Bakery Console Staff';

                          return _buildAccountRow(
                            email: email,
                            role: role,
                            desc: desc,
                            isSuperAdminViewer: isSuperAdmin,
                            isMobile: isMobile,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPermissionTable() {
    return Table(
      border: TableBorder.all(
        color: const Color(0xFFEFE4D6),
        borderRadius: BorderRadius.circular(10),
      ),
      columnWidths: const {
        0: FlexColumnWidth(2.2),
        1: FlexColumnWidth(1.8),
        2: FlexColumnWidth(1.8),
        3: FlexColumnWidth(1.8),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFFAF4EE)),
          children: [
            _tableHeader('MODULE / CAPABILITY'),
            _tableHeader('SUPER ADMIN (OWNER)'),
            _tableHeader('BAKER ADMIN (KITCHEN)'),
            _tableHeader('RIDER (DISPATCH)'),
          ],
        ),
        _permissionRow(
          'Live Kitchen Pipeline',
          'Full (Verify, Reject, Bake)',
          'Bake & Pack Only',
          'Pickup & Delivery Only',
        ),
        _permissionRow(
          'Payment Verification',
          'Full (GCash / QRPh / COD)',
          'View Status Only',
          'COD Collect Only',
        ),
        _permissionRow(
          'Custom Cake 3D Specs',
          'Full Inspection & Approval',
          'Full Inspection & Prep',
          'No Access',
        ),
        _permissionRow(
          'Menu & SKU Creation',
          'Full (Add/Edit Drops)',
          'Stock Stepper Only',
          'No Access',
        ),
        _permissionRow(
          'Sales Analytics & Reports',
          'Full Financial Access',
          'No Access',
          'No Access',
        ),
        _permissionRow(
          'Staff Accounts & Roles',
          'Full Control (Add/Edit/Revoke)',
          'No Access',
          'No Access',
        ),
        _permissionRow(
          'Storefront Open/Close',
          'Full Toggle',
          'No Access',
          'No Access',
        ),
      ],
    );
  }

  Widget _buildAccountRow({
    required String email,
    required String role,
    required String desc,
    required bool isSuperAdminViewer,
    required bool isMobile,
  }) {
    final normalized = _normalizeRole(role);
    final displayLabel = _formatRoleLabel(normalized);

    IconData icon = Icons.cookie_outlined;
    Color roleColor = brandCocoa;

    if (normalized == 'super_admin') {
      icon = Icons.stars_rounded;
      roleColor = const Color(0xFF2E7D32);
    } else if (normalized == 'order_dispatcher') {
      icon = Icons.two_wheeler_outlined;
      roleColor = const Color(0xFFC27803);
    }

    final bool isCurrentSelf =
        email.toLowerCase() == widget.adminEmail.toLowerCase();
    final bool isSuperAdminAccount = normalized == 'super_admin';
    final bool isRootSuperAdmin =
        email.toLowerCase() == 'superadmin@nysebites.com';
    final bool isProtectedFromDelete =
        isCurrentSelf || isRootSuperAdmin || isSuperAdminAccount;

    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: roleColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                email,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                  color: textDark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isCurrentSelf) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'YOU',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          desc,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: wellBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      displayLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10.5,
                        color: roleColor,
                      ),
                    ),
                  ),
                  if (isSuperAdminViewer)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isSuperAdminAccount)
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 17,
                              color: brandCocoa,
                            ),
                            tooltip: 'Change Role',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () =>
                                _showEditRoleDialog(context, email, role),
                          ),
                        if (!isProtectedFromDelete) ...[
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 17,
                              color: Color(0xFFD32F2F),
                            ),
                            tooltip: 'Revoke Access',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _deleteAccount(email),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ],
          )
        : Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: roleColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          email,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: textDark,
                          ),
                        ),
                        if (isCurrentSelf) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'YOU',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      desc,
                      style: const TextStyle(fontSize: 11, color: textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: wellBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  displayLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: roleColor,
                  ),
                ),
              ),
              if (isSuperAdminViewer) ...[
                if (!isSuperAdminAccount) ...[
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: brandCocoa,
                    ),
                    tooltip: 'Change Staff Role',
                    onPressed: () => _showEditRoleDialog(context, email, role),
                  ),
                ],
                if (!isProtectedFromDelete)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Color(0xFFD32F2F),
                    ),
                    tooltip: 'Revoke Access',
                    onPressed: () => _deleteAccount(email),
                  ),
              ],
            ],
          );
  }

  Widget _tableHeader(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: brandCocoa,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  TableRow _permissionRow(
    String feature,
    String superVal,
    String bakerVal,
    String riderVal,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Text(
            feature,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: textDark,
            ),
          ),
        ),
        _statusCell(superVal, isAllowed: true),
        _statusCell(bakerVal, isAllowed: !bakerVal.contains('No Access')),
        _statusCell(riderVal, isAllowed: !riderVal.contains('No Access')),
      ],
    );
  }

  Widget _statusCell(String text, {required bool isAllowed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(
            isAllowed ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 14,
            color: isAllowed
                ? const Color(0xFF2E7D32)
                : const Color(0xFFB0A39B),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isAllowed ? FontWeight.w600 : FontWeight.normal,
                color: isAllowed ? textDark : textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
