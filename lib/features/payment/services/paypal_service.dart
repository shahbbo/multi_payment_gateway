import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_auth/http_auth.dart';

class PaypalService {
  String domain = "https://api.sandbox.paypal.com";

  String clientId = dotenv.env['PAYPAL_CLIENT_ID']!;
  String secret = dotenv.env['PAYPAL_CLIENT_SECRET']!;

  void setCredentials(String clientId, String secret) {
    this.clientId = clientId;
    this.secret = secret;
    domain = "https://api.sandbox.paypal.com";
  }

  Future<String?> getAccessToken() async {
    try {
      var client = BasicAuthClient(clientId, secret);
      var response = await client.post(
        Uri.parse('$domain/v1/oauth2/token?grant_type=client_credentials'),
      );
      if (response.statusCode == 200) {
        final body = convert.jsonDecode(response.body);
        return body["access_token"];
      }
      return null;
    } catch (e) {
      debugPrint('Error getting PayPal access token: $e');
      rethrow;
    }
  }

  Future<Map<String, String>?> createPaypalPayment(
    Map<String, dynamic> transactions,
    String? accessToken,
  ) async {
    try {
      if (accessToken == null) return null;

      var response = await http.post(
        Uri.parse("$domain/v1/payments/payment"),
        body: convert.jsonEncode(transactions),
        headers: {
          "content-type": "application/json",
          'Authorization': 'Bearer $accessToken',
        },
      );

      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (body["links"] != null && body["links"].length > 0) {
          List links = body["links"];

          String? executeUrl;
          String? approvalUrl;

          final item = links.firstWhere(
            (o) => o["rel"] == "approval_url",
            orElse: () => null,
          );
          if (item != null) {
            approvalUrl = item["href"];
          }

          final item1 = links.firstWhere(
            (o) => o["rel"] == "execute",
            orElse: () => null,
          );
          if (item1 != null) {
            executeUrl = item1["href"];
          }
          return {"executeUrl": executeUrl!, "approvalUrl": approvalUrl!};
        }
        return null;
      } else {
        throw Exception(body["message"] ?? "Failed to create payment");
      }
    } catch (e) {
      debugPrint('Error creating PayPal payment: $e');
      rethrow;
    }
  }

  Future<String?> executePayment(
    String url,
    String payerId,
    String? accessToken,
  ) async {
    try {
      if (accessToken == null) return null;

      var response = await http.post(
        Uri.parse(url),
        body: convert.jsonEncode({"payer_id": payerId}),
        headers: {
          "content-type": "application/json",
          'Authorization': 'Bearer $accessToken',
        },
      );

      final body = convert.jsonDecode(response.body);

      debugPrint('///////////////////////////////////////////////////');
      debugPrint(' ////////////////////////////////////////////////');
      debugPrint("URL in excutePayment: $url");
      debugPrint('Payer ID in excutePayment: $payerId');
      debugPrint('Access Token in excutePayment: $accessToken');
      debugPrint('HTTP Status Code in excutePayment: ${response.statusCode}');
      debugPrint('Response Body in excutePayment: $body');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Payment executed successfully: ${body["id"]}');
        return body["id"];
      } else {
        debugPrint(
          'Error executing payment: ${body["name"]} - ${body["message"]}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Exception executing payment: $e');
      return null;
    }
  }
}
