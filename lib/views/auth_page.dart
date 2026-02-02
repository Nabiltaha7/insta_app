import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../utils/validators.dart';

class AuthPage extends GetView<AuthController> {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the controller property from GetView instead of Get.find
    // This ensures we get the correct controller instance

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Logo/Title with gradient
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.purple, Colors.pink, Colors.orange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.purple, Colors.pink, Colors.orange],
                      ).createShader(bounds),
                      child: const Text(
                        'Instagram',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Auth Form with modern design
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Obx(() => controller.isSignUp.value 
                  ? _buildSignUpForm(controller)
                  : _buildSignInForm(controller)
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Toggle between sign in and sign up
              Obx(() => TextButton(
                onPressed: controller.toggleAuthMode,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    children: [
                      TextSpan(
                        text: controller.isSignUp.value 
                          ? 'لديك حساب بالفعل؟ '
                          : 'ليس لديك حساب؟ ',
                      ),
                      TextSpan(
                        text: controller.isSignUp.value 
                          ? 'سجل دخول'
                          : 'أنشئ حساب جديد',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm(AuthController controller) {
    return Form(
      key: controller.signInFormKey,
      child: Column(
        children: [
          Text(
            'مرحباً بعودتك',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Get.theme.textTheme.headlineMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سجل دخولك للمتابعة',
            style: TextStyle(
              fontSize: 16,
              color: Get.theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),
          
          // Username field
          _buildModernTextField(
            controller: controller.usernameController,
            label: 'اسم المستخدم',
            icon: Icons.person_outline,
            validator: Validators.validateUsername,
            textDirection: TextDirection.ltr,
          ),
          
          const SizedBox(height: 20),
          
          // Password field
          _buildModernTextField(
            controller: controller.passwordController,
            label: 'كلمة المرور',
            icon: Icons.lock_outline,
            validator: Validators.validatePassword,
            textDirection: TextDirection.ltr,
            isPassword: true,
          ),
          
          const SizedBox(height: 32),
          
          // Sign in button
          Obx(() => _buildModernButton(
            onPressed: controller.isLoading.value ? null : controller.signIn,
            text: 'تسجيل الدخول',
            isLoading: controller.isLoading.value,
            isPrimary: true,
          )),
        ],
      ),
    );
  }

  Widget _buildSignUpForm(AuthController controller) {
    return Form(
      key: controller.signUpFormKey,
      child: Column(
        children: [
          Text(
            'إنشاء حساب جديد',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Get.theme.textTheme.headlineMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'انضم إلى مجتمعنا اليوم',
            style: TextStyle(
              fontSize: 16,
              color: Get.theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),
          
          // Full name field
          _buildModernTextField(
            controller: controller.fullNameController,
            label: 'الاسم الكامل',
            icon: Icons.person_outline,
            validator: Validators.validateFullName,
            textDirection: TextDirection.rtl,
          ),
          
          const SizedBox(height: 20),
          
          // Username field
          _buildModernTextField(
            controller: controller.usernameController,
            label: 'اسم المستخدم',
            icon: Icons.alternate_email,
            validator: Validators.validateUsername,
            textDirection: TextDirection.ltr,
          ),
          
          const SizedBox(height: 20),
          
          // Email field
          _buildModernTextField(
            controller: controller.emailController,
            label: 'البريد الإلكتروني',
            icon: Icons.email_outlined,
            validator: Validators.validateEmail,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
          ),
          
          const SizedBox(height: 20),
          
          // Password field
          _buildModernTextField(
            controller: controller.passwordController,
            label: 'كلمة المرور',
            icon: Icons.lock_outline,
            validator: Validators.validatePassword,
            textDirection: TextDirection.ltr,
            isPassword: true,
          ),
          
          const SizedBox(height: 32),
          
          // Sign up button
          Obx(() => _buildModernButton(
            onPressed: controller.isLoading.value ? null : controller.signUp,
            text: 'إنشاء حساب',
            isLoading: controller.isLoading.value,
            isPrimary: true,
          )),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextDirection? textDirection,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Get.theme.dividerColor.withValues(alpha: 0.2),
        ),
        color: Get.theme.cardColor,
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: isPassword ? !this.controller.isPasswordVisible.value : obscureText,
        keyboardType: keyboardType,
        textDirection: textDirection,
        style: TextStyle(
          fontSize: 16,
          color: Get.theme.textTheme.bodyLarge?.color,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Get.theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.blue,
              size: 20,
            ),
          ),
          suffixIcon: isPassword ? Obx(() => IconButton(
            onPressed: this.controller.togglePasswordVisibility,
            icon: Icon(
              this.controller.isPasswordVisible.value 
                ? Icons.visibility_off 
                : Icons.visibility,
              color: Colors.grey.shade600,
            ),
          )) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
      ),
    );
  }

  Widget _buildModernButton({
    required VoidCallback? onPressed,
    required String text,
    bool isLoading = false,
    bool isPrimary = true,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isPrimary ? const LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ) : null,
        color: isPrimary ? null : Get.theme.cardColor,
        border: isPrimary ? null : Border.all(
          color: Get.theme.dividerColor.withValues(alpha: 0.2),
        ),
        boxShadow: isPrimary ? [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            alignment: Alignment.center,
            child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isPrimary 
                      ? Colors.white 
                      : Get.theme.textTheme.bodyLarge?.color,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}