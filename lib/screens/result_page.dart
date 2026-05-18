import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final String label;
  final String deskripsi;
  final String saran;
  final String obat;
  final bool isHealthy;

  const ResultPage({
    super.key,
    required this.label,
    required this.deskripsi,
    required this.saran,
    required this.obat,
    required this.isHealthy,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text("Hasil Deteksi AI"),
        backgroundColor: isHealthy ? Colors.green[700] : const Color(0xFF1E6F42),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER HASIL ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: isHealthy ? Colors.green[700] : const Color(0xFF1E6F42),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.analytics_outlined, color: Colors.white, size: 60),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isHealthy ? "Tanaman Sehat" : "Tanaman Terinfeksi",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- KARTU DESKRIPSI ---
                  _buildResultCard(
                    title: "Analisis YOLOv8",
                    content: deskripsi,
                    icon: Icons.description_outlined,
                    color: Colors.blue[700]!,
                  ),

                  const SizedBox(height: 15),

                  // --- KARTU SARAN TINDAKAN ---
                  _buildResultCard(
                    title: "Saran Tindakan",
                    content: saran,
                    icon: Icons.lightbulb_outline,
                    color: Colors.orange[800]!,
                  ),

                  const SizedBox(height: 15),

                  // --- KARTU REKOMENDASI OBAT ---
                  if (!isHealthy)
                    _buildResultCard(
                      title: "Rekomendasi Bakterisida/Fungisida",
                      content: obat,
                      icon: Icons.medication_liquid_outlined,
                      color: Colors.red[700]!,
                    ),

                  const SizedBox(height: 30),

                  // --- TOMBOL KEMBALI ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E6F42),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text(
                        "SCAN ULANG", 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk membuat kartu informasi yang rapi
  Widget _buildResultCard({required String title, required String content, required IconData icon, required Color color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
              ),
            ],
          ),
          const Divider(height: 25),
          Text(
            content,
            style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
          ),
        ],
      ),
    );
  }
}