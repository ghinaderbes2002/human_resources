import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_resources/controller/transaction_controller.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<int, String?> selectedTypes = {};
  final Map<int, DateTime?> selectedDates = {};
  final Map<int, DateTime?> selectedEndDates = {};
  final Map<int, TimeOfDay?> startTimes = {};
  final Map<int, TimeOfDay?> endTimes = {};
  final Map<int, TextEditingController> reasonControllers = {};
  final Map<int, TextEditingController> hoursControllers = {};
  final Map<int, DateTime?> advanceDates = {};

  final TextEditingController amountController = TextEditingController();
  final TransactionController controller = Get.put(TransactionController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    for (int i = 0; i < 2; i++) {
      selectedTypes[i] = null;
      selectedDates[i] = null;
      selectedEndDates[i] = null;
      startTimes[i] = null;
      endTimes[i] = null;
      reasonControllers[i] = TextEditingController();
      hoursControllers[i] = TextEditingController();
      advanceDates[i] = null;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var ctrl in reasonControllers.values) ctrl.dispose();
    for (var ctrl in hoursControllers.values) ctrl.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller.fetchTransactions();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "طلباتي",
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,

        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFFE85D4A),
                unselectedLabelColor: const Color(0xFF6B7280),
                indicatorColor: const Color(0xFFE85D4A),
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(text: "طلب إجازة"),
                  Tab(text: "طلب سلفة"),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [buildLeaveForm(context, 0), buildAdvanceForm(context, 1)],
      ),
    );
  }

  Widget buildLeaveForm(BuildContext context, int tabIndex) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE85D4A), Color(0xFFFF7A6B)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.event_note_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        "تقديم طلب إجازة",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // نوع الإجازة
                  _buildLabel("نوع الإجازة"),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1.5,
                      ),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedTypes[tabIndex],
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        hintText: "اختر نوع الإجازة",
                        hintStyle: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 15,
                        ),
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF6B7280),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "daily_leave",
                          child: Text("إجازة يومية"),
                        ),
                        DropdownMenuItem(
                          value: "hourly_leave",
                          child: Text("إجازة ساعية"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedTypes[tabIndex] = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // للإجازة اليومية
                  if (selectedTypes[tabIndex] == "daily_leave") ...[
                    _buildLabel("تاريخ البداية"),
                    const SizedBox(height: 10),
                    _buildModernDateSelector(
                      context,
                      "اختر تاريخ البداية",
                      selectedDates[tabIndex],
                      Icons.calendar_today_rounded,
                      () async {
                        final picked = await _showStyledDatePicker(context);
                        if (picked != null) {
                          setState(() => selectedDates[tabIndex] = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildLabel("تاريخ النهاية"),
                    const SizedBox(height: 10),
                    _buildModernDateSelector(
                      context,
                      "اختر تاريخ النهاية",
                      selectedEndDates[tabIndex],
                      Icons.calendar_today_rounded,
                      () async {
                        final picked = await _showStyledDatePicker(
                          context,
                          initialDate: selectedDates[tabIndex],
                        );
                        if (picked != null) {
                          setState(() => selectedEndDates[tabIndex] = picked);
                        }
                      },
                    ),
                  ] else if (selectedTypes[tabIndex] == "hourly_leave") ...[
                    _buildLabel("تاريخ الإجازة"),
                    const SizedBox(height: 10),
                    _buildModernDateSelector(
                      context,
                      "اختر تاريخ الإجازة",
                      selectedDates[tabIndex],
                      Icons.calendar_today_rounded,
                      () async {
                        final picked = await _showStyledDatePicker(context);
                        if (picked != null) {
                          setState(() => selectedDates[tabIndex] = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("وقت البداية"),
                              const SizedBox(height: 10),
                              _buildModernTimeSelector(
                                context,
                                "البداية",
                                startTimes[tabIndex],
                                () async {
                                  final picked = await _showStyledTimePicker(
                                    context,
                                  );
                                  if (picked != null) {
                                    setState(
                                      () => startTimes[tabIndex] = picked,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("وقت النهاية"),
                              const SizedBox(height: 10),
                              _buildModernTimeSelector(
                                context,
                                "النهاية",
                                endTimes[tabIndex],
                                () async {
                                  final picked = await _showStyledTimePicker(
                                    context,
                                  );
                                  if (picked != null) {
                                    setState(() => endTimes[tabIndex] = picked);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildLabel("عدد الساعات"),
                    const SizedBox(height: 10),
                    _buildModernTextField(
                      controller: hoursControllers[tabIndex]!,
                      hint: "أدخل عدد الساعات",
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.access_time_rounded,
                    ),
                  ],

                  const SizedBox(height: 20),
                  _buildLabel("سبب الإجازة"),
                  const SizedBox(height: 10),
                  _buildModernTextField(
                    controller: reasonControllers[tabIndex]!,
                    hint: "اكتب سبب طلب الإجازة...",
                    maxLines: 4,
                    prefixIcon: Icons.edit_note_rounded,
                  ),
                  const SizedBox(height: 28),

                  // زر الإرسال
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => _submitLeave(tabIndex),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE85D4A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: const Color(0xFFE85D4A).withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 20),
                          SizedBox(width: 10),
                          Text(
                            "إرسال الطلب",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // قسم الطلبات السابقة
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE85D4A), Color(0xFFFF7A6B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "طلبات الإجازة السابقة",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          GetBuilder<TransactionController>(
            builder: (ctrl) {
              if (ctrl.staterequest == Staterequest.loading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(
                      color: Color(0xFFE85D4A),
                      strokeWidth: 3,
                    ),
                  ),
                );
              }

              final leaves = ctrl.transactions
                  .where((tx) => tx.transactionType != "advance")
                  .toList();

              if (leaves.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.event_busy_rounded,
                  message: "لا يوجد طلبات إجازة",
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: leaves.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final tx = leaves[index];
                  return _buildTransactionCard(
                    icon: Icons.event_note_rounded,
                    title: tx.transactionType == "daily_leave"
                        ? "إجازة يومية"
                        : "إجازة ساعية",
                    subtitle: tx.reason ?? "",
                    status: tx.status ?? "قيد المعالجة",
                    // date: tx.createdAt,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildAdvanceForm(BuildContext context, int tabIndex) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE85D4A), Color(0xFFFF7A6B)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.payments_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        "تقديم طلب سلفة",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  _buildLabel("تاريخ السلفة"),
                  const SizedBox(height: 10),
                  _buildModernDateSelector(
                    context,
                    "اختر تاريخ السلفة",
                    advanceDates[tabIndex],
                    Icons.calendar_today_rounded,
                    () async {
                      final picked = await _showStyledDatePicker(context);
                      if (picked != null) {
                        setState(() => advanceDates[tabIndex] = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("المبلغ المطلوب"),
                  const SizedBox(height: 10),
                  _buildModernTextField(
                    controller: amountController,
                    hint: "أدخل المبلغ",
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.attach_money_rounded,
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("سبب السلفة"),
                  const SizedBox(height: 10),
                  _buildModernTextField(
                    controller: reasonControllers[tabIndex]!,
                    hint: "اكتب سبب طلب السلفة...",
                    maxLines: 4,
                    prefixIcon: Icons.edit_note_rounded,
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => _submitAdvance(tabIndex),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE85D4A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: const Color(0xFFE85D4A).withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 20),
                          SizedBox(width: 10),
                          Text(
                            "إرسال الطلب",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // قسم السلفات السابقة
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE85D4A), Color(0xFFFF7A6B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "السلفات السابقة",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          GetBuilder<TransactionController>(
            builder: (controller) {
              if (controller.staterequest == Staterequest.loading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(
                      color: Color(0xFFE85D4A),
                      strokeWidth: 3,
                    ),
                  ),
                );
              }

              final advances = controller.transactions
                  .where((tx) => tx.transactionType == "advance")
                  .toList();

              if (advances.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.payments_outlined,
                  message: "لا توجد سلفات سابقة",
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: advances.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final tx = advances[index];
                  return _buildTransactionCard(
                    icon: Icons.payments_rounded,
                    title: "سلفة مالية",
                    subtitle: tx.notes ?? "",
                    amount: tx.amount,
                    status: tx.status ?? "قيد المعالجة",
                    date: tx.date,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    IconData? prefixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: const Color(0xFFE85D4A), size: 20)
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: prefixIcon != null ? 12 : 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildModernDateSelector(
    BuildContext context,
    String hint,
    DateTime? selectedDate,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFE85D4A), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedDate == null
                    ? hint
                    : "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                style: TextStyle(
                  color: selectedDate == null
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF1A1A1A),
                  fontSize: 15,
                  fontWeight: selectedDate == null
                      ? FontWeight.w400
                      : FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFF6B7280),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTimeSelector(
    BuildContext context,
    String hint,
    TimeOfDay? selectedTime,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time_rounded,
              color: const Color(0xFFE85D4A),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              selectedTime == null ? hint : selectedTime.format(context),
              style: TextStyle(
                color: selectedTime == null
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF1A1A1A),
                fontSize: 14,
                fontWeight: selectedTime == null
                    ? FontWeight.w400
                    : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    double? amount,
    required String status,
    String? date,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getStatusColor(status).withOpacity(0.15),
                    _getStatusColor(status).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _getStatusColor(status), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (amount != null)
                    Text(
                      "المبلغ: $amount",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9CA3AF),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 40, color: const Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
      case 'موافق':
      case 'مقبول':
        return const Color(0xFF10B981);
      case 'rejected':
      case 'مرفوض':
        return const Color(0xFFEF4444);
      case 'pending':
      case 'قيد المعالجة':
      case 'منتظر':
      default:
        return const Color(0xFFF59E0B);
    }
  }

  Future<DateTime?> _showStyledDatePicker(
    BuildContext context, {
    DateTime? initialDate,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE85D4A),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1A1A1A),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
  }

  Future<TimeOfDay?> _showStyledTimePicker(BuildContext context) {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE85D4A),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1A1A1A),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
  }

  Future<void> _submitLeave(int tabIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final employeeId = prefs.getInt('employee_id') ?? 0;

    if (selectedTypes[tabIndex] == "daily_leave") {
      if (selectedDates[tabIndex] == null ||
          selectedEndDates[tabIndex] == null) {
        _showErrorSnackBar("الرجاء اختيار تاريخ البداية والنهاية");
        return;
      }

      int totalDays =
          selectedEndDates[tabIndex]!
              .difference(selectedDates[tabIndex]!)
              .inDays +
          1;

      await controller.createLeave(
        transactionType: "daily_leave",
        employeeId: employeeId,
        startDate:
            "${selectedDates[tabIndex]!.year}-${selectedDates[tabIndex]!.month.toString().padLeft(2, '0')}-${selectedDates[tabIndex]!.day.toString().padLeft(2, '0')}",
        endDate:
            "${selectedEndDates[tabIndex]!.year}-${selectedEndDates[tabIndex]!.month.toString().padLeft(2, '0')}-${selectedEndDates[tabIndex]!.day.toString().padLeft(2, '0')}",
        days: totalDays,
        reason: reasonControllers[tabIndex]!.text.trim(),
      );
    } else if (selectedTypes[tabIndex] == "hourly_leave") {
      if (selectedDates[tabIndex] == null ||
          startTimes[tabIndex] == null ||
          endTimes[tabIndex] == null) {
        _showErrorSnackBar("الرجاء إكمال جميع الحقول المطلوبة");
        return;
      }

      String startTimeStr =
          "${startTimes[tabIndex]!.hour.toString().padLeft(2, '0')}:${startTimes[tabIndex]!.minute.toString().padLeft(2, '0')}";
      String endTimeStr =
          "${endTimes[tabIndex]!.hour.toString().padLeft(2, '0')}:${endTimes[tabIndex]!.minute.toString().padLeft(2, '0')}";

      await controller.createLeave(
        transactionType: "hourly_leave",
        employeeId: employeeId,
        leaveDate:
            "${selectedDates[tabIndex]!.year}-${selectedDates[tabIndex]!.month.toString().padLeft(2, '0')}-${selectedDates[tabIndex]!.day.toString().padLeft(2, '0')}",
        startTime: startTimeStr,
        endTime: endTimeStr,
        hours: int.tryParse(hoursControllers[tabIndex]!.text.trim()),
        reason: reasonControllers[tabIndex]!.text.trim(),
      );
    } else {
      _showErrorSnackBar("الرجاء اختيار نوع الإجازة");
      return;
    }

    setState(() {
      selectedTypes[tabIndex] = null;
      selectedDates[tabIndex] = null;
      selectedEndDates[tabIndex] = null;
      startTimes[tabIndex] = null;
      endTimes[tabIndex] = null;
      reasonControllers[tabIndex]!.clear();
      hoursControllers[tabIndex]!.clear();
    });

    await controller.fetchTransactions();
    _showSuccessSnackBar("تم إرسال الطلب بنجاح");
  }

  Future<void> _submitAdvance(int tabIndex) async {
    if (amountController.text.trim().isEmpty ||
        reasonControllers[tabIndex]!.text.trim().isEmpty ||
        advanceDates[tabIndex] == null) {
      _showErrorSnackBar("الرجاء ملء جميع الحقول");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final employeeId = prefs.getInt('employee_id') ?? 0;

    await controller.createTransaction(
      transactionType: "advance",
      employeeId: employeeId,
      amount: double.tryParse(amountController.text) ?? 0,
      documentNumber: "ADV",
      date:
          "${advanceDates[tabIndex]!.year}-${advanceDates[tabIndex]!.month.toString().padLeft(2, '0')}-${advanceDates[tabIndex]!.day.toString().padLeft(2, '0')}",
      notes: reasonControllers[tabIndex]!.text.trim(),
    );

    await controller.fetchTransactions();

    setState(() {
      amountController.clear();
      reasonControllers[tabIndex]!.clear();
      advanceDates[tabIndex] = null;
    });

    _showSuccessSnackBar("تم إرسال الطلب بنجاح");
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
