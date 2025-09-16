import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class SendResultPage extends StatefulWidget {
  final String from;
  final String to;
  final String currency;
  final double amount;
  final double convertedAmount;
  final double rate;

  const SendResultPage({
    super.key,
    required this.from,
    required this.to,
    required this.currency,
    required this.amount,
    required this.convertedAmount,
    required this.rate,
  });

  @override
  State<SendResultPage> createState() => _SendResultPageState();
}

class _SendResultPageState extends State<SendResultPage> {
  bool isLoading = true;
  List<dynamic> methods = [];
  // لتخزين المربعات المختارة
  final Set<int> _selectedIndexes = {};

  @override
  void initState() {
    super.initState();
    _loadMethods();
  }

  Future<void> _loadMethods() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/transfer_methods.json');
      final data = jsonDecode(jsonString);

      const currencyToCountry = {
        'EGP': 'EG',
        'USD': 'US',
        'SAR': 'SA',
        'AED': 'AE',
        'INR': 'IN',
        'GBP': 'UK',
        'TRY': 'TR',
        'EUR': 'DE',
        'JPY': 'JP',
        'JOD': 'JO',
        'KWD': 'KW',
        'TND': 'TN',
      };

      final code = currencyToCountry[widget.to] ?? widget.to;
      final countryData = data[code];

      setState(() {
        methods = countryData?['methods'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطأ في قراءة طرق التحويل: $e")),
        );
      }
    }
  }

  void _finish(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("نتائج التحويل"),
        backgroundColor: Colors.indigo.shade900,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade900, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.cyan))
            : SafeArea(
                child: LayoutBuilder(
                  builder: (ctx, c) => SingleChildScrollView(
                    padding: EdgeInsets.all(c.maxWidth * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _infoBox(context),
                        const SizedBox(height: 20),
                        Text(
                          "طرق التحويل المتاحة:",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 10),
                        methods.isEmpty
                            ? Text(
                                "لا توجد طرق تحويل متاحة لهذه الدولة",
                                style: const TextStyle(color: Colors.white70),
                              )
                            : Column(
                                children: List.generate(
                                  methods.length,
                                  (i) => _methodCard(methods[i], i),
                                ),
                              ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                                onPressed: () {
                                  if (_selectedIndexes.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("اختر طريقة واحدة على الأقل")),
                                    );
                                  } else {
                                    _finish("✅ تم إرسال الأموال عبر ${_selectedIndexes.length} طريقة");
                                  }
                                },
                                child: const Text("إرسال"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                                onPressed: () => _finish("❌ تم الإلغاء"),
                                child: const Text("إلغاء"),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _infoBox(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoText("From: ${widget.from} → to: ${widget.to}"),
            _infoText("Amount: ${widget.amount} ${widget.currency}"),
            _infoText(
              " After conversion: ${widget.convertedAmount.toStringAsFixed(2)} ${widget.to}",
            ),
            _infoText(
              " Exchange rate: 1 ${widget.from} = ${widget.rate.toStringAsFixed(4)} ${widget.to}",
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoText(String text, {Color color = Colors.white}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(text, style: TextStyle(color: color)),
      );

  Widget _methodCard(dynamic m, int index) {
    final bool selected = _selectedIndexes.contains(index);
    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: CheckboxListTile(
        value: selected,
        onChanged: (val) {
          setState(() {
            if (val == true) {
              _selectedIndexes.add(index);
            } else {
              _selectedIndexes.remove(index);
            }
          });
        },
        title: Text(
          "${m["name"]}",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "fee_precent: ${m[ "fee_percent"]}% , ( min_fee :${m["min_fee"]}) , time: ${m["time"]} ,notes:${m["notes"]}",
          style: const TextStyle(color: Colors.white70),
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
