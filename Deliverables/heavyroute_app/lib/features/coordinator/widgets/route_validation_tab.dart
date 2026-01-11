import 'package:flutter/material.dart';
import '../services/coordinator_service.dart';
import '../dto/proposed_route_dto.dart';

class RouteValidationTab extends StatefulWidget {
  const RouteValidationTab({super.key});

  @override
  State<RouteValidationTab> createState() => _RouteValidationTabState();
}

class _RouteValidationTabState extends State<RouteValidationTab> {
  final TrafficCoordinatorService _service = TrafficCoordinatorService();
  List<ProposedRouteDTO> _routes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _service.getProposedRoutes();
    if (mounted) {
      setState(() {
        _routes = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleValidation(String routeId, bool approved) async {
    // Mostra caricamento o feedback ottimistico
    final success = await _service.validateRoute(routeId, approved);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approved ? "Percorso validato!" : "Richiesta modifica inviata"),
          backgroundColor: approved ? Colors.green : Colors.orange,
        ),
      );
      _loadData(); // Ricarica la lista
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Errore durante l'operazione"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Proposte di Percorso", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("Valida, approva o modifica i percorsi proposti dal Pianificatore",
              style: TextStyle(color: Colors.grey, fontSize: 14)),

          const SizedBox(height: 24),
          _buildTableHeader(),
          const Divider(),

          // --- LISTA DINAMICA ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _routes.isEmpty
                ? const Center(child: Text("Nessun percorso da validare."))
                : ListView.builder(
              itemCount: _routes.length,
              itemBuilder: (context, index) {
                final route = _routes[index];
                return _buildRouteRow(route);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text("ID", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 2, child: Text("Origine - Destinazione", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 3, child: Text("Percorso Proposto", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 2, child: Text("Tipologia", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 1, child: Text("Stato", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 2, child: Text("Azioni", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildRouteRow(ProposedRouteDTO route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: route.isPending ? const Color(0xFFFFFBEB) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: route.isPending ? Border.all(color: Colors.orange.shade100) : null,
      ),
      child: Row(
        children: [
          // ID e Planner
          Expanded(flex: 1, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(route.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(route.orderId, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 4),
            Text(route.plannerName, style: const TextStyle(fontSize: 11)),
          ])),

          // Origine / Dest
          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildLocationRow(Icons.my_location, route.origin),
            const SizedBox(height: 4),
            _buildLocationRow(Icons.location_on, route.destination),
          ])),

          // Percorso
          Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(route.routeDescription, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(route.details, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ])),

          // Tipologia
          Expanded(flex: 2, child: Text(route.loadType, style: const TextStyle(fontSize: 13))),

          // Stato
          Expanded(flex: 1, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: route.isPending ? Colors.white : Colors.black,
              borderRadius: BorderRadius.circular(4),
              border: route.isPending ? Border.all(color: Colors.grey.shade300) : null,
            ),
            child: Text(route.status,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10, // Font leggermente più piccolo per far stare WAITING_VALIDATION
                    fontWeight: FontWeight.bold,
                    color: route.isPending ? Colors.black : Colors.white
                )
            ),
          )),

          // Azioni
          Expanded(flex: 2, child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: route.isPending ? [
              _buildActionButton(
                "Valida", Colors.black, Colors.white, Icons.check_circle_outline,
                    () => _handleValidation(route.id, true),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                "Rifiuta", Colors.red, Colors.white, Icons.cancel_outlined,
                    () => _handleValidation(route.id, false),
              ),
            ] : [
              const Text("Elaborato", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 12, color: Colors.grey),
      const SizedBox(width: 4),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))
    ]);
  }

  Widget _buildActionButton(String label, Color bg, Color fg, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14, color: fg),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}