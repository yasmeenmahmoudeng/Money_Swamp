import 'package:flutter/material.dart';
import 'country_data.dart';
import 'api_service.dart';

class MoneyExchangeUI extends StatefulWidget {
  const MoneyExchangeUI({super.key});

  @override
  _MoneyExchangeUIState createState() => _MoneyExchangeUIState();
}

class _MoneyExchangeUIState extends State<MoneyExchangeUI>
    with SingleTickerProviderStateMixin {
  String fromCurrency = "USD";
  String toCurrency = "EGP";
  final TextEditingController amountController = TextEditingController();
  String result = "";
  String unitLine = "";
  bool isLoading = false;

  final ApiService api = ApiService();

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo));
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> _convert() async {
  final raw = amountController.text.trim();
  if (raw.isEmpty) return;

  final amount = double.tryParse(raw.replaceAll(',', '.'));
  if (amount == null) return;

  setState(() {
    isLoading = true;
    result = "";
    unitLine = "";
  });

  try {
    final data = await api.convertWithRate(fromCurrency, toCurrency, amount);

    //  التحقق لو الـ API رجّع null علشان مايحصلش Crash
    if (data == null) {
      setState(() {
        result = "❌ Error: API request failed";
        unitLine = "";
      });
      return;
    }

    setState(() {
      result =
          "$amount $fromCurrency = ${data["converted"]!.toStringAsFixed(2)} $toCurrency";
      unitLine =
          "1 $fromCurrency = ${data["rate"]!.toStringAsFixed(4)} $toCurrency";
    });

    _controller.forward(from: 0);
  } catch (e) {
    setState(() {
      result = "❌ Error: ${e.toString()}";
      unitLine = "";
    });
  } finally {
    setState(() => isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    // نجيب حجم الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
  appBar: AppBar(
    title: const Text("Exchange Your Money"),
    titleTextStyle: TextStyle(color: const Color.fromARGB(226, 255, 255, 255),fontSize: 22),
    backgroundColor: const Color.fromARGB(255, 33, 41, 131),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      color:  const Color.fromARGB(226, 255, 255, 255),
      onPressed: () {
        Navigator.pop(context); // بيرجع للهوم
      },
    ),
  ),
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.indigo.shade900, Colors.blue.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      "💸 Currency Converter",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 22 : 28,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Dropdowns Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown("From", fromCurrency, (value) {
                            setState(() => fromCurrency = value!);
                          }),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.swap_horiz,
                              size: 30, color: Colors.white),
                          onPressed: isLoading
                              ? null
                              : () {
                                  setState(() {
                                    final tmp = fromCurrency;
                                    fromCurrency = toCurrency;
                                    toCurrency = tmp;
                                  });
                                },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown("To", toCurrency, (value) {
                            setState(() => toCurrency = value!);
                          }),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Amount Input
                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Enter Amount",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.08),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                              color: Colors.cyanAccent, width: 2),
                        ),
                        prefixIcon: const Icon(Icons.attach_money,
                            color: Colors.cyanAccent),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Convert Button
                    SizedBox(
                      width: isSmallScreen ? double.infinity : 260,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _convert,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          backgroundColor: Colors.deepPurpleAccent,
                        ),
                        child: Text(
                          isLoading ? "Please wait..." : "Convert",
                          style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Result Box
                    if (result.isNotEmpty)
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [Colors.white, Colors.blue.shade50]),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 12,
                                    offset: Offset(2, 6))
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(result,
                                    style: TextStyle(
                                        fontSize: isSmallScreen ? 16 : 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo.shade800),
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 8),
                                Text(unitLine,
                                    style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16,
                                        color: Colors.grey.shade700),
                                    textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              if (isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black45,
                    child: const Center(
                      child:
                          CircularProgressIndicator(color: Colors.cyanAccent),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
      String label, String currentValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white30, width: 1),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            dropdownColor: Colors.indigo.shade400,
            value: currentValue,
            underline: const SizedBox(),
            iconEnabledColor: Colors.cyanAccent,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14),
            items: all_currencies
                .map((currency) => DropdownMenuItem(
                      value: currency.countryCode,
                      child: Text(
                        "${currency.name} (${currency.countryCode})",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
