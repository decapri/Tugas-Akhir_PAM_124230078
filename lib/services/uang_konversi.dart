import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String baseUrl = 'https://api.exchangerate-api.com/v4/latest/USD';
  
  
  static Map<String, double>? _cachedRates;
  static DateTime? _lastFetch;
  
 
  static const double rewardPerDonation = 7.0;
  
  static Future<Map<String, double>> getExchangeRates() async {
  
    if (_cachedRates != null && 
        _lastFetch != null && 
        DateTime.now().difference(_lastFetch!).inHours < 1) {
      return _cachedRates!;
    }
    
    try {
      final response = await http.get(Uri.parse(baseUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        
        _cachedRates = {
          'USD': 1.0,
          'GBP': rates['GBP'] as double,
          'KRW': rates['KRW'] as double,
          'IDR': rates['IDR'] as double,
        };
        _lastFetch = DateTime.now();
        
        return _cachedRates!;
      } else {
        return _getDefaultRates();
      }
    } catch (e) {
      print('Error fetching exchange rates: $e');
      return _getDefaultRates();
    }
  }
  
  static Map<String, double> _getDefaultRates() {
    
    return {
      'USD': 1.0,
      'GBP': 0.79,
      'KRW': 1320.0,
      'IDR': 15750.0,
    };
  }
  
  static Future<double> convertFromUSD(double usdAmount, String targetCurrency) async {
    final rates = await getExchangeRates();
    final rate = rates[targetCurrency] ?? 1.0;
    return usdAmount * rate;
  }
  
  static String getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'KRW':
        return '₩';
      case 'IDR':
        return 'Rp';
      default:
        return '\$';
    }
  }
  
  static String formatCurrency(double amount, String currency) {
    final symbol = getCurrencySymbol(currency);
    
    if (currency == 'KRW' || currency == 'IDR') {
      return '$symbol${amount.toStringAsFixed(0)}';
    } else {
      return '$symbol${amount.toStringAsFixed(2)}';
    }
  }
  
  static String getCurrencyFlag(String currency) {
    switch (currency) {
      case 'USD':
        return '🇺🇸';
      case 'GBP':
        return '🇬🇧';
      case 'KRW':
        return '🇰🇷';
      case 'IDR':
        return '🇮🇩';
      default:
        return '🇺🇸';
    }
  }
}