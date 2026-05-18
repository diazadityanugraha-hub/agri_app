import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _namaController = TextEditingController();
  final _userController = TextEditingController(); // Ini akan jadi 'nama' di database agar bisa di-login
  final _passController = TextEditingController();
  final _lahanController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _userController.dispose();
    _passController.dispose();
    _lahanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color agriGreen = Color(0xFF1E6F42);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Daftar Akun Petani", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: agriGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
        child: Column(
          children: [
            const Icon(Icons.app_registration_rounded, size: 100, color: agriGreen),
            const SizedBox(height: 10),
            const Text(
              "Bergabung dengan AgriPedia",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: agriGreen),
            ),
            const SizedBox(height: 30),
            
            _buildTextField(_namaController, "Nama Lengkap", Icons.person, false),
            const SizedBox(height: 15),
            _buildTextField(_lahanController, "Luas Lahan (Contoh: 2.5)", Icons.landscape, true),
            const SizedBox(height: 15),
            _buildTextField(_userController, "Username (Untuk Login)", Icons.alternate_email, false),
            const SizedBox(height: 15),
            _buildTextField(_passController, "Password", Icons.lock, false, obscure: true),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () async { 
                  // Ambil input
                  String usernameInput = _userController.text.trim(); 
                  String namaLengkap = _namaController.text.trim();
                  String pass = _passController.text.trim();
                  String lahan = _lahanController.text.trim();

                  if (usernameInput.isNotEmpty && namaLengkap.isNotEmpty && pass.isNotEmpty && lahan.isNotEmpty) {
                    try {
                      showDialog(
                        context: context, 
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator(color: agriGreen))
                      );

                      // --- SIMPAN KE FIREBASE ---
                      // Kita simpan usernameInput ke kolom 'nama' supaya bisa dibaca oleh LoginPage
                      await FirebaseFirestore.instance.collection('users').add({
                        "nama": usernameInput, // Ini kunci pentingnya biar bisa login!
                        "nama_lengkap": namaLengkap,
                        "pass": pass,
                        "lahan": "$lahan Ha",
                        "kondisi": "Normal",
                        "role": "petani", 
                        "createdAt": FieldValue.serverTimestamp(),
                      });

                      if (!mounted) return;
                      Navigator.pop(context); // Tutup loading

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Akun $usernameInput Berhasil Terdaftar!"), backgroundColor: agriGreen),
                      );

                      Navigator.pop(context); // Kembali ke Login
                    } catch (e) {
                      if (Navigator.canPop(context)) Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Gagal Simpan: $e"), backgroundColor: Colors.red),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Mohon lengkapi semua data!"), backgroundColor: Colors.redAccent),
                    );
                  }
                },
                child: const Text("DAFTAR SEKARANG", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Sudah punya akun? Login di sini", style: TextStyle(color: agriGreen)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isNumber, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1E6F42)),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}