// lib/presentation/screens/auth/login_screen.dart - نسخة متجاوبة محسنة
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/arabic_text_field.dart'; // أضف هذا الاستيراد
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _scrollController = ScrollController();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.login(_emailController.text, _passwordController.text);

      if (userProvider.error == null) {
        if (mounted) context.go('/');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(userProvider.error!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginAsGuest() async {
    setState(() => _isLoading = true);
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loginAsGuest();
      
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // تهيئة أدوات الاستجابة
    ResponsiveUtils.init(context);
    
    // استخدام الامتداد للحصول على القيم المتجاوبة
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight - MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      body: Stack(
        children: [
          // خلفية متدرجة
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [
                  AppColors.primary,
                  Colors.white,
                ],
                stops: [0.0, 0.5],
              ),
            ),
          ),
          
          // المحتوى
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: context.responsivePadding(
                          horizontal: context.isSmallPhone ? 16 : 24,
                          vertical: context.isSmallPhone ? 16 : 24,
                        ),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // مساحة علوية متكيفة
                                SizedBox(height: context.adaptive(20)),
                                
                                // الشعار
                                if (!isKeyboardOpen || !context.isSmallPhone)
                                  Center(
                                    child: Column(
                                      children: [
                                        Hero(
                                          tag: 'logo',
                                          child: Container(
                                            width: context.adaptive(100),
                                            height: context.adaptive(100),
                                            padding: EdgeInsets.all(context.adaptive(16)),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.primary.withOpacity(0.3),
                                                  blurRadius: 15,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: Image.asset(
                                              AppConstants.logoPath,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: context.sm),
                                        Text(
                                          'Velora',
                                          style: TextStyle(
                                            fontSize: context.fontSize(32),
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        SizedBox(height: context.xs),
                                        Text(
                                          'استكشف فلسطين',
                                          style: TextStyle(
                                            fontSize: context.fontSize(18),
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                
                                SizedBox(height: context.adaptive(32)),

                                // النموذج
                                Expanded(
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'تسجيل الدخول',
                                          style: TextStyle(
                                            fontSize: context.fontSize(24),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: context.xs),
                                        Text(
                                          'أدخل بياناتك للوصول إلى حسابك',
                                          style: TextStyle(
                                            fontSize: context.fontSize(14),
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        SizedBox(height: context.md),
                                        
                                        // البريد الإلكتروني
                                        ArabicTextField(
                                          controller: _emailController,
                                          labelText: 'البريد الإلكتروني',
                                          hintText: 'أدخل بريدك الإلكتروني',
                                          prefixIcon: PhosphorIcons.envelope,
                                          keyboardType: TextInputType.emailAddress,
                                          validator: Validators.validateEmail,
                                          textInputAction: TextInputAction.next,
                                        ),
                                        SizedBox(height: context.sm),
                                        
                                        // كلمة المرور
                                        ArabicTextField(
                                          controller: _passwordController,
                                          labelText: 'كلمة المرور',
                                          hintText: 'أدخل كلمة المرور',
                                          prefixIcon: PhosphorIcons.lock,
                                          obscureText: !_isPasswordVisible,
                                          validator: Validators.validatePassword,
                                          textInputAction: TextInputAction.done,
                                          onFieldSubmitted: (_) => _login(),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isPasswordVisible
                                                  ? PhosphorIcons.eye_slash
                                                  : PhosphorIcons.eye,
                                              size: context.iconSize(),
                                              color: AppColors.textSecondary,
                                            ),
                                            onPressed: _togglePasswordVisibility,
                                          ),
                                        ),
                                        SizedBox(height: context.xs),
                                        
                                        // تذكرني ونسيت كلمة المرور
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: Checkbox(
                                                    value: _rememberMe,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _rememberMe = value ?? false;
                                                      });
                                                    },
                                                    activeColor: AppColors.primary,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: context.xs),
                                                Text(
                                                  'تذكرني',
                                                  style: TextStyle(
                                                    fontSize: context.fontSize(14),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                // نسيت كلمة المرور
                                              },
                                              child: Text(
                                                'نسيت كلمة المرور؟',
                                                style: TextStyle(
                                                  fontSize: context.fontSize(14),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: context.md),
                                        
                                        // زر تسجيل الدخول - محدث
                                        SizedBox(
                                          width: double.infinity,
                                          height: 54,
                                          child: ElevatedButton(
                                            onPressed: _isLoading ? null : _login,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              foregroundColor: Colors.white,
                                              elevation: 2,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 24,
                                                vertical: 0,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text(
                                              'تسجيل الدخول',
                                              style: TextStyle(
                                                fontSize: context.fontSize(16),
                                                fontWeight: FontWeight.bold,
                                                height: 1.3,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: context.sm),
                                        
                                        // زر الدخول كضيف - محدث
                                        SizedBox(
                                          width: double.infinity,
                                          height: 54,
                                          child: OutlinedButton(
                                            onPressed: _isLoading ? null : _loginAsGuest,
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppColors.primary,
                                              side: const BorderSide(
                                                color: AppColors.primary,
                                                width: 1.5,
                                              ),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 24,
                                                vertical: 0,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text(
                                              'الدخول كضيف',
                                              style: TextStyle(
                                                fontSize: context.fontSize(16),
                                                fontWeight: FontWeight.bold,
                                                height: 1.3,
                                              ),
                                            ),
                                          ),
                                        ),
                                        
                                        const Spacer(),
                                        // رابط التسجيل
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'ليس لديك حساب؟',
                                              style: TextStyle(
                                                fontSize: context.fontSize(14),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) => const RegisterScreen(),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                'إنشاء حساب',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: context.fontSize(14),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // مؤشر التحميل
          if (_isLoading)
            const LoadingIndicator(
              isOverlay: true,
              message: 'جاري تسجيل الدخول...',
            ),
        ],
      ),
    );
  }
}