import 'package:flutter/material.dart';
import '../../models/request_dto.dart';
import '../../services/request_service.dart';
import '../../../auth/services/user_service.dart';
import '../../../auth/models/user_dto.dart';
import '../widgets/request_card.dart';

/**
 * Schermata della Dashboard del Committente.
 * Implementa fedelmente il design degli ordini attivi e il sistema
 * di inserimento tramite dialog a due colonne.
 * * @author Roman
 * @version 1.7
 */
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final RequestService _requestService = RequestService();
  final UserService _userService = UserService();
  late Future<List<RequestDetailDTO>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _requestsFuture = _requestService.getMyRequests();
  }

  /**
   * Apre il dialog per la creazione di un nuovo ordine.
   * Rimuove le restrizioni 'const' per evitare errori di compilazione con i controller.
   * * @author Roman
   */
  void _openNewOrderDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        // Rimosso 'const' qui per permettere la creazione dinamica del widget
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: const NewOrderPopup(), // Assicurati che il nome sia identico alla classe sotto
          ),
        );
      },
    ).then((value) {
      if (value == true) {
        setState(() {
          _requestsFuture = _requestService.getMyRequests();
        });
      }
    });
  }

  /**
   * Apre il dialog per visualizzare e modificare i dati utente.
   * @author Roman
   */
  void _openUserDataDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: UserDataPopup(userService: _userService),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Dashboard Committente', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.person_outline, color: Color(0xFF374151)),
              tooltip: 'Dati Utente',
              onPressed: _openUserDataDialog,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _requestsFuture = _requestService.getMyRequests();
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAddOrderHeader(),
              const SizedBox(height: 32),
              const Text('Ordini Attivi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text('Monitora lo stato delle tue spedizioni in corso', style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 20),
              FutureBuilder<List<RequestDetailDTO>>(
                future: _requestsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Errore: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Nessun ordine presente.'));
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) => RequestCard(request: snapshot.data![index]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddOrderHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openNewOrderDialog,
              borderRadius: BorderRadius.circular(40),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Color(0xFF0D0D1A), shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Aggiungi Nuovo Ordine', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Clicca per richiedere una nuova consegna speciale', style: TextStyle(color: Colors.blueGrey, fontSize: 14)),
        ],
      ),
    );
  }
}

/**
 * Widget della card ordine (image_bb2e9d.png).
 */
class _OrderCard extends StatelessWidget {
  final RequestCreationDTO request;
  const _OrderCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.inventory_2_outlined, size: 24, color: Color(0xFF374151)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ordine', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFF0D0D1A), borderRadius: BorderRadius.circular(4)),
                      child: const Text('In Transito', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.location_on_outlined, request.originAddress),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.monitor_weight_outlined, 'Peso: ${request.weight} ton'),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.calendar_today_outlined, request.pickupDate),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_note, size: 20, color: Colors.black87),
              label: const Text('Richiedi Modifica o Annullamento', style: TextStyle(color: Colors.black87)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: TextStyle(color: Colors.grey[800], fontSize: 14), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

/**
 * Widget del Form Pop-up (image_baafda.png).
 */
class NewOrderPopup extends StatefulWidget {
  const NewOrderPopup({super.key});

  @override
  State<NewOrderPopup> createState() => _NewOrderPopupState();
}

class _NewOrderPopupState extends State<NewOrderPopup> {
  final _formKey = GlobalKey<FormState>();
  final RequestService _requestService = RequestService();

  final _originCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _quantCtrl = TextEditingController();
  final _lenCtrl = TextEditingController();
  final _widCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  void _handleConfirm() async {
    if (_formKey.currentState!.validate()) {
      final dto = RequestCreationDTO(
        originAddress: _originCtrl.text,
        destinationAddress: _destCtrl.text,
        pickupDate: _dateCtrl.text,
        weight: double.tryParse(_weightCtrl.text) ?? 0.0,
        length: double.tryParse(_lenCtrl.text) ?? 0.0,
        width: double.tryParse(_widCtrl.text) ?? 0.0,
        height: 0.0,
      );

      final success = await _requestService.createRequest(dto);
      if (success && mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Aggiungi Nuovo Ordine', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const Text('Inserisci i dettagli della consegna speciale che vuoi richiedere.', style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(child: _buildInput('Origine del carico *', 'Es. Milano, Via Roma 123', _originCtrl)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildInput('Destinazione del carico *', 'Es. Roma, Via del Corso 45', _destCtrl)),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: _buildDropdown('Tipologia di carico *')),
                  const SizedBox(width: 20),
                  Expanded(child: _buildInput('Quantità *', 'Es. 1', _quantCtrl, isNum: true)),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: _buildInput('Lunghezza (m) *', 'Es. 5.5', _lenCtrl, isNum: true)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildInput('Larghezza (m) *', 'Es. 2.5', _widCtrl, isNum: true)),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: _buildInput('Peso Totale (kg) *', 'Es. 2500', _weightCtrl, isNum: true)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildInput('Data di ritiro *', 'Seleziona data', _dateCtrl, isDate: true)),
                ],
              ),
              const SizedBox(height: 20),

              _buildInput('Note operative', 'Inserisci eventuali note, istruzioni speciali o requisiti particolari...', _noteCtrl, maxLines: 4),
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFFE5E7EB))),
                    ),
                    child: const Text('Annulla', style: TextStyle(color: Colors.black87)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D0D1A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Conferma Ordine'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, String hint, TextEditingController ctrl, {int maxLines = 1, bool isDate = false, bool isNum = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          readOnly: isDate,
          onTap: isDate ? _showPicker : null,
          keyboardType: isNum ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (v) => v!.isEmpty && label.contains('*') ? 'Richiesto' : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          hint: Text('Seleziona tipologia', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          items: const [DropdownMenuItem(value: 'eco', child: Text('Trasporto Eccezionale'))],
          onChanged: (v) {},
        ),
      ],
    );
  }

  Future<void> _showPicker() async {
    final DateTime? d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
    if (d != null) setState(() => _dateCtrl.text = d.toIso8601String().split('T')[0]);
  }
}

