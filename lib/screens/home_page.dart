import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'calculator_page.dart'; 
import 'scan_page.dart';
import 'katalog_page.dart';
import 'profil_page.dart';
import 'result_page.dart';
import '../main.dart'; // AMBIL DATA DARI MAIN

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _location = "Mencari lokasi...";
  String _temp = "--";
  String _weatherStatus = "Memuat...";

  @override
  void initState() {
    super.initState();
    _getWeatherAndLocation();
  }

  Future<void> _getWeatherAndLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);

      const apiKey = "4a180dfa3f6291a56653df8a9a40733d"; 
      final url = "https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric";
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _location = data['name'];
          _temp = "${data['main']['temp'].toStringAsFixed(0)}°C";
          _weatherStatus = data['weather'][0]['main'];
        });
      }
    } catch (e) {
      setState(() {
        _location = "Gagal ambil lokasi";
        _weatherStatus = "Offline";
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() { _selectedIndex = index; });
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanPage()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- LOGIKA DATA GLOBAL (SINKRON DENGAN PROFIL & ADMIN) ---
    final String namaTampil = (userLogin == "admin") 
        ? (dataPantauanAdmin?['nama'] ?? "Admin") 
        : (savedName ?? "Petani AgriPedia");

    final String lahanTampil = (userLogin == "admin")
        ? (dataPantauanAdmin?['lahan'] ?? "Semua Lahan")
        : (savedLahan ?? "0 Ha");

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER SECTION
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(25, 60, 25, 35),
              decoration: const BoxDecoration(
                color: Color(0xFF1E6F42),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("AgriPedia", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: () {
                          // Clean Session
                          dataPantauanAdmin = null;
                          userLogin = "";
                          savedName = null;
                          savedLahan = null;
                          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); 
                        },
                        icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text("Halo, $namaTampil!", 
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 14),
                      const SizedBox(width: 5),
                      Text("$_location | ", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      const Icon(Icons.thermostat, color: Colors.white70, size: 14),
                      Text("$_temp ($_weatherStatus)", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),

            // STATS CARDS
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  _buildStatCard(lahanTampil, "Luas Lahan", Icons.landscape, Colors.green),
                  const SizedBox(width: 15),
                  _buildStatCard(_temp, _location, Icons.wb_sunny, Colors.orange),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Text("Fitur Utama", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
            ),

            // MENU ITEMS
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.calculate_outlined,
                    title: "Kalkulator Pupuk",
                    subtitle: "Hitung dosis urea & NPK",
                    color: Colors.teal,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CalculatorPage())),
                  ),
                  _buildMenuItem(
                    icon: Icons.camera_alt_outlined,
                    title: "Scan Penyakit (AI)",
                    subtitle: "Deteksi hama real-time",
                    color: Colors.orange,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanPage())),
                  ),
                  _buildMenuItem(
                    icon: Icons.assignment_turned_in_outlined,
                    title: "Hasil Terakhir",
                    subtitle: "Cek diagnosa sebelumnya",
                    color: Colors.purple,
                    onTap: () {
                      // Ambil data kondisi terakhir dari admin atau user sendiri
                      String kondisi = (userLogin == "admin") 
                          ? (dataPantauanAdmin?['kondisi'] ?? "Belum Scan") 
                          : "Status: Normal";
                      
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ResultPage(
                        label: kondisi,
                        deskripsi: "Analisis terakhir untuk lahan $namaTampil.",
                        saran: "Lakukan pemantauan berkala.",
                        obat: "Tersedia di Pustaka Padi",
                        isHealthy: !kondisi.contains("Terinfeksi"), 
                      )));
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.menu_book_rounded,
                    title: "Pustaka Padi",
                    subtitle: "Info penyakit & solusi",
                    color: Colors.brown,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const KatalogPage())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF1E6F42),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: "Scan"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profil"),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }
}