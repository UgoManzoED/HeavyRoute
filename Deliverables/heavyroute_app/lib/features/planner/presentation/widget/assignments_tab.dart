import 'package:flutter/material.dart';
import '../../../trips/models/trip_model.dart';
import '../../../trips/services/trip_service.dart';

/**
 * Tab per la gestione operativa delle assegnazioni (Dispatching).
 * <p>
 * Visualizza i viaggi in stato IN_PLANNING e permette di associare
 * Autisti (FREE) e Veicoli (AVAILABLE) tramite un dialog modale.
 * </p>
 */
class AssignmentsTab extends StatefulWidget {
  const AssignmentsTab({super.key});

  @override
  State<AssignmentsTab> createState() => _AssignmentsTabState();
}

class _AssignmentsTabState extends State<AssignmentsTab> {
  final TripService _tripService = TripService();

  // Future per la lista dei viaggi da pianificare
  late Future<List<TripModel>> _tripsToPlanFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /**
   * Ricarica la lista dei viaggi in attesa di assegnazione.
   */
  void _loadData() {
    setState(() {
      _tripsToPlanFuture = _tripService.getTripsToPlan();
    });
  }

  /**
   * Apre il dialog per assegnare le risorse al viaggio selezionato.
   * @param trip Il viaggio da pianificare.
   */
  void _openAssignmentDialog(TripModel trip) {
    showDialog(
      context: context,
      barrierDismissible: false, // Impedisce la chiusura accidentale
      builder: (context) => _AssignmentDialog(
        trip: trip,
        service: _tripService,
        onSuccess: () {
          _loadData(); // Ricarica la lista dopo il successo
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Viaggio assegnato e confermato!"),
                backgroundColor: Colors.green
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Pianificazione Viaggi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("Assegna le risorse (Autista e Mezzo) ai viaggi approvati", style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadData,
                tooltip: "Aggiorna Lista",
              ),
            ],
          ),
          const SizedBox(height: 24),

          // LISTA VIAGGI
          Expanded(
            child: FutureBuilder<List<TripModel>>(
              future: _tripsToPlanFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Errore: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) => _buildTripCard(snapshot.data![index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("Nessun viaggio da pianificare.", style: TextStyle(color: Colors.grey, fontSize: 16)),
          const Text("I viaggi appariranno qui dopo l'approvazione del Coordinator.", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTripCard(TripModel trip) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Colonna 1: Info Principali
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip.tripCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(child: Text("${trip.request.originAddress.split(',')[0]} ➝ ${trip.request.destinationAddress.split(',')[0]}",
                          style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ],
              ),
            ),
            // Colonna 2: Info Carico
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Peso: ${trip.request.load?.weightKg ?? '-'} kg", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(trip.request.load?.description ?? "Nessuna descr.",
                      style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            // Colonna 3: Bottone Azione
            ElevatedButton.icon(
              icon: const Icon(Icons.assignment_ind, size: 16),
              label: const Text("Assegna"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D0D1A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () => _openAssignmentDialog(trip),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
//  WIDGET PRIVATO: DIALOG DI ASSEGNAZIONE
//  Gestisce il caricamento dei dropdown e la chiamata API finale.
// =============================================================================

class _AssignmentDialog extends StatefulWidget {
  final TripModel trip;
  final TripService service;
  final VoidCallback onSuccess;

  const _AssignmentDialog({
    required this.trip,
    required this.service,
    required this.onSuccess
  });

  @override
  State<_AssignmentDialog> createState() => _AssignmentDialogState();
}

class _AssignmentDialogState extends State<_AssignmentDialog> {
  // Stato selezione
  int? _selectedDriverId;
  String? _selectedVehiclePlate;

  // Futures per caricamento risorse
  late Future<List<dynamic>> _driversFuture;
  late Future<List<dynamic>> _vehiclesFuture;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Al caricamento del dialog, richiediamo al backend chi è libero
    _driversFuture = widget.service.getAvailableDrivers();
    _vehiclesFuture = widget.service.getAvailableVehicles();
  }

  Future<void> _confirmAssignment() async {
    if (_selectedDriverId == null || _selectedVehiclePlate == null) return;

    setState(() => _isSaving = true);

    // Chiamata all'endpoint PUT /plan
    bool success = await widget.service.assignResources(
        widget.trip.id,
        _selectedDriverId!,
        _selectedVehiclePlate!
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context); // Chiude il dialog
        widget.onSuccess();     // Trigger del refresh nella tab
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Errore: impossibile assegnare le risorse."), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Pianifica Viaggio ${widget.trip.tripCode}"),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Seleziona le risorse per questo viaggio:", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            // 1. SELETTORE AUTISTA
            FutureBuilder<List<dynamic>>(
              future: _driversFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const LinearProgressIndicator(minHeight: 2);
                var drivers = snapshot.data!;

                if (drivers.isEmpty) {
                  return const Text("⚠️ Nessun autista disponibile (Tutti occupati)", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold));
                }

                return DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                      labelText: "Seleziona Autista (Stato: FREE)",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person)
                  ),
                  value: _selectedDriverId,
                  items: drivers.map((d) => DropdownMenuItem<int>(
                    value: d['id'],
                    child: Text("${d['firstName']} ${d['lastName']}"),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedDriverId = val),
                );
              },
            ),
            const SizedBox(height: 20),

            // 2. SELETTORE VEICOLO
            FutureBuilder<List<dynamic>>(
              future: _vehiclesFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const LinearProgressIndicator(minHeight: 2);
                var vehicles = snapshot.data!;

                if (vehicles.isEmpty) {
                  return const Text("⚠️ Nessun veicolo disponibile", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold));
                }

                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                      labelText: "Seleziona Veicolo (Stato: AVAILABLE)",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_shipping)
                  ),
                  value: _selectedVehiclePlate,
                  items: vehicles.map((v) => DropdownMenuItem<String>(
                    value: v['licensePlate'],
                    child: Text("${v['licensePlate']} - ${v['model']} (${v['maxLoadCapacity']}kg)"),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedVehiclePlate = val),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annulla")
        ),
        ElevatedButton(
          onPressed: (_selectedDriverId != null && _selectedVehiclePlate != null && !_isSaving)
              ? _confirmAssignment : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D0D1A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: _isSaving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("Conferma Assegnazione"),
        )
      ],
    );
  }
}