import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'money_exchange_ui.dart';
import 'best_rates_tab.dart';
import 'send_money.dart';
import 'login.dart';

class HomePage extends StatelessWidget {
  final String username;
  const HomePage({super.key, required this.username});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final height = media.size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, $username"),
        centerTitle: true,
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
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final padding = constraints.maxWidth * 0.05;
              final cardSpacing = height * 0.02;

              return SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: cardSpacing),
                    Text(
                      "Choose what you want to do",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: cardSpacing),

                    _buildCard(
                      context,
                      icon: Icons.currency_exchange,
                      title: "Currency Converter",
                      subtitle: "Convert currencies instantly",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MoneyExchangeUI()),
                      ),
                    ),

                    _buildCard(
                      context,
                      icon: Icons.star,
                      title: "Best Rates",
                      subtitle: "Find top 3 currencies to maximize value",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BestRatesTab()),
                      ),
                    ),

                    _buildCard(
                      context,
                      icon: Icons.send,
                      title: "Send Money",
                      subtitle: "Choose the fastest and cheapest way",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SendMoneyPage()),
                      ),
                    ),

                    _buildCard(
                      context,
                      icon: Icons.logout,
                      title: "Logout",
                      subtitle: "Return to login screen",
                      onTap: () => _logout(context),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      color: Colors.white.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white24,
                radius: 28,
                child: Icon(icon, color: Colors.cyanAccent, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white54, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
