# RoofMate

RoofMate is a professional roofing estimation and quotation tool designed for builders, carpenters, architects, quantity surveyors, and artisans.

It helps you calculate roofing materials, generate accurate cost estimates, and produce client-ready PDF quotations, all offline.

## Features

### Roofing Estimation

- Multi-section roof support, including main roofs, extensions, and similar project sections
- Supports multiple roof types:
  - Gable
  - Hip
  - Mono-pitch
- Accurate calculation of:
  - Roof area
  - Roofing sheets
  - Timber/steel frame
  - Accessories

### Costing & Pricing

- Editable material price database
- Labour, transport, waste, and profit calculations
- Real-time cost breakdown
- Nigerian currency formatting with `₦`

### Professional Quotation

- Generate BOQ-style PDF quotations
- Includes:
  - Project details
  - Section breakdown
  - Materials and quantities
  - Cost tables
  - Category totals
  - Grand total
- Clean, client-ready layout

### Sharing

- Share PDF directly via WhatsApp and other apps
- Copy quotation text
- Export BOQ as CSV

### Company Branding

- Add company name, phone, email, and address
- Company profile is automatically included in PDF quotations

### Offline-First

- No internet required
- Local storage using Hive
- Project saving and reuse

### Settings

- Default waste percentage
- Default material preferences
- Company profile management

## Screenshots

Add screenshots here later:

- Home
- Project Builder
- Results
- PDF Preview

## Tech Stack

- Flutter
- Hive local database
- PDF and Printing document generation
- `share_plus` sharing

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/roofmate.git
cd roofmate
flutter pub get
flutter run
```

## Build APK

```bash
flutter build apk --release
```

Output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Security Note

The following files are not included in this repository:

```text
android/key.properties
*.jks
```

These files are required for signing release builds and must be created locally.

## Testing

```bash
flutter analyze
flutter test
```

## Manual Testing Checklist

See:

```text
MANUAL_TEST_CHECKLIST.md
```

## Known Issues

- Some UI polish improvements pending
- Ongoing optimization for low-end devices
- Continuous improvements to PDF design

## Roadmap

- Improved PDF styling
- Cloud backup and sync
- Advanced roof visualization
- Multi-user/team features

## Author

Durodadah

## License

This project is currently private/proprietary.

## Vision

RoofMate aims to become the go-to roofing estimation tool in Nigeria and beyond, combining accuracy, simplicity, and professional output for real-world construction work.