/**
 * Widget del Dialog per la visualizzazione e modifica dei dati utente.
 * @author Roman
 * @version 1.0
 */
class UserDataPopup extends StatefulWidget {
  final UserService userService;
  const UserDataPopup({super.key, required this.userService});

  @override
  State<UserDataPopup> createState() => _UserDataPopupState();
}

class _UserDataPopupState extends State<UserDataPopup> {
  final _formKey = GlobalKey<FormState>();
  late Future<UserDTO?> _userFuture;
  bool _isEditing = false;
  bool _isSaving = false;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userFuture = widget.userService.getCurrentUser();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await widget.userService.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _firstNameCtrl.text = user.firstName ?? '';
        _lastNameCtrl.text = user.lastName ?? '';
        _emailCtrl.text = user.email ?? '';
        _phoneCtrl.text = user.phone ?? '';
        _companyCtrl.text = user.company ?? '';
        _addressCtrl.text = user.address ?? '';
      });
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Se si esce dalla modalità modifica, ricarica i dati originali
        _loadUserData();
      }
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final userData = UserDTO(
      firstName: _firstNameCtrl.text.trim().isEmpty ? null : _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim().isEmpty ? null : _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      company: _companyCtrl.text.trim().isEmpty ? null : _companyCtrl.text.trim(),
      address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
    );

    final success = await widget.userService.updateUser(userData);

    if (mounted) {
      setState(() => _isSaving = false);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dati utente aggiornati con successo'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isEditing = false);
        // Ricarica i dati aggiornati
        _userFuture = widget.userService.getCurrentUser();
        await _loadUserData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore durante l\'aggiornamento dei dati'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _companyCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dati Utente', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      if (_isEditing)
                        IconButton(
                          onPressed: _isSaving ? null : _toggleEdit,
                          icon: const Icon(Icons.close),
                          tooltip: 'Annulla',
                        )
                      else
                        IconButton(
                          onPressed: _toggleEdit,
                          icon: const Icon(Icons.edit),
                          tooltip: 'Modifica',
                        ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Visualizza e modifica le tue informazioni personali', style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 32),
              FutureBuilder<UserDTO?>(
                future: _userFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Errore: ${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    return const Center(child: Text('Impossibile caricare i dati utente.'));
                  }

                  final user = snapshot.data!;
                  
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildInput(
                              'Nome',
                              'Inserisci il nome',
                              _firstNameCtrl,
                              initialValue: user.firstName,
                              enabled: _isEditing,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildInput(
                              'Cognome',
                              'Inserisci il cognome',
                              _lastNameCtrl,
                              initialValue: user.lastName,
                              enabled: _isEditing,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInput(
                        'Email',
                        'Inserisci l\'email',
                        _emailCtrl,
                        initialValue: user.email,
                        enabled: _isEditing,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      _buildInput(
                        'Telefono',
                        'Inserisci il numero di telefono',
                        _phoneCtrl,
                        initialValue: user.phone,
                        enabled: _isEditing,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),
                      _buildInput(
                        'Azienda',
                        'Inserisci il nome dell\'azienda',
                        _companyCtrl,
                        initialValue: user.company,
                        enabled: _isEditing,
                      ),
                      const SizedBox(height: 20),
                      _buildInput(
                        'Indirizzo',
                        'Inserisci l\'indirizzo',
                        _addressCtrl,
                        initialValue: user.address,
                        enabled: _isEditing,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 32),
                      if (_isEditing)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _isSaving ? null : _toggleEdit,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                              ),
                              child: const Text('Annulla', style: TextStyle(color: Colors.black87)),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _isSaving ? null : _handleSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D0D1A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('Salva Modifiche'),
                            ),
                          ],
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _toggleEdit,
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Modifica Dati'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D0D1A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    String label,
    String hint,
    TextEditingController ctrl, {
    String? initialValue,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    if (initialValue != null && ctrl.text.isEmpty) {
      ctrl.text = initialValue;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          enabled: enabled,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: enabled ? const Color(0xFFF3F4F6) : Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (v) {
            if (label == 'Email' && v != null && v.isNotEmpty) {
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(v)) {
                return 'Inserisci un\'email valida';
              }
            }
            return null;
          },
        ),
      ],
    );
  }
}