import 'package:api_client/api_client.dart';

class Contact {
  final String? id;
  final String? displayName;
  final String? givenName;
  final String? familyName;
  final String? middleName;
  final String? prefix;
  final String? suffix;
  final String? company;
  final String? jobTitle;
  final List<ContactEmail> emails;
  final List<ContactPhone> phones;
  final List<ContactAddress> addresses;
  final List<ContactWebsite> websites;
  final List<ContactSocialMedia> socialMedia;
  final String? notes;
  final String? birthday;
  final String? avatar;

  const Contact({
    this.id,
    this.displayName,
    this.givenName,
    this.familyName,
    this.middleName,
    this.prefix,
    this.suffix,
    this.company,
    this.jobTitle,
    this.emails = const [],
    this.phones = const [],
    this.addresses = const [],
    this.websites = const [],
    this.socialMedia = const [],
    this.notes,
    this.birthday,
    this.avatar,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: JsonUtils.parseString(json['id']),
      displayName: JsonUtils.parseString(json['displayName']),
      givenName: JsonUtils.parseString(json['givenName']),
      familyName: JsonUtils.parseString(json['familyName']),
      middleName: JsonUtils.parseString(json['middleName']),
      prefix: JsonUtils.parseString(json['prefix']),
      suffix: JsonUtils.parseString(json['suffix']),
      company: JsonUtils.parseString(json['company']),
      jobTitle: JsonUtils.parseString(json['jobTitle']),
      emails:
          JsonUtils.parseList(
            json['emails'],
            (item) => ContactEmail.fromJson(item as Map<String, dynamic>),
          ) ??
          <ContactEmail>[],
      phones:
          JsonUtils.parseList(
            json['phones'],
            (item) => ContactPhone.fromJson(item as Map<String, dynamic>),
          ) ??
          <ContactPhone>[],
      addresses:
          JsonUtils.parseList(
            json['addresses'],
            (item) => ContactAddress.fromJson(item as Map<String, dynamic>),
          ) ??
          <ContactAddress>[],
      websites:
          JsonUtils.parseList(
            json['websites'],
            (item) => ContactWebsite.fromJson(item as Map<String, dynamic>),
          ) ??
          <ContactWebsite>[],
      socialMedia:
          JsonUtils.parseList(
            json['socialMedia'],
            (item) => ContactSocialMedia.fromJson(item as Map<String, dynamic>),
          ) ??
          <ContactSocialMedia>[],
      notes: JsonUtils.parseString(json['notes']),
      birthday: JsonUtils.parseString(json['birthday']),
      avatar: JsonUtils.parseString(json['avatar']),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    // Only include non-null and non-empty values
    if (id != null && id!.isNotEmpty) json['id'] = id;
    if (displayName != null && displayName!.isNotEmpty)
      json['displayName'] = displayName;
    if (givenName != null && givenName!.isNotEmpty)
      json['givenName'] = givenName;
    if (familyName != null && familyName!.isNotEmpty)
      json['familyName'] = familyName;
    if (middleName != null && middleName!.isNotEmpty)
      json['middleName'] = middleName;
    if (prefix != null && prefix!.isNotEmpty) json['prefix'] = prefix;
    if (suffix != null && suffix!.isNotEmpty) json['suffix'] = suffix;
    if (company != null && company!.isNotEmpty) json['company'] = company;
    if (jobTitle != null && jobTitle!.isNotEmpty) json['jobTitle'] = jobTitle;
    if (notes != null && notes!.isNotEmpty) json['notes'] = notes;
    if (birthday != null && birthday!.isNotEmpty) json['birthday'] = birthday;
    if (avatar != null && avatar!.isNotEmpty) json['avatar'] = avatar;

    // Include lists only if they have items
    if (emails.isNotEmpty)
      json['emails'] = emails.map((e) => e.toJson()).toList();
    if (phones.isNotEmpty)
      json['phones'] = phones.map((p) => p.toJson()).toList();
    if (addresses.isNotEmpty)
      json['addresses'] = addresses.map((a) => a.toJson()).toList();
    if (websites.isNotEmpty)
      json['websites'] = websites.map((w) => w.toJson()).toList();
    if (socialMedia.isNotEmpty)
      json['socialMedia'] = socialMedia.map((s) => s.toJson()).toList();

    return json;
  }
}

class ContactEmail {
  final String? label;
  final String? value;
  final String? type;

