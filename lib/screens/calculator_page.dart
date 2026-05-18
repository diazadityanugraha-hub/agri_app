import 'package:flutter/material.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  // Controller untuk menangkap input angka dari user
  final TextEditingController _luasController = TextEditingController();

  // Pilihan satuan default
  String _satuan = 'm2';

  // Variabel penampung hasil hitung
  double _urea = 0;
  double _npk = 0;

  void _hitungPupuk() {
    // Ambil angka dari input, kalau kosong kasih 0
    double luas = double.tryParse(_luasController.text) ?? 0;

    if (luas <= 0) {
      // Tampilkan pesan jika input kosong/salah
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Masukkan luas lahan yang valid!")),
      );
      return;
    }

    // LOGIKA: Konversi ke Hektar agar bisa dikali dosis standar
    // 1 Hektar = 10.000 m2
    double luasDalamHektar = (_satuan == 'm2') ? luas / 10000 : luas;

    setState(() {
      // Rumus Dosis (Standar Umum Kementan):
      // Urea: 200 kg per Hektar
      // NPK: 300 kg per Hektar
      _urea = luasDalamHektar * 200;
      _npk = luasDalamHektar * 300;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Kalkulator Pupuk Pintar",
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E6F42),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Estimasi Kebutuhan Pupuk",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Masukkan luas lahan Anda untuk mendapatkan dosis Urea dan NPK yang tepat.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // INPUT BOX & DROPDOWN SATUAN
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _luasController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Luas Lahan",
                      hintText: "Contoh: 500",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _satuan,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: ['m2', 'Hektar'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _satuan = val!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // TOMBOL HITUNG
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _hitungPupuk,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                ),
                child: const Text(
                  "HITUNG SEKARANG",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // TAMPILAN HASIL (Akan muncul jika nilai > 0)
            if (_urea > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 2)
                  ],
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: Column(
                  children: [
                    const Text("HASIL PERHITUNGAN",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const Divider(height: 30),
                    // Perbaikan: Pakai icons.science (huruf kecil semua)
                    _rowHasil("Pupuk Urea", "${_urea.toStringAsFixed(2)} Kg",
                        Icons.science),
                    const SizedBox(height: 15),
                    _rowHasil("Pupuk NPK", "${_npk.toStringAsFixed(2)} Kg",
                        Icons.science_outlined),
                    const SizedBox(height: 20),
                    const Text(
                      "*Dosis berdasarkan standar umum pemupukan padi.",
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Baris Hasil
  Widget _rowHasil(String nama, String nilai, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF1E6F42)),
            const SizedBox(width: 10),
            Text(nama, style: const TextStyle(fontSize: 16)),
          ],
        ),
        Text(
          nilai,
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E6F42)),
        ),
      ],
    );
  }
}
