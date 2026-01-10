import 'package:flutter/material.dart';
import '../../../../../core/widgets/custom_input_field.dart';

class RegistrationForm extends StatelessWidget {
  final TextEditingController usernameCtrl;
  final TextEditingController nameCtrl;
  final TextEditingController surnameCtrl;
  final TextEditingController companyCtrl;
  final TextEditingController vatCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController pecCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmPasswordCtrl;

  final Map<String, String?> serverErrors;
  final bool acceptedTerms;
  final Function(bool?) onTermsChanged;
  final VoidCallback onSubmit;
  final bool isLoading;

  const RegistrationForm({
    super.key,
    required this.usernameCtrl,
    required this.nameCtrl,
    required this.surnameCtrl,
    required this.companyCtrl,
    required this.vatCtrl,
    required this.emailCtrl,
    required this.pecCtrl,
    required this.phoneCtrl,
    required this.addressCtrl,
    required this.passwordCtrl,
    required this.confirmPasswordCtrl,
    required this.serverErrors,
    required this.acceptedTerms,
    required this.onTermsChanged,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),

          // --- SEZIONE 1: DATI ACCESSO ---
          _buildSectionTitle("Dati Accesso"),

          // Java DTO: "username"
          CustomInputField(
            label: "Username *",
            controller: usernameCtrl,
            hint: "Es. azienda.rossi",
            errorText: serverErrors['username'],
          ),

          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: CustomInputField(
              label: "Password *",
              controller: passwordCtrl,
              hint: "********",
              isPassword: true,
              // Java DTO: "password"
              errorText: serverErrors['password'],
            )),
            const SizedBox(width: 20),
            Expanded(child: CustomInputField(
              label: "Conferma Password *",
              controller: confirmPasswordCtrl,
              hint: "********",
              isPassword: true,
            )),
          ]),

          const SizedBox(height: 32),

          // --- SEZIONE 2: REFERENTE ---
          _buildSectionTitle("Referente Aziendale"),
          Row(children: [
            Expanded(child: CustomInputField(
              label: "Nome *",
              controller: nameCtrl,
              hint: "Mario",
              // Java DTO: "firstName"
              errorText: serverErrors['firstName'],
            )),
            const SizedBox(width: 20),
            Expanded(child: CustomInputField(
              label: "Cognome *",
              controller: surnameCtrl,
              hint: "Rossi",
              // Java DTO: "lastName"
              errorText: serverErrors['lastName'],
            )),
          ]),

          const SizedBox(height: 32),

          // --- SEZIONE 3: DATI AZIENDA ---
          _buildSectionTitle("Dati Azienda"),
          Row(children: [
            Expanded(child: CustomInputField(
              label: "Ragione Sociale *",
              controller: companyCtrl,
              hint: "Nome S.r.l.",
              // Java DTO: "companyName"
              errorText: serverErrors['companyName'],
            )),
            const SizedBox(width: 20),
            Expanded(child: CustomInputField(
              label: "Partita IVA *",
              controller: vatCtrl,
              hint: "IT12345678901",
              // Java DTO: "vatNumber" (IMPORTANTE!)
              errorText: serverErrors['vatNumber'],
            )),
          ]),
          const SizedBox(height: 20),
          CustomInputField(
            label: "Indirizzo Sede *",
            controller: addressCtrl,
            hint: "Via Roma 1, Milano",
            // Java DTO: "address"
            errorText: serverErrors['address'],
          ),

          const SizedBox(height: 32),

          // --- SEZIONE 4: CONTATTI ---
          _buildSectionTitle("Contatti"),
          Row(children: [
            Expanded(child: CustomInputField(
              label: "Email *",
              controller: emailCtrl,
              hint: "mail@esempio.it",
              keyboardType: TextInputType.emailAddress,
              // Java DTO: "email"
              errorText: serverErrors['email'],
            )),
            const SizedBox(width: 20),
            Expanded(child: CustomInputField(
              label: "PEC *",
              controller: pecCtrl,
              hint: "azienda@pec.it",
              keyboardType: TextInputType.emailAddress,
              // Java DTO: "pec"
              errorText: serverErrors['pec'],
            )),
          ]),
          const SizedBox(height: 20),
          CustomInputField(
            label: "Telefono *",
            controller: phoneCtrl,
            hint: "+39 333 123 4567",
            keyboardType: TextInputType.phone,
            // Java DTO: "phoneNumber" (IMPORTANTE!)
            errorText: serverErrors['phoneNumber'],
          ),

          const SizedBox(height: 32),

          // Footer
          _buildTermsCheckbox(),
          const SizedBox(height: 32),
          _buildSubmitButton(),
          const SizedBox(height: 24),
          _buildLoginLink(context),
        ],
      ),
    );
  }

  // ... (Gli altri metodi _buildHeader, _buildSectionTitle ecc. rimangono uguali) ...
  // Copiali dal file precedente se non li hai salvati, oppure chiedimeli.
  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.local_shipping_rounded, size: 48, color: Color(0xFF0D0D1A)),
          const SizedBox(height: 4),
          const Text("HEAVY\nROUTE", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, height: 0.9, color: Color(0xFF0D0D1A), letterSpacing: 1.0)),
          const SizedBox(height: 32),
          const Text("Registrati su HeavyRoute", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 8),
          const Text("Crea un account per richiedere consegne speciali e gestire le tue spedizioni", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
      const Divider(),
      const SizedBox(height: 12),
    ]);
  }

  Widget _buildTermsCheckbox() {
    return Row(children: [
      SizedBox(height: 24, width: 24, child: Checkbox(value: acceptedTerms, activeColor: const Color(0xFF0D0D1A), onChanged: onTermsChanged)),
      const SizedBox(width: 12),
      const Expanded(child: Text("Accetto i termini e condizioni e la privacy policy", style: TextStyle(color: Color(0xFF6B7280), fontSize: 14))),
    ]);
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onSubmit,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D0D1A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Crea Account"),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("Hai già un account? ", style: TextStyle(color: Color(0xFF6B7280))),
      GestureDetector(
        onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
        child: const Text("Accedi", style: TextStyle(color: Color(0xFF0D0D1A), fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
      ),
    ]);
  }
}