  const ContactEmail({
    this.label,
    this.value,
    this.type,
  });

  factory ContactEmail.fromJson(Map<String, dynamic> json) {
    return ContactEmail(
      label: JsonUtils.parseString(json['label']),
      value: JsonUtils.parseString(json['value']),
      type: JsonUtils.parseString(json['type']),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (label != null && label!.isNotEmpty) json['label'] = label;
    if (value != null && value!.isNotEmpty) json['value'] = value;
    if (type != null && type!.isNotEmpty) json['type'] = type;
    return json;
  }
}

class ContactPhone {
  final String? label;
  final String? value;
  final String? type;

  const ContactPhone({
    this.label,
    this.value,
    this.type,
  });

  factory ContactPhone.fromJson(Map<String, dynamic> json) {
    return ContactPhone(
      label: JsonUtils.parseString(json['label']),
      value: JsonUtils.parseString(json['value']),
      type: JsonUtils.parseString(json['type']),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (label != null && label!.isNotEmpty) json['label'] = label;
    if (value != null && value!.isNotEmpty) json['value'] = value;
    if (type != null && type!.isNotEmpty) json['type'] = type;
    return json;
  }
}

class ContactAddress {
  final String? label;
  final String? street;
  final String? city;
  final String? region;
  final String? postcode;
  final String? country;
  final String? type;

  const ContactAddress({
    this.label,
    this.street,
    this.city,
    this.region,
    this.postcode,
    this.country,
    this.type,
  });

  factory ContactAddress.fromJson(Map<String, dynamic> json) {
    return ContactAddress(
      label: JsonUtils.parseString(json['label']),
      street: JsonUtils.parseString(json['street']),
      city: JsonUtils.parseString(json['city']),
      region: JsonUtils.parseString(json['region']),
      postcode: JsonUtils.parseString(json['postcode']),
      country: JsonUtils.parseString(json['country']),
      type: JsonUtils.parseString(json['type']),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (label != null && label!.isNotEmpty) json['label'] = label;
    if (street != null && street!.isNotEmpty) json['street'] = street;
    if (city != null && city!.isNotEmpty) json['city'] = city;
    if (region != null && region!.isNotEmpty) json['region'] = region;
    if (postcode != null && postcode!.isNotEmpty) json['postcode'] = postcode;
    if (country != null && country!.isNotEmpty) json['country'] = country;
    if (type != null && type!.isNotEmpty) json['type'] = type;
    return json;
  }
}

class ContactWebsite {
  final String? label;
  final String? value;
  final String? type;

  const ContactWebsite({
    this.label,
    this.value,
    this.type,
  });

  factory ContactWebsite.fromJson(Map<String, dynamic> json) {
    return ContactWebsite(
      label: JsonUtils.parseString(json['label']),
      value: JsonUtils.parseString(json['value']),
      type: JsonUtils.parseString(json['type']),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (label != null && label!.isNotEmpty) json['label'] = label;
    if (value != null && value!.isNotEmpty) json['value'] = value;
    if (type != null && type!.isNotEmpty) json['type'] = type;
    return json;
  }
}

class ContactSocialMedia {
  final String? label;
  final String? value;
  final String? type;

  const ContactSocialMedia({
    this.label,
    this.value,
    this.type,
  });

  factory ContactSocialMedia.fromJson(Map<String, dynamic> json) {
    return ContactSocialMedia(
      label: JsonUtils.parseString(json['label']),
      value: JsonUtils.parseString(json['value']),
      type: JsonUtils.parseString(json['type']),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (label != null && label!.isNotEmpty) json['label'] = label;
    if (value != null && value!.isNotEmpty) json['value'] = value;
    if (type != null && type!.isNotEmpty) json['type'] = type;
    return json;
  }
}
