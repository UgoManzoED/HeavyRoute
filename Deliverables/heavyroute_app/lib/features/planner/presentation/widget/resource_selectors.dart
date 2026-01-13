import 'package:flutter/material.dart';

class ResourceSelectors extends StatelessWidget {
  final bool isLoading;
  final List<dynamic> drivers;
  final List<dynamic> vehicles;
  final int? selectedDriverId;
  final String? selectedVehiclePlate;
  final Function(int?) onDriverChanged;
  final Function(String?) onVehicleChanged;

  const ResourceSelectors({
    super.key,
    required this.isLoading,
    required this.drivers,
    required this.vehicles,
    required this.selectedDriverId,
    required this.selectedVehiclePlate,
    required this.onDriverChanged,
    required this.onVehicleChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: LinearProgressIndicator(minHeight: 2),
      );
    }

    return Column(
      children: [
        // DROPDOWN AUTISTA
        DropdownButtonFormField<int>(
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: "Seleziona Autista",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          ),
          value: selectedDriverId,
          items: drivers.map<DropdownMenuItem<int>>((d) {
            return DropdownMenuItem<int>(
              value: d['id'],
              child: Text(
                "${d['firstName']} ${d['lastName']}",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            );
          }).toList(),
          onChanged: onDriverChanged,
          hint: const Text("Scegli autista"),
        ),

        const SizedBox(height: 12),

        // DROPDOWN VEICOLO
        DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: "Seleziona Veicolo",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.local_shipping_outlined),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          ),
          value: selectedVehiclePlate,
          items: vehicles.map<DropdownMenuItem<String>>((v) {
            return DropdownMenuItem<String>(
              value: v['licensePlate'],
              child: Text(
                "${v['model']} | ${v['licensePlate']}",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            );
          }).toList(),
          onChanged: onVehicleChanged,
          hint: const Text("Scegli veicolo"),
        ),
      ],
    );
  }
}