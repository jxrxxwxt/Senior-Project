import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/dialog_utils.dart';
import '../../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  
  String? _department; 
  bool _isLoading = false;

  final List<String> _departments =[
    'Emergency Department',
    'Internal Medicine',
    'Surgery',
    'Pediatrics',
    'Obstetrics & Gynecology',
    'Laboratory',
    'Radiology',
    'Infectious Disease',
    'Pathology',
    'Microbiology'
  ];

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (_department == null) {
        DialogUtils.showError(context, "Please select a department");
        return;
      }
      if (_passCtrl.text != _confirmPassCtrl.text) {
        DialogUtils.showError(context, "Passwords do not match");
        return;
      }

      setState(() => _isLoading = true);
      try {
        await Provider.of<AuthProvider>(context, listen: false).register(
          _usernameCtrl.text,
          _emailCtrl.text,
          _department!,
          _passCtrl.text,
        );
        if (mounted) {
          DialogUtils.showSuccess(context, "Account created! Please sign in.");
          
          // delay ให้ user เห็น notification ก่อน pop กลับ
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) DialogUtils.showError(context, "Registration failed");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // ใช้ GestureDetector เพื่อปิด Dropdown เวลาจิ้มที่อื่น
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  // 1. Header
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back, color: AppColors.textDark, size: 20),
                        SizedBox(width: 8),
                        Text("Back to Login", style: TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text("Create Account", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  const Text("Join the Detection App community", style: TextStyle(color: AppColors.textGrey, fontSize: 15)),
                  const SizedBox(height: 32),
        
                  // 2. Form Fields
                  _buildLabel("Username"),
                  _buildTextField(
                    controller: _usernameCtrl,
                    hint: "Your username for sign in",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
        
                  _buildLabel("Email"),
                  _buildTextField(
                    controller: _emailCtrl,
                    hint: "your.email@hospital.com",
                    icon: Icons.mail_outline,
                  ),
                  const SizedBox(height: 16),
        
                  _buildLabel("Department"),
                  // ★ ใช้ Custom Dropdown ที่สร้างขึ้นเองด้านล่าง
                  _CustomDropdown(
                    items: _departments,
                    value: _department,
                    hint: "Select your department",
                    onChanged: (val) {
                      setState(() => _department = val);
                    },
                  ),
                  const SizedBox(height: 16),
        
                  _buildLabel("Password"),
                  _buildTextField(
                    controller: _passCtrl,
                    hint: "Create a secure password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),
        
                  _buildLabel("Confirm Password"),
                  _buildTextField(
                    controller: _confirmPassCtrl,
                    hint: "Confirm your password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 40),
        
                  // 3. Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, 
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading 
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Create Account", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark, fontSize: 13),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: AppColors.textDark, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.textGrey, size: 22),
        filled: true,
        fillColor: const Color(0xFFF7F9FC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEDF1F7))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
      ),
      validator: (value) {
         if (value == null || value.trim().isEmpty) return 'This field is required';
         return null;
      },
    );
  }
}

// ---------------------------------------------------------------------------
// ★ Custom Dropdown Widget (สร้างขึ้นใหม่เพื่อให้ได้ UI ตามที่ขอ)
// ---------------------------------------------------------------------------
class _CustomDropdown extends StatefulWidget {
  final List<String> items;
  final String? value;
  final String hint;
  final Function(String) onChanged;

  const _CustomDropdown({
    required this.items,
    required this.value,
    required this.hint,
    required this.onChanged,
  });

  @override
  State<_CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<_CustomDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _showDropdown();
    }
  }

  void _showDropdown() {
    // 1. หาตำแหน่งและขนาดของปุ่มกด
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // พื้นหลังใส กดแล้วปิด Dropdown
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeDropdown,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),
          // ตัว Dropdown Menu
          Positioned(
            width: size.width, // ความกว้างเท่ากับปุ่มเป๊ะๆ
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              // ★ offset (0, height + 8) คือเว้นช่องไฟ 8px จากด้านล่างปุ่ม
              offset: Offset(0, size.height + 8), 
              child: Material(
                elevation: 4,
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                shadowColor: Colors.black.withValues(alpha: 0.1),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 250), // จำกัดความสูง
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEDF1F7)),
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: widget.items.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      final isSelected = item == widget.value;
                      return InkWell(
                        onTap: () {
                          widget.onChanged(item);
                          _closeDropdown();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          color: isSelected ? const Color(0xFFF7F9FC) : Colors.white, // Highlight สีเทาอ่อน
                          child: Text(
                            item,
                            style: TextStyle(
                              color: isSelected ? AppColors.textDark : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    setState(() => _isOpen = false);
  }

  @override
  void dispose() {
    if (_isOpen) _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FC), // สีพื้นหลังเทาอ่อน
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isOpen ? AppColors.primary : const Color(0xFFEDF1F7), // เปลี่ยนสีขอบเมื่อเปิด
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.business_outlined, color: AppColors.textGrey, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    widget.value ?? widget.hint,
                    style: TextStyle(
                      color: widget.value == null ? AppColors.textGrey : AppColors.textDark,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Icon(
                _isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                color: AppColors.textGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}