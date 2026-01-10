import 'package:flutter/material.dart';
import '../../auth/models/user_dto.dart';
import 'edit_user_popup.dart';

/**
 * Sezione dedicata alla visualizzazione e filtraggio degli utenti interni.
 * <p>
 * Include una barra di ricerca, filtri per ruolo/stato e una tabella
 * dati con azioni di modifica e disabilitazione.
 * </p>
 */
class InternalUserListSection extends StatelessWidget {
  const InternalUserListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Utenti Interni', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Visualizza, modifica e gestisci tutti gli utenti interni del sistema', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 20),
          _buildFilters(),
          const SizedBox(height: 20),
          Expanded(child: _buildUserTable(context)),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cerca per username, nome, cognome o email...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildDropdownFilter('Tutti i ruoli'),
        const SizedBox(width: 12),
        _buildDropdownFilter('Tutti gli stati'),
      ],
    );
  }

  Widget _buildDropdownFilter(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 16),
          const SizedBox(width: 8),
          Text(label),
          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }

  Widget _buildUserTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(2),
          4: FlexColumnWidth(1.5),
          7: FixedColumnWidth(100),
        },
        children: [
          _buildHeaderRow(),
          _buildDataRow(context, 'USR-003', 'l.verdi', 'Luca Verdi', 'Autista', 'Sospeso'),
          // Aggiungi altre righe qui...
        ],
      ),
    );
  }

  TableRow _buildHeaderRow() {
    return const TableRow(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
      children: [
        Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Username', style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Nome Completo', style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Ruolo', style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Stato', style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Ultimo Accesso', style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Azioni', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
    );
  }

  TableRow _buildDataRow(BuildContext context, String id, String user, String name, String role, String status) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(id)),
        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(user)),
        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(name)),
        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('email@heavyroute.it')),
        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: _buildRoleChip(role)),
        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: _buildStatusChip(status)),
        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('2025-10-20')),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit_note),
              onPressed: () => _openEditPopup(context),
            ),
            const Icon(Icons.block, color: Colors.red),
          ],
        ),
      ],
    );
  }

  void _openEditPopup(BuildContext context) {
    showDialog(context: context, builder: (context) => const EditUserPopup());
  }

  Widget _buildRoleChip(String role) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
      child: Text(role, style: const TextStyle(fontSize: 10)),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = status == 'Attivo' ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}