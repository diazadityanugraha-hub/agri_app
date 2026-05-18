import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'register_page.dart'; 
import 'home_page.dart';
import 'admin_page.dart'; 
import '../main.dart' as global; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  
  // --- 1. VARIABEL BARU UNTUK LIHAT SANDI ---
  bool _isObscure = true;

  Future<void> _prosesAksi() async {
    String user = _userController.text.trim();
    String pass = _passController.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      _showNotif("Username dan Password wajib diisi!", Colors.orange);
      return;
    }

    // Munculkan Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF1E6F42))),
    );

    try {
      // Cari data berdasarkan Nama
      var query = await FirebaseFirestore.instance
          .collection('users')
          .where('nama', isEqualTo: user)
          .get();

      if (!mounted) return;
      Navigator.pop(context); // Tutup loading

      if (query.docs.isNotEmpty) {
        var doc = query.docs.first;
        var data = doc.data();

        if (data['pass'] == pass) {
          // Login Berhasil
          global.userLogin = user;
          global.savedName = data['nama'] ?? "User";
          global.savedLahan = data['lahan'] ?? "-";
          
          if (data['role'] == "admin" || user.toLowerCase() == "admin") {
            global.dataPantauanAdmin = data;
            _showNotif("Mode Administrator Aktif!", Colors.blue);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminPage()));
          } else {
            _showNotif("Selamat Datang, ${global.savedName}!", Colors.green);
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          _showNotif("Password salah, silakan cek kembali!", Colors.red);
        }
      } else {
        _showNotif("Username '$user' tidak terdaftar!", Colors.red);
      }
    } catch (e) {
      if (!mounted) return;
      if (Navigator.canPop(context)) Navigator.pop(context);
      _showNotif("Gagal terhubung ke Cloud: $e", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color agriGreen = Color(0xFF1E6F42);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, agriGreen.withOpacity(0.12)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: Column(
              children: [
                const SizedBox(height: 50),
                const Icon(Icons.grass_rounded, size: 110, color: Color(0xFF7CB342)),
                const SizedBox(height: 15),
                const Text(
                  "AGRIPEDIA",
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif', 
                    letterSpacing: 8,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const Text(
                  "Selamat Datang Petani Milenial",
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.black87),
                ),
                const SizedBox(height: 45),
                
                // Input Username
                _buildInput(controller: _userController, hint: "Username", icon: Icons.person_outline),
                
                // --- 2. INPUT PASSWORD DENGAN TOMBOL MATA ---
                Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
                  ),
                  child: TextField(
                    controller: _passController,
                    obscureText: _isObscure, // Pakai variabel _isObscure
                    decoration: InputDecoration(
                      hintText: "Password",
                      prefixIcon: const Icon(Icons.lock_open_rounded, color: Color(0xFF1E6F42)),
                      // Ikon Mata di ujung kanan
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure; // Ganti status lihat/tutup
                          });
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(22),
                    ),
                  ),
                ),

                const SizedBox(height: 35),
                _buildButton("MASUK SEKARANG", _prosesAksi),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                  },
                  child: const Text(
                    "Belum memiliki akun? Daftar di sini",
                    style: TextStyle(color: agriGreen, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({required TextEditingController controller, required String hint, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF1E6F42)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(22),
        ),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback action) {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: ElevatedButton(
        onPressed: action,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E6F42),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  void _showNotif(String pesan, Color warna) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: warna,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}