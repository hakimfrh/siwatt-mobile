import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:siwatt_mobile/core/models/token_transaction.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';

class TokenHistoryCard extends StatelessWidget {
  final TokenTransaction item;

  const TokenHistoryCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 14, color: SiwattColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    "${DateFormat('dd MMM yyyy - HH:mm').format(DateTime.parse(item.createdAt))}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: SiwattColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(double.tryParse(item.price) ?? 0),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: SiwattColors.accentSuccess,
                ),
              ),
            ],
          ),
          Text(
            "${item.amountKwh} KwH",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: SiwattColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
