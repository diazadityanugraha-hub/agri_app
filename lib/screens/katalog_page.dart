import 'package:flutter/material.dart';

class KatalogPage extends StatelessWidget {
  const KatalogPage({super.key});

  // --- DATA LENGKAP PENYAKIT DAUN PADI (SINKRON DENGAN LABELS.TXT) ---
  final List<Map<String, String>> daftarPustaka = const [
    {
      "nama": "Bacterial Leaf Blight",
      "indonesia": "Hawar Daun Bakteri",
      "status": "Infeksi Bakteri",
      "gejala": "Bercak kuning keabu-abuan di tepi daun, lama-lama daun mengering seperti terbakar.",
      "solusi": "Kurangi pupuk Urea berlebih, atur jarak tanam agar tidak terlalu rapat.",
      "obat": "Bakterisida (Streptomisin Sulfat atau Tembaga Oksida).",
      "icon": "warning_amber",
      "color": "0xFFEF6C00" 
    },
    {
      "nama": "Brown Spot",
      "indonesia": "Bercak Coklat",
      "status": "Jamur / Kurang Hara",
      "gejala": "Bercak oval coklat dengan titik tengah abu-abu pada permukaan daun.",
      "solusi": "Perbaiki drainase tanah dan pastikan pemupukan Kalium (KCl) mencukupi.",
      "obat": "Fungisida (Mankozeb atau Difenokonazol).",
      "icon": "report_problem",
      "color": "0xFF795548" 
    },
    {
      "nama": "Healthy Rice Leaf",
      "indonesia": "Tanaman Sehat",
      "status": "Normal",
      "gejala": "Daun berwarna hijau segar, permukaan bersih tanpa bercak, berdiri tegak.",
      "solusi": "Pertahankan pola pemupukan dan irigasi yang sudah berjalan.",
      "obat": "Tidak memerlukan obat (Cukup pupuk rutin).",
      "icon": "check_circle",
      "color": "0xFF2E7D32" 
    },
    {
      "nama": "Leaf Blast",
      "indonesia": "Blast Daun",
      "status": "Infeksi Jamur",
      "gejala": "Bercak belah ketupat dengan pusat putih keabu-abuan pada daun.",
      "solusi": "Hindari pupuk Nitrogen berlebih saat cuaca lembap dan gunakan varietas tahan.",
      "obat": "Fungisida (Trisiklazol atau Pirokulon).",
      "icon": "coronavirus",
      "color": "0xFFC62828" 
    },
    {
      "nama": "Leaf Scald",
      "indonesia": "Luka Daun",
      "status": "Infeksi Jamur",
      "gejala": "Garis basah di ujung daun berubah jadi pita coklat lebar dengan pola seperti ombak.",
      "solusi": "Bersihkan gulma di sekitar pematang agar sirkulasi udara lancar.",
      "obat": "Fungisida sistemik (Karbendazim).",
      "icon": "opacity",
      "color": "0xFF455A64" 
    },
    {
      "nama": "Narrow Brown Leaf Spot",
      "indonesia": "Bercak Coklat Sempit",
      "status": "Jamur",
      "gejala": "Bercak coklat berbentuk garis lurus sempit sejajar urat daun.",
      "solusi": "Pastikan kecukupan unsur hara Mikro dan gunakan varietas tahan.",
      "obat": "Fungisida (Propikonazol).",
      "icon": "report_problem",
      "color": "0xFF8D6E63" 
    },
    {
      "nama": "Neck_Blast",
      "indonesia": "Blast Leher (Patah Leher)",
      "status": "Infeksi Jamur Parah",
      "gejala": "Pangkal malai membusuk coklat, menyebabkan malai patah dan gabah hampa.",
      "solusi": "Semprot fungisida sebelum fase berbunga dan saat keluar malai.",
      "obat": "Fungisida (Trisiklazol atau Difenokonazol).",
      "icon": "error_outline",
      "color": "0xFFB71C1C" 
    },
    {
      "nama": "Rice Hispa",
      "indonesia": "Hama Hispa",
      "status": "Hama Kumbang",
      "gejala": "Daun bergaris putih memanjang karena dikerok kumbang kecil berduri.",
      "solusi": "Potong ujung daun yang ada telurnya sebelum ditanam di sawah.",
      "obat": "Insektisida (Deltametrin atau Fipronil).",
      "icon": "bug_report",
      "color": "0xFF212121" 
    },
    {
      "nama": "Sheath Blight",
      "indonesia": "Hawar Pelepah",
      "status": "Infeksi Jamur",
      "gejala": "Bercak oval besar di pelepah dekat air, menyebabkan daun menguning.",
      "solusi": "Gunakan sistem Jajar Legowo untuk mengurangi kelembapan tanaman.",
      "obat": "Fungisida (Heksakonazol atau Validamisin).",
      "icon": "warning_amber",
      "color": "0xFFFBC02D" 
    },
    {
      "nama": "Tungro",
      "indonesia": "Virus Tungro",
      "status": "Infeksi Virus",
      "gejala": "Tanaman kerdil parah, daun muda berubah warna menjadi oranye terang.",
      "solusi": "Cabut tanaman sakit, kendalikan hama Wereng Hijau pembawa virus.",
      "obat": "Insektisida pembasmi wereng (Imidakloprid).",
      "icon": "error_outline",
      "color": "0xFF6A1B9A" 
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Pustaka Penyakit Padi",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E6F42),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            color: const Color(0xFF1E6F42),
            child: const Text(
              "Daftar lengkap penyakit berdasarkan scan AI AgriPedia.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: daftarPustaka.length,
              padding: const EdgeInsets.all(15),
              itemBuilder: (context, index) {
                final item = daftarPustaka[index];
                final Color themeColor = Color(int.parse(item['color']!));

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: themeColor.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 5))
                    ],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_getIcon(item['icon']!), color: themeColor, size: 24),
                      ),
                      title: Text(
                        item['indonesia']!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3436)),
                      ),
                      subtitle: Text(
                        "${item['nama']} (${item['status']})",
                        style: TextStyle(
                            color: themeColor, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(),
                              const SizedBox(height: 10),
                              _buildInfoRow(Icons.search, "Gejala:", item['gejala']!),
                              const SizedBox(height: 12),
                              _buildInfoRow(Icons.lightbulb_outline, "Solusi:", item['solusi']!),
                              const SizedBox(height: 12),
                              _buildInfoRow(Icons.medication_liquid, "Rekomendasi Obat:", item['obat']!),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF1E6F42)),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3436), fontSize: 13)),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 26),
          child: Text(content,
              style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4)),
        ),
      ],
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'check_circle': return Icons.check_circle;
      case 'coronavirus': return Icons.coronavirus;
      case 'warning_amber': return Icons.warning_amber;
      case 'error_outline': return Icons.error_outline;
      case 'report_problem': return Icons.report_problem;
      case 'opacity': return Icons.opacity;
      case 'bug_report': return Icons.bug_report;
      default: return Icons.help_outline;
    }
  }
}