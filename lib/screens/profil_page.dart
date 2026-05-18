import 'package:flutter/material.dart';
import '../main.dart'; // PASTIIN INI IMPORT KE main.dart BUKAN login_page.dart

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color agriGreen = Color(0xFF1E6F42);

    // LOGIKA DATA: Tetap canggih, bisa deteksi Admin atau Petani
    final String namaTampil = (userLogin == "admin") 
        ? (dataPantauanAdmin?['nama'] ?? "Admin AgriPedia") 
        : (savedName ?? "Petani Milenial");

    final String lahanTampil = (userLogin == "admin")
        ? (dataPantauanAdmin?['lahan'] ?? "Global")
        : (savedLahan ?? "0 Ha");

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5), // Background abu-abu lembut
      appBar: AppBar(
        title: const Text("PROFIL SAYA", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white)),
        backgroundColor: agriGreen,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER SECTION (Gradients & Shadow) ---
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 150,
                  decoration: const BoxDecoration(
                    color: agriGreen,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 40),
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    child: const Icon(Icons.person, size: 80, color: agriGreen),
                  ),
                ),
              ],
            ) ,
            
            const SizedBox(height: 15),
            Text(namaTampil, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: agriGreen)),
            Text("@$userLogin", style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
            
            const SizedBox(height: 30),

            // --- INFO CARDS SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  _buildFancyCard(Icons.badge_rounded, "Nama Lengkap", namaTampil, Colors.blue),
                  _buildFancyCard(Icons.landscape_rounded, "Luas Lahan", lahanTampil, Colors.green),
                  _buildFancyCard(Icons.verified_user_rounded, "Status Akun", 
                      userLogin == "admin" ? "Super Administrator" : "Petani Terverifikasi", Colors.orange),
                  
                  const SizedBox(height: 40),

                  // --- TOMBOL LOGOUT PREMIUM ---
                  GestureDetector(
                    onTap: () {
                      // Reset data sebelum keluar
                      userLogin = ""; 
                      dataPantauanAdmin = null;
                      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFFF5252)]),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.power_settings_new, color: Colors.white),
                          SizedBox(width: 10),
                          Text("KELUAR APLIKASI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET CARD CUSTOM
  Widget _buildFancyCard(IconData icon, String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }
}