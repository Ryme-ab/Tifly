import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/features/navigation/app_router.dart';
import '../../data/models/user_model.dart';
import '../cubit/signin_cubit.dart';
import '../cubit/signin_state.dart';
import 'login_screen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // SHOW MESSAGE
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sign Up Successful!')),
            );

            // NAVIGATE TO HOME
            Navigator.pushReplacementNamed(context, AppRoutes.maintabscreen);
          }

          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// LOGO
                  Center(
                    child: Column(
                      children: [
                        Image.asset("assets/logo.png", height: 60),
                        const SizedBox(height: 10),
                        const Text(
                          "TIFLI",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE91E63),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// TITLE
                  const Text(
                    "Create Your Account",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Start your journey with Dreamland Care.\nEffortlessly manage your child’s well-being.",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),

                  const SizedBox(height: 30),

                  /// FORM CONTAINER
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE6EA),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        // FULL NAME
                        _buildTextField(
                          label: "Full Name",
                          controller: fullNameController,
                          hint: "Joshua Davis",
                          icon: Icons.person_outline,
                          validator: (value) =>
                              value!.isEmpty ? "Full name required" : null,
                        ),
                        const SizedBox(height: 16),

                        // EMAIL
                        _buildTextField(
                          label: "Email Address",
                          controller: emailController,
                          hint: "your.email@example.com",
                          icon: Icons.email_outlined,
                          validator: (value) =>
                              value!.contains("@") ? null : "Invalid email",
                        ),
                        const SizedBox(height: 16),

                        // PHONE
                        _buildTextField(
                          label: "Phone Number",
                          controller: phoneController,
                          hint: "0567889999",
                          icon: Icons.phone_outlined,
                          validator: (value) =>
                              value!.length < 8 ? "Invalid phone number" : null,
                        ),
                        const SizedBox(height: 16),

                        // PASSWORD
                        _buildPasswordField(
                          label: "Password",
                          controller: passwordController,
                          obscure: _obscurePassword,
                          toggle: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          validator: (value) =>
                              value!.length < 6 ? "Password too short" : null,
                        ),
                        const SizedBox(height: 16),

                        // CONFIRM PASSWORD
                        _buildPasswordField(
                          label: "Confirm Password",
                          controller: confirmPasswordController,
                          obscure: _obscureConfirmPassword,
                          toggle: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          validator: (value) => value != passwordController.text
                              ? "Passwords do not match"
                              : null,
                        ),

                        const SizedBox(height: 25),

                        /// SIGN UP BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE91E63),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: state is AuthLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      final user = UserModel(
                                        fullName: fullNameController.text,
                                        email: emailController.text,
                                        phone: phoneController.text,
                                        pwd: passwordController.text,
                                      );

                                      context.read<AuthCubit>().signUp(user);
                                    }
                                  },
                            child: state is AuthLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Sign Up Now",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// LOGIN REDIRECT
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Login here",
                            style: TextStyle(color: Color(0xFFE91E63)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// GENERIC TEXT FIELD
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  /// PASSWORD FIELD
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback toggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: toggle,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
