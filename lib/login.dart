// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application/admin/dashboard.dart';
// import 'package:flutter_application/register.dart';
// import 'package:flutter_application/theme/app_theme.dart';
// import 'package:flutter_application/userhome.dart';
// import 'package:google_fonts/google_fonts.dart';

// class LoginPage extends StatefulWidget {
//    LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   bool _savePassword = false;

//   Future<void> login() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       final authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );

//       final userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(authResult.user!.uid)
//           .get();

//       final role = userDoc.data()?['role'] ?? 'user';
//       if (role == 'admin') {
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (_) => AdminDashboard()));
//       } else {
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (_) => CarModelDashboard()));
//       }
//     } on FirebaseAuthException catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.message ?? 'Login failed')),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Widget _buildBackground() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppTheme.primaryColor.withOpacity(0.85),
//             AppTheme.secondaryColor.withOpacity(0.85),
//             AppTheme.primaryColor.withOpacity(0.95),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           stops:  [0.0, 0.5, 1.0],
//           // For luxury effect, add some subtle stops & color opacity changes
//         ),
//       ),
//     );
//   }

//   Widget _buildLoginCard(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, raints) {
//         // Limit max width on large screens for better UI
//         double cardWidth = raints.maxWidth < 600 ? raints.maxWidth * 0.9 : 450;

//         return Center(
//           child: Container(
//             width: cardWidth,
//             padding:  EdgeInsets.symmetric(horizontal: 24, vertical: 32),
//             child: Card(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//               elevation: 12,
//               child: Padding(
//                 padding:  EdgeInsets.all(24.0),
//                 child: SingleChildScrollView(
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           "Login Account",
//                           style: GoogleFonts.poppins(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             color: AppTheme.primaryColor,
//                           ),
//                         ),
//                          SizedBox(height: 8),
//                         Text(
//                           "Access your account with your credentials.",
//                           style: GoogleFonts.poppins(
//                             fontSize: 14,
//                             color: AppTheme.textSecondary,
//                           ),
//                         ),
//                          SizedBox(height: 24),
//                         TextFormField(
//                           controller: _emailController,
//                           decoration:  InputDecoration(
//                             labelText: 'Email Address',
//                             prefixIcon: Icon(Icons.email),
//                           ),
//                           validator: (val) =>
//                               val == null || val.isEmpty ? 'Enter email' : null,
//                         ),
//                          SizedBox(height: 16),
//                         TextFormField(
//                           controller: _passwordController,
//                           obscureText: true,
//                           decoration:  InputDecoration(
//                             labelText: 'Password',
//                             prefixIcon: Icon(Icons.lock),
//                           ),
//                           validator: (val) =>
//                               val == null || val.isEmpty ? 'Enter password' : null,
//                         ),
//                          SizedBox(height: 16),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Checkbox(
//                                   value: _savePassword,
//                                   onChanged: (val) {
//                                     setState(() {
//                                       _savePassword = val ?? false;
//                                     });
//                                   },
//                                 ),
//                                  Text("Save Password"),
//                               ],
//                             ),
//                             // TextButton(
//                             //   onPressed: () {
//                             //     // TODO: handle forgot password
//                             //   },
//                             //   child:  Text("Forgot Password?"),
//                             // )
//                           ],
//                         ),
//                          SizedBox(height: 16),
//                         _isLoading
//                             ?  Center(child: CircularProgressIndicator())
//                             : SizedBox(
//                                 width: double.infinity,
//                                 height: 50,
//                                 child: ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: AppTheme.primaryColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                   ),
//                                   onPressed: login,
//                                   child:  Text(
//                                     "Login Account",
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                          SizedBox(height: 16),
//                         TextButton(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (_) =>  UserRegisterScreen()),
//                             );
//                           },
//                           child:  Text("Create New Account"),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           _buildBackground(),
//           _buildLoginCard(context),
//         ],
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/admin/dashboard.dart';
import 'package:flutter_application/register.dart';
import 'package:flutter_application/theme/app_theme.dart';
import 'package:flutter_application/userhome.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
   LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _savePassword = false;

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = authResult.user;
      if (user == null) {
        throw FirebaseAuthException(
          message: 'User not found',
          code: 'user-not-found',
        );
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists || userDoc.data()?['role'] == null) {
        throw FirebaseAuthException(
          message: 'User role not defined. Please contact support.',
          code: 'role-not-found',
        );
      }

      final role = userDoc.data()?['role'];

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) =>  AdminDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) =>  CarModelDashboard()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.85),
            AppTheme.secondaryColor.withOpacity(0.85),
            AppTheme.primaryColor.withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops:  [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return LayoutBuilder(
      builder: (context, raints) {
        double cardWidth =
            raints.maxWidth < 600 ? raints.maxWidth * 0.9 : 450;

        return Center(
          child: Container(
            width: cardWidth,
            padding:  EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 12,
              child: Padding(
                padding:  EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Login Account",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                         SizedBox(height: 8),
                        Text(
                          "Access your account with your credentials.",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                         SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          decoration:  InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Enter email' : null,
                        ),
                         SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration:  InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                          ),
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Enter password' : null,
                        ),
                         SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _savePassword,
                                  onChanged: (val) {
                                    setState(() {
                                      _savePassword = val ?? false;
                                    });
                                  },
                                ),
                                 Text("Save Password"),
                              ],
                            ),
                          ],
                        ),
                         SizedBox(height: 16),
                        _isLoading
                            ?  Center(child: CircularProgressIndicator())
                            : SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: login,
                                  child:  Text(
                                    "Login Account",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                         SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>  UserRegisterScreen()),
                            );
                          },
                          child:  Text("Create New Account"),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildLoginCard(context),
        ],
      ),
    );
  }
}
