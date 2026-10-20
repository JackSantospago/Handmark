import 'catalog.dart';

/// How Handmark certifies: our own checks, plus the external certifications we
/// verify when a maker claims them.
///
/// The external schemes below are real organisations, described in general
/// terms. Certificate numbers, dates and results attached to pieces in
/// preview/fake_data.dart are DEMO CONTENT, not real records. The scheme
/// logos are not reproduced: the app shows a neutral text seal instead.

/// One of our own checks. Every listing must pass all of them.
class VerificationCheck {
  const VerificationCheck({required this.title, required this.summary, required this.evidence});
  final String title, summary;

  /// What we actually look at.
  final List<String> evidence;
}

const handmarkChecks = [
  VerificationCheck(
    title: 'The maker',
    summary: 'We confirm the maker is a real, named person working in the workshop we list.',
    evidence: [
      'Workshop visit, in person or on a live, unscheduled video walk-through',
      'Identity and business registration checked against public records',
      'Tools and equipment recorded, so we know what can and cannot be made there',
    ],
  ),
  VerificationCheck(
    title: 'The making',
    summary: 'We see how the piece is made, and check the hours of human work are plausible.',
    evidence: [
      'Dated work-in-progress photos at each stage of the piece',
      "The maker's hours log, compared with similar pieces of the same craft",
      'Any machine step written down plainly on the listing',
    ],
  ),
  VerificationCheck(
    title: 'The materials',
    summary: 'We trace where the materials come from and verify any external certification.',
    evidence: [
      'Supplier invoices or source records for the main materials',
      "External certificates looked up on the issuing body's public register",
      'Where no scheme applies, the reason stated on the listing',
    ],
  ),
  VerificationCheck(
    title: 'The piece',
    summary: 'Each finished piece gets its own record, ID and signed certificate.',
    evidence: [
      'Photographed and measured before listing, with a unique Handmark ID',
      'Provenance record signed by the maker and countersigned by us',
      'The certificate ships with the piece; the record stays online',
    ],
  ),
];

/// Results a piece can show for an external scheme.
enum CertStatus {
  /// Claimed by the maker and checked by us against the issuer's register.
  verified,

  /// The scheme could apply but this piece is not certified. We say why.
  notCertified,

  /// No external scheme exists for this kind of work. We say so.
  notApplicable,
}

class CertScheme {
  const CertScheme({
    required this.id,
    required this.seal,
    required this.name,
    required this.certifies,
    required this.howWeCheck,
    required this.appliesTo,
  });
  final String id;

  /// Short text shown in the neutral seal ("FSC").
  final String seal;
  final String name, certifies, howWeCheck;
  final List<Category> appliesTo;
}

const certSchemes = [
  CertScheme(
    id: 'fsc',
    seal: 'FSC',
    name: 'Forest Stewardship Council',
    certifies: 'Wood from forests managed to FSC environmental and social standards, '
        'tracked through every business that handles it (chain of custody).',
    howWeCheck: "We look up the supplier's licence code on FSC's public certificate search, "
        'check it is valid and covers the species, and match it to the timber invoice.',
    appliesTo: [Category.furniture, Category.wood],
  ),
  CertScheme(
    id: 'pefc',
    seal: 'PEFC',
    name: 'Programme for the Endorsement of Forest Certification',
    certifies: 'Wood from sustainably managed forests under national schemes endorsed by PEFC, '
        'common for Nordic and European timber.',
    howWeCheck: "We check the supplier's certificate on the PEFC public register and match it to the invoice.",
    appliesTo: [Category.furniture, Category.wood],
  ),
  CertScheme(
    id: 'hallmark',
    seal: 'HALL\nMARK',
    name: 'UK Hallmark (Assay Office)',
    certifies: 'An independent assay office has tested the precious metal and stamped its fineness, '
        "the maker's mark and the office mark. Required by UK law above set weights.",
    howWeCheck: "We inspect the marks on the piece and confirm the maker's sponsor mark is registered with the assay office.",
    appliesTo: [Category.jewellery],
  ),
  CertScheme(
    id: 'fairmined',
    seal: 'FM',
    name: 'Fairmined',
    certifies: 'Gold and silver from certified artisanal and small-scale mines meeting labour and environmental standards.',
    howWeCheck: "We confirm the maker is a registered Fairmined licensee and check the metal supplier's paperwork.",
    appliesTo: [Category.jewellery],
  ),
  CertScheme(
    id: 'lwg',
    seal: 'LWG',
    name: 'Leather Working Group',
    certifies: 'The tannery has been audited for environmental performance and rated (Gold, Silver, Bronze or Audited).',
    howWeCheck: 'We find the tannery in the LWG member directory and confirm its current rating.',
    appliesTo: [Category.furniture],
  ),
  CertScheme(
    id: 'food',
    seal: 'FOOD\nSAFE',
    name: 'Food-contact testing',
    certifies: 'For vessels meant to hold food or drink: an accredited lab has tested how much lead and cadmium '
        'the glaze or glass releases, against EU limits.',
    howWeCheck: 'We read the lab report, check the lab is accredited, and that the sample matches this glaze or batch.',
    appliesTo: [Category.ceramics, Category.glass],
  ),
];

CertScheme? schemeById(String id) => certSchemes.where((s) => s.id == id).firstOrNull;

/// An external certification result on one piece.
class CertRecord {
  const CertRecord(this.schemeId, this.status, this.detail);

  /// A [CertScheme] id, or '' when no scheme applies at all.
  final String schemeId;
  final CertStatus status;
  final String detail;
}
