import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  Future<Map<String, double>?> convertWithRate(
      String from, String to, double amount) async {
    try {
      final url = Uri.parse("https://open.er-api.com/v6/latest/$from");
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception("Server Error: ${response.statusCode}");
      }

      final data = jsonDecode(response.body);

      if (data["result"] != "success") {
        throw Exception("API Error: ${data["error"] ?? "Unknown error"}");
      }

      if (!data["rates"].containsKey(to)) {
        throw Exception("Currency $to not found in API response");
      }

      final rate = (data["rates"][to] as num).toDouble();
      final converted = amount * rate;

      return {"rate": rate, "converted": converted};
    } catch (e) {
      print("Error in convertWithRate: $e");
      return null; 
    }
  }
}
