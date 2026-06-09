import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(), // 가짜 결제창의 다크모드를 위해 다크 테마 적용
      home: const PrankHomeScreen(),
    );
  }
}

class PrankHomeScreen extends StatefulWidget {
  const PrankHomeScreen({super.key});

  @override
  State<PrankHomeScreen> createState() => _PrankHomeScreenState();
}

class _PrankHomeScreenState extends State<PrankHomeScreen> {
  int _stage = 1; // 1: 계좌입력, 2: 소리테러, 3: 결제성공
  final TextEditingController _accountController = TextEditingController();
  String? _selectedBank;
  bool _isButtonEnabled = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _accountController.addListener(_checkInput);
  }

  void _checkInput() {
    setState(() {
      // 은행이 선택되고 계좌번호가 입력되면 버튼 활성화
      _isButtonEnabled = _selectedBank != null && _accountController.text.isNotEmpty;
    });
  }

  // 핵심 기능: 볼륨을 최대(1.0)로 높이고 오디오 무한 루프 재생
  Future<void> _startPrank() async {
    await FlutterVolumeController.setVolume(1.0); // 볼륨 100% 강제
    await _audioPlayer.setReleaseMode(ReleaseMode.loop); // 무한 반복 설정
    await _audioPlayer.play(AssetSource('moan.mp3')); // 사운드 재생
    
    setState(() {
      _stage = 2;
    });
  }

  // 소리 끄기 기능
  Future<void> _stopPrank() async {
    await _audioPlayer.stop();
    setState(() {
      _stage = 3;
    });
  }

  @override
  void dispose() {
    _accountController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_stage == 1) return _buildStage1();
    if (_stage == 2) return _buildStage2();
    return _buildStage3();
  }

  // 1. 계좌 입력 화면
  Widget _buildStage1() {
    return Scaffold(
      appBar: AppBar(title: const Text('신속 계좌 송금')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButtonFormField<String>(
              hint: const Text('은행 선택'),
              value: _selectedBank,
              items: ['농협은행','우리은행', '대구은행', '신한은행', '국민은행', '카카오뱅크', '토스뱅크'].map((bank) {
                return DropdownMenuItem(value: bank, child: Text(bank));
              }).toList(),
              onChanged: (value) {
                _selectedBank = value;
                _checkInput();
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _accountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '계좌번호 입력'),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isButtonEnabled ? Colors.blue : Colors.grey,
                ),
                onPressed: _isButtonEnabled ? _startPrank : null,
                child: const Text('5억 받기', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. 소리 폭탄 + 해제 유도 화면
  Widget _buildStage2() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.volume_up, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text('⚠️ 경고 ⚠️\n귀하의 폰에서 소리가 재생 중입니다.', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: Colors.white)),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
              onPressed: () => _showFakePaymentSheet(context),
              child: const Text('결제하여 소리 해제', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // 3. 결제 성공 화면
  Widget _buildStage3() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            const Text('결제 성공', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('소리가 안전하게 해제되었습니다.', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _accountController.clear();
                  _selectedBank = null;
                  _isButtonEnabled = false;
                  _stage = 1; // 처음으로 리셋
                });
              },
              child: const Text('메인 화면으로'),
            ),
          ],
        ),
      ),
    );
  }
  // 4. 업데이트된 가짜 iOS 결제 창 (계좌번호 & 사운드 아이콘 연동)
  void _showFakePaymentSheet(BuildContext context) {
    // 💡 사용자가 입력한 계좌번호에서 끝 4자리만 추출해 내는 로직
    String accountNum = _accountController.text;
    String last4Digits = accountNum.length >= 4 
        ? accountNum.substring(accountNum.length - 4) 
        : accountNum; // 만약 4자리보다 짧게 치면 그냥 친 것만 보여줌
        
    // 💡 앞에서 선택한 은행 이름 가져오기
    String bankName = _selectedBank ?? '결제 은행';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C1E), 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)),
                        // 1️⃣ 플래시 아이콘 대신 '사운드 끄기' 아이콘으로 변경
                        child: const Icon(Icons.volume_off, color: Colors.white), 
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 2️⃣ 텍스트를 'Turn Off Sounds'로 변경
                          Text('Turn Off Sounds', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text('In-App Purchase', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  const Text('\$129.99', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.credit_card, color: Colors.amber),
                    const SizedBox(width: 12),
                    // 3️⃣ 사용자가 선택한 은행 이름 연동
                    Text(bankName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    // 4️⃣ 입력한 계좌번호 끝 4자리 연동
                    Text('Visa •••• $last4Digits', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('Subtotal', style: TextStyle(color: Colors.grey)), Text('\$129.99', style: TextStyle(color: Colors.white))],
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('GST', style: TextStyle(color: Colors.grey)), Text('Included', style: TextStyle(color: Colors.white))],
              ),
              const Divider(height: 30, color: Colors.grey),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('AUD \$129.99', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    Navigator.pop(context);
                    _stopPrank(); 
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Pay ', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                      Icon(Icons.fingerprint, color: Colors.black),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.blue, fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }
}