/// Modello per i dati utente.
/// @author Roman
/// @version 1.0
class UserDTO {
  final String? id;
  final String? username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? company;
  final String? address;
  final String? vat;

  UserDTO({
    this.id,
    this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.company,
    this.address,
    this.vat,
  });

  /// Crea un UserDTO da un oggetto JSON.
  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id']?.toString(),
      username: json['username']?.toString(),
      email: json['email']?.toString(),
      firstName: json['firstName']?.toString() ?? json['first_name']?.toString(),
      lastName: json['lastName']?.toString() ?? json['last_name']?.toString(),
      phone: json['phone']?.toString(),
      company: json['company']?.toString(),
      address: json['address']?.toString(),
      vat: json['vat']?.toString(),
    );
  }

  /// Converte un UserDTO in un oggetto JSON.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (phone != null) 'phone': phone,
      if (company != null) 'company': company,
      if (address != null) 'address': address,
      if (vat != null) 'vat' : vat,
    };
  }

  /// Crea una copia del UserDTO con alcuni campi modificati.
  UserDTO copyWith({
    String? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? company,
    String? address,
    String? vat,
  }) {
    return UserDTO(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      address: address ?? this.address,
      vat: vat ?? this.vat,
    );
  }
}
