import 'package:flutter/material.dart';
import 'api_service.dart';
import 'country_data.dart';
import 'send_result_page.dart';

class SendMoneyPage extends StatefulWidget {
  const SendMoneyPage({super.key});

  @override
  State<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  final ApiService api = ApiService();

  String fromCountry = "USD";
  String toCountry   = "EGP";
  String currency    = "USD";
  final TextEditingController amountController = TextEditingController();

  bool isLoading = false;

  Future<void> _search() async {
    final raw = amountController.text.trim();
    final amount = double.tryParse(raw.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("أدخل مبلغ صحيح")),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
     final data = await api.convertWithRate(fromCountry, toCountry, amount);

        if (!mounted) return;

        if (data == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("تعذر جلب سعر الصرف")),
          );
          setState(() => isLoading = false);
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SendResultPage(
              from: fromCountry,
              to: toCountry,
              currency: currency,
              amount: amount,
              convertedAmount: data["converted"] ?? 0,
              rate: data["rate"] ?? 0,
            ),
          ),
        );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 400;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Send money"),
        backgroundColor: Colors.indigo.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade900, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildDropdown(
                  label: "From",
                  currentValue: fromCountry,
                  onChanged: (v) => setState(() => fromCountry = v!),
                ),
                const SizedBox(height: 20),
                _buildDropdown(
                  label: "To",
                  currentValue: toCountry,
                  onChanged: (v) => setState(() => toCountry = v!),
                ),
                const SizedBox(height: 20),
                _buildDropdown(
                  label: "Currency",
                  currentValue: currency,
                  onChanged: (v) => setState(() => currency = v!),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Amount",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _search,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.deepPurpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : Text(
                            "Search",
                            style: TextStyle(
                              fontSize: isSmall ? 16 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String currentValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white30, width: 1),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: currentValue,
            dropdownColor: Colors.indigo.shade600,
            underline: const SizedBox(),
            iconEnabledColor: Colors.cyanAccent,
            style: const TextStyle(color: Colors.white),
            items: all_currencies
                .map((c) => DropdownMenuItem(
                      value: c.countryCode, // مهم: يرسل كود الدولة
                      child: Text("${c.name} (${c.countryCode})",
                          style: const TextStyle(color: Colors.white)),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
