import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'country_data.dart'; 

class BestRatesTab extends StatefulWidget {
  const BestRatesTab({super.key});

  @override
  State<BestRatesTab> createState() => _BestRatesTabState();
}

class _BestRatesTabState extends State<BestRatesTab> {
  bool isLoading = false;
  List<MapEntry<String, double>> topRates = [];


  Currency from = all_currencies.lastWhere((c) => c.countryCode == "USD");

  @override
  void initState() {
    super.initState();
    fetchRates();
  }

  Future<void> fetchRates() async {
    setState(() {
      isLoading = true;
      topRates.clear();
    });

    try {
      final url = Uri.parse(
          "https://open.er-api.com/v6/latest/${from.countryCode}");
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception("Server error: ${response.statusCode}");
      }

      final data = jsonDecode(response.body);
      if (data["result"] != "success") {
        throw Exception("API Error: ${data["error"] ?? "Unknown error"}");
      }

      final Map<String, dynamic> rates =
          Map<String, dynamic>.from(data["rates"]);

    
      final filteredRates = rates.entries
          .where((e) => all_currencies.any((c) => c.countryCode == e.key))
          .where((e) => e.key != from.countryCode)
          .map((e) => MapEntry(e.key, (e.value as num).toDouble()))
          .toList();

      filteredRates.sort((a, b) => b.value.compareTo(a.value));

      setState(() {
        topRates = filteredRates.take(3).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("💹 Best 3 Rates"),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        label: "Base Currency",
                        currentValue: from,
                        onChanged: (v) => setState(() => from = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: isLoading ? null : fetchRates,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text(
                              "Best Rate",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (isLoading)
                  const Center(
                      child: CircularProgressIndicator(color: Colors.cyanAccent))
                else if (topRates.isEmpty)
                  const Center(
                      child: Text("No data",
                          style: TextStyle(color: Colors.white)))
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: topRates.length,
                      itemBuilder: (context, i) {
                        final entry = topRates[i];
                        final currencyObj = all_currencies.firstWhere(
                            (c) => c.countryCode == entry.key,
                            orElse: () => Currency(entry.key, entry.key));
                        return Card(
                          color: Colors.white.withOpacity(0.15),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            title: Text(
                              "${currencyObj.name} (${currencyObj.countryCode})",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            trailing: Text(
                              entry.value.toStringAsFixed(4),
                              style: const TextStyle(
                                  color: Colors.cyanAccent,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
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
    required Currency currentValue,
    required ValueChanged<Currency?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white30, width: 1),
          ),
          child: DropdownButton<Currency>(
            isExpanded: true,
            value: currentValue,
            dropdownColor: Colors.indigo.shade600,
            underline: const SizedBox(),
            iconEnabledColor: Colors.cyanAccent,
            style: const TextStyle(color: Colors.white),
            items: all_currencies
                .map((c) => DropdownMenuItem(
                      value: c,
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
