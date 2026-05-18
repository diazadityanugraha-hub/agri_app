import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_vision/flutter_vision.dart'; // IMPORT AI
import 'dart:io';
import 'result_page.dart';
import '../main.dart'; // Ambil data userLogin

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animationController;
  
  // --- VARIABEL AI & GAMBAR ---
  late FlutterVision vision;
  File? _selectedImage;
  bool _isModelLoaded = false;

  // --- DATABASE PENYAKIT ---
  final Map<String, Map<String, dynamic>> diseaseDatabase = {
    "Bacterial Leaf Blight": {
      "nama": "Hawar Daun Bakteri",
      "gejala": "Bercak kuning keabu-abuan di tepi daun, mengering seperti terbakar.",
      "solusi": "Kurangi Nitrogen, atur jarak tanam.",
      "obat": "Bakterisida (Tembaga Oksida).",
      "isHealthy": false
    },
    "Brown Spot": {
      "nama": "Bercak Coklat",
      "gejala": "Bercak oval coklat dengan titik tengah abu-abu.",
      "solusi": "Perbaiki drainase, cukupi pupuk Kalium.",
      "obat": "Fungisida (Mankozeb).",
      "isHealthy": false
    },
    "Healthy Rice Leaf": {
      "nama": "Daun Padi Sehat",
      "gejala": "Daun hijau segar tanpa bercak.",
      "solusi": "Pertahankan pola pemupukan.",
      "obat": "Tidak perlu obat.",
      "isHealthy": true
    },
    "Leaf Blast": {
      "nama": "Blast Daun",
      "gejala": "Bercak belah ketupat pusat putih abu-abu.",
      "solusi": "Hindari Nitrogen berlebih saat lembap.",
      "obat": "Fungisida (Trisiklazol).",
      "isHealthy": false
    },
  };

  @override
  void initState() {
    super.initState();
    vision = FlutterVision();
    _loadModel(); // Muat Otak AI
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  // Fungsi Muat Model YOLO
  Future<void> _loadModel() async {
    await vision.loadYoloModel(
      modelPath: 'assets/models/padi_model.tflite',
      labels: 'assets/models/labels.txt',
      modelVersion: "yolov8",
      numThreads: 2,
      useGpu: true,
    );
    setState(() => _isModelLoaded = true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    vision.closeYoloModel();
    super.dispose();
  }

  // --- FUNGSI AMBIL FOTO & DETEKSI ---
  Future<void> _processAction(ImageSource source) async {
    if (!_isModelLoaded) {
      _showNotif("AI sedang bersiap, tunggu sebentar...", Colors.orange);
      return;
    }

    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    setState(() {
      _selectedImage = File(pickedFile.path);
    });

    // Munculkan Loading Deteksi
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF1E6F42))),
    );

    // PROSES AI YOLO
    final bytes = await File(pickedFile.path).readAsBytes();
    final results = await vision.yoloOnImage(
      bytesList: bytes,
      imageHeight: 640,
      imageWidth: 640,
      confThreshold: 0.4,
    );

    if (!mounted) return;
    Navigator.pop(context); // Tutup loading

    if (results.isNotEmpty) {
      String labelAI = results[0]['tag']; // Ambil label dari AI
      _navigateToResult(labelAI);
    } else {
      // Jika AI ragu, arahkan ke Sehat atau beri peringatan
      _navigateToResult("Healthy Rice Leaf");
    }
  }

  Future<void> _saveToCloud(String label, Map<String, dynamic> data) async {
    if (userLogin.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('scan_history').add({
        "userId": userLogin,
        "penyakit": data['nama'],
        "status": data['isHealthy'] ? "Sehat" : "Sakit",
        "tanggal": FieldValue.serverTimestamp(),
      });
      await FirebaseFirestore.instance.collection('users').doc(userLogin).update({
        "kondisi": data['nama']
      });
    } catch (e) {
      debugPrint("Gagal simpan ke cloud: $e");
    }
  }

  void _navigateToResult(String label) async {
    final data = diseaseDatabase[label] ?? diseaseDatabase["Healthy Rice Leaf"]!;
    await _saveToCloud(label, data);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          label: data['nama'],
          deskripsi: data['gejala'],
          saran: data['solusi'],
          obat: data['obat'],
          isHealthy: data['isHealthy'],
        ),
      ),
    );
  }

  void _showNotif(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    const Color agriGreen = Color(0xFF1E6F42);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Scan AI Padi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: agriGreen,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Center(
            child: Stack(
              children: [
                Container(
                  width: 320, height: 320,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: agriGreen.withOpacity(0.3), width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: _selectedImage != null 
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : Icon(Icons.center_focus_weak_rounded, size: 100, color: agriGreen.withOpacity(0.5)),
                  ),
                ),
                // Animasi Laser
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Positioned(
                      top: _animationController.value * 280 + 20,
                      left: 20,
                      child: Container(
                        width: 280, height: 3,
                        decoration: BoxDecoration(
                          boxShadow: [BoxShadow(color: Colors.greenAccent.withOpacity(0.8), blurRadius: 10, spreadRadius: 2)],
                          gradient: const LinearGradient(colors: [Colors.transparent, Colors.greenAccent, Colors.transparent]),
                        ),
                      ),
                    );
                  },
                ),
                const Positioned(top: 0, left: 0, child: _ScannerCorner(quarterTurns: 0)),
                const Positioned(top: 0, right: 0, child: _ScannerCorner(quarterTurns: 1)),
                const Positioned(bottom: 0, right: 0, child: _ScannerCorner(quarterTurns: 2)),
                const Positioned(bottom: 0, left: 0, child: _ScannerCorner(quarterTurns: 3)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text("Arahkan Kamera ke Daun Padi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: agriGreen)),
          const Text("AI akan mendeteksi penyakit secara otomatis", style: TextStyle(color: Colors.grey, fontSize: 13)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: agriGreen.withOpacity(0.05),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _processAction(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined, color: agriGreen),
                    label: const Text("GALERI", style: TextStyle(color: agriGreen, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: agriGreen)),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _processAction(ImageSource.camera),
                    icon: const Icon(Icons.camera_rounded, color: Colors.white),
                    label: const Text("DETEKSI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: agriGreen,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerCorner extends StatelessWidget {
  final int quarterTurns;
  const _ScannerCorner({required this.quarterTurns});
  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: quarterTurns,
      child: Container(
        width: 40, height: 40,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF1E6F42), width: 5),
            left: BorderSide(color: Color(0xFF1E6F42), width: 5),
          ),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(15)),
        ),
      ),
    );
  }
}