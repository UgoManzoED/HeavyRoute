import 'package:flutter/material.dart';
import '../../../requests/models/transport_request.dart';

class RequestInfoCard extends StatelessWidget {
  final TransportRequest request;

  const RequestInfoCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocRow(Icons.circle_outlined, request.originAddress, Colors.green),
          Padding(
            padding: const EdgeInsets.only(left: 11.0),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Container(width: 2, height: 16, color: Colors.grey.shade300)),
          ),
          _buildLocRow(Icons.location_on, request.destinationAddress, Colors.red),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text("Carico: ${request.load?.type ?? 'Standard'}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    overflow: TextOverflow.ellipsis),
              ),
              Text("${request.load?.weightKg?.toStringAsFixed(0)} kg",
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Dim: ${request.load?.length}m x ${request.load?.width}m x ${request.load?.height}m",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildLocRow(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 13, height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}