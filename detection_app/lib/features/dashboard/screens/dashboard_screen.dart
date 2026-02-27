import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/history_item.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/history_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../detection/screens/model_selection_sheet.dart';
import '../../history/screens/history_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (!auth.isGuest) {
        Provider.of<HistoryProvider>(context, listen: false).fetchAllData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isGuest = auth.isGuest;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      extendBody: true,
      
      // 1. ส่วนเนื้อหาหลัก
      body: IndexedStack(
        index: _currentIndex > 1 ? 0 : _currentIndex,
        children:[
          _buildDashboardTab(),
          const HistoryListScreen(),
        ],
      ),

      // 2. ปุ่ม FAB (กล้องวิเคราะห์)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 60, width: 60, 
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow:[
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4), 
              blurRadius: 10, 
              offset: const Offset(0, 4)
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (_) => const ModelSelectionSheet(),
            );
          },
          backgroundColor: AppColors.primary,
          elevation: 0, 
          shape: const CircleBorder(),
          child: const Icon(Icons.crop_free_rounded, color: Colors.white, size: 28),
        ),
      ),

      // 3. Bottom Nav Bar (ปรับให้มีกุญแจถ้าเป็น Guest)
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 15,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[
              Expanded(
                child: _buildTabItem(
                  icon: Icons.home_outlined, 
                  activeIcon: Icons.home_rounded, 
                  label: "Dashboard", 
                  index: 0,
                  isLocked: isGuest, // ส่งค่าว่าต้องล็อคหรือไม่
                ),
              ),
              
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const[
                    Text(
                      "Analysis", 
                      style: TextStyle(
                        color: AppColors.textDark, 
                        fontSize: 12, 
                        fontWeight: FontWeight.bold
                      )
                    ),
                    SizedBox(height: 4), 
                  ],
                ),
              ),
              
              Expanded(
                child: _buildTabItem(
                  icon: Icons.history_outlined, 
                  activeIcon: Icons.history_rounded, 
                  label: "History", 
                  index: 1,
                  isLocked: isGuest, // ส่งค่าว่าต้องล็อคหรือไม่
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget สร้างปุ่ม Tab (เพิ่มฟังก์ชัน Lock) ---
  Widget _buildTabItem({
    required IconData icon, 
    required IconData activeIcon, 
    required String label, 
    required int index,
    bool isLocked = false,
  }) {
    final safeCurrentIndex = _currentIndex > 1 ? 0 : _currentIndex;
    final isSelected = safeCurrentIndex == index;
    final color = isSelected ? Colors.blue : const Color(0xFF8F9BB3); 
    final displayIcon = isSelected ? activeIcon : icon;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              Icon(displayIcon, color: color, size: 26),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
          // ไอคอนกุญแจล็อค (แสดงเมื่อเป็น Guest)
          if (isLocked)
            Positioned(
              top: 0,
              right: 12, // ปรับตำแหน่งให้แปะมุมขวาบนของไอคอนหลัก
              child: Icon(Icons.lock_rounded, size: 12, color: Colors.grey.shade400),
            ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  // หน้า UI หลักของ Dashboard
  // ----------------------------------------------------------------------
  Widget _buildDashboardTab() {
    final auth = Provider.of<AuthProvider>(context);
    
    // --- โหมด Guest (UI ตาม Ref 100%) ---
    if (auth.isGuest) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: SafeArea(
          child: Column(
            children: [
              // Header แบบ Guest
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                      child: const Icon(Icons.lock_outline, size: 20, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Guest User", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                        Text("Limited Access", style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    )
                  ],
                ),
              ),
              
              // เนื้อหาตรงกลาง
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                    Container(
                      padding: const EdgeInsets.all(30), 
                      decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle), 
                      child: Icon(Icons.lock_outline_rounded, size: 60, color: Colors.grey.shade400)
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Dashboard Not Available", 
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0), 
                      child: Text(
                        "To access dashboard features, statistics, and history, please sign in with your account.", 
                        textAlign: TextAlign.center, 
                        style: TextStyle(color: Colors.grey.shade600, height: 1.5)
                      )
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF37E12), // สีส้มปุ่ม Sign In
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.login_rounded, size: 20),
                      label: const Text("Sign In to Continue", style: TextStyle(fontWeight: FontWeight.bold))
                    )
                  ],
                ),
              ),
              const SizedBox(height: 80), // เว้นที่ด้านล่างให้ Nav Bar
            ],
          ),
        ),
      );
    }

    // --- โหมด Member ---
    return Consumer<HistoryProvider>(
      builder: (context, provider, _) {
        return RefreshIndicator(
          onRefresh: () => provider.fetchAllData(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 60, bottom: 100), 
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                _buildHeader(auth.user),
                const SizedBox(height: 24),
                _buildTotalCard(provider.totalAnalyses),
                const SizedBox(height: 16),
                Row(
                  children:[
                    Expanded(child: _buildStatCard("Avg. Accuracy", "${provider.avgAccuracy.toStringAsFixed(1)}%")),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard("Today", "${provider.todayCount}")),
                  ],
                ),
                const SizedBox(height: 24),
                _buildCalendarSection(provider),
                const SizedBox(height: 24),
                const Text("Recent Analyses", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 16),
                if (provider.recentItems.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 30), 
                      child: Text("No analyses yet.", style: TextStyle(color: Colors.grey))
                    )
                  )
                else
                  ...provider.recentItems.map((item) => _buildRecentItem(item)),
              ],
            ),
          ),
        );
      }
    );
  }

  // --- Sub Widgets (Member) ---

  Widget _buildHeader(dynamic user) {
    final initial = user?.username.isNotEmpty == true ? user!.username[0].toUpperCase() : "U";
    final name = user?.username ?? "User";
    final dept = user?.department ?? "Laboratory";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:[
        Row(
          children:[
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300)
                ),
                alignment: Alignment.center,
                child: Text(initial, style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                Text(dept, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ],
        ),
        TextButton.icon(
          onPressed: () {
            Provider.of<AuthProvider>(context, listen: false).logout();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          },
          icon: const Icon(Icons.logout_rounded, color: AppColors.textDark, size: 18),
          label: const Text("Logout", style: TextStyle(color: AppColors.textDark, fontSize: 14)),
        )
      ],
    );
  }

  Widget _buildTotalCard(int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow:[
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          const Row(
            children:[
              Icon(Icons.trending_up_rounded, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text("Total Analyses Performed", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          Text(total.toString(), style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow:[
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildCalendarSection(HistoryProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow:[
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ]
      ),
      child: Column(
        children:[
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.week, 
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark),
              leftChevronIcon: Icon(Icons.chevron_left_rounded, color: AppColors.textDark),
              rightChevronIcon: Icon(Icons.chevron_right_rounded, color: AppColors.textDark),
            ),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Color(0xFFFFF3E0), shape: BoxShape.circle), 
              todayTextStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), 
              selectedTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              defaultTextStyle: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w500),
              weekendTextStyle: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w500),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.grey, fontSize: 13),
              weekendStyle: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          const Divider(height: 32, color: Color(0xFFEDF1F7)),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[
              Text(DateFormat('MMMM d, yyyy').format(_selectedDay), style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
              Row(
                children:[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children:[
                      const Text("Analyses", style: TextStyle(color: Colors.grey, fontSize: 11)),
                      Text(
                        provider.items.where((e) => isSameDay(e.timestamp, _selectedDay)).length.toString(), 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children:[
                      const Text("Avg. Accuracy", style: TextStyle(color: Colors.grey, fontSize: 11)),
                      Builder(builder: (ctx) {
                        final dayItems = provider.items.where((e) => isSameDay(e.timestamp, _selectedDay)).toList();
                        if (dayItems.isEmpty) return const Text("-", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark));
                        final avg = dayItems.fold(0.0, (sum, e) => sum + e.accuracy) / dayItems.length;
                        return Text("${avg.toStringAsFixed(1)}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark));
                      }),
                    ],
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRecentItem(HistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow:[
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children:[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
              const SizedBox(height: 6),
              Text(DateFormat('MMM d, hh:mm a').format(item.timestamp), style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children:[
              Text("${item.accuracy.toStringAsFixed(1)}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
              const SizedBox(height: 6),
              Text(item.modelUsed, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
}