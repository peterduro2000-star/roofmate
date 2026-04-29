import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/company_profile_model.dart';
import '../models/material_model.dart';
import '../models/project_calculation.dart';
import '../models/project_model.dart';
import '../models/quotation_document.dart';

class QuotationService {
  static final _date = DateFormat('dd MMM yyyy');
  static final _moneyFormatter = NumberFormat.currency(
    locale: 'en_NG',
    symbol: '₦',
    decimalDigits: 0,
  );

  const QuotationService();

  QuotationDocument build({
    required ProjectModel project,
    required ProjectCalculation calculation,
  }) {
    final title = 'Quotation - ${project.name}';
    final quotationText = _buildQuotationText(project, calculation);
    final boqCsv = _buildBoqCsv(project, calculation);
    final shareText = _buildShareText(project, calculation);

    return QuotationDocument(
      title: title,
      quotationText: quotationText,
      boqCsv: boqCsv,
      shareText: shareText,
    );
  }

  Future<Uint8List> buildPdfBytes({
    required ProjectModel project,
    required ProjectCalculation calculation,
    List<MaterialModel> materials = const [],
    String companyName = 'RoofMate',
    CompanyProfileModel? companyProfile,
    Uint8List? logoBytes,
  }) async {
    final profile =
        companyProfile ?? CompanyProfileModel(companyName: companyName);
    final document = pw.Document(
      title: 'Quotation - ${project.name}',
      author: profile.companyName,
      creator: 'RoofMate',
    );
    final logo = logoBytes == null ? null : pw.MemoryImage(logoBytes);
    final regularFont = await _loadPdfFont('assets/fonts/Roboto-Regular.ttf');
    final boldFont = await _loadPdfFont('assets/fonts/Roboto-Bold.ttf');
    final rows = _buildBoqRows(calculation, materials);
    final categoryEntries = _orderedCostEntries(calculation);

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        footer: _pageFooter,
        theme: pw.ThemeData.withFont(
          base: regularFont,
          bold: boldFont,
        ),
        build: (context) => [
          _pdfHeader(project, profile, logo),
          pw.SizedBox(height: 18),
          _projectDetails(project),
          pw.SizedBox(height: 18),
          _sectionTable(project, calculation),
          pw.SizedBox(height: 18),
          _materialsTable(rows),
          pw.SizedBox(height: 18),
          _categoryTotalsTable(categoryEntries),
          pw.SizedBox(height: 12),
          _grandTotal(calculation.total),
          pw.SizedBox(height: 18),
          _terms(),
        ],
      ),
    );

    return document.save();
  }

  Future<File> savePdf({
    required ProjectModel project,
    required ProjectCalculation calculation,
    List<MaterialModel> materials = const [],
    String companyName = 'RoofMate',
    CompanyProfileModel? companyProfile,
    Uint8List? logoBytes,
  }) async {
    final bytes = await buildPdfBytes(
      project: project,
      calculation: calculation,
      materials: materials,
      companyName: companyName,
      companyProfile: companyProfile,
      logoBytes: logoBytes,
    );
    final directory = await getApplicationDocumentsDirectory();
    final filename =
        '${_safeFilename(project.name)}-${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${directory.path}/$filename');

    return file.writeAsBytes(bytes, flush: true);
  }

  String _buildQuotationText(
    ProjectModel project,
    ProjectCalculation calculation,
  ) {
    final buffer = StringBuffer()
      ..writeln('ROOFING QUOTATION')
      ..writeln('Project: ${project.name}')
      ..writeln('Date: ${_date.format(project.updatedAt)}');

    if (project.clientName.isNotEmpty) {
      buffer.writeln('Client: ${project.clientName}');
    }
    if (project.siteAddress.isNotEmpty) {
      buffer.writeln('Site: ${project.siteAddress}');
    }

    buffer
      ..writeln('')
      ..writeln('PROJECT SUMMARY')
      ..writeln('Mode: ${project.mode.label}')
      ..writeln('Roof sections: ${project.roofSections.length}')
      ..writeln('Roof area: ${calculation.roofArea.toStringAsFixed(1)} sqm')
      ..writeln('Sheets: ${calculation.sheets}')
      ..writeln('Rafters: ${calculation.rafters}')
      ..writeln('Battens: ${calculation.battensNeeded}')
      ..writeln('Wall plates: ${calculation.wallPlatesNeeded}')
      ..writeln('Accessories/fixings: ${calculation.fasteners}')
      ..writeln('')
      ..writeln('COST BREAKDOWN');

    for (final entry in _orderedCostEntries(calculation)) {
      buffer.writeln('${entry.key}: ${_money(entry.value)}');
    }

    buffer
      ..writeln('')
      ..writeln('ROOF SECTIONS');

    for (var i = 0; i < project.roofSections.length; i++) {
      final section = project.roofSections[i];
      final sectionCalculation = calculation.sectionCalculations[i];

      buffer
        ..writeln('${i + 1}. ${section.name}')
        ..writeln('   Type: ${section.displayName}')
        ..writeln('   Dimensions: ${section.length}m x ${section.width}m')
        ..writeln(
          '   Area: ${sectionCalculation.roofArea.toStringAsFixed(1)} sqm',
        )
        ..writeln('   Sheets: ${sectionCalculation.sheets}');
    }

    return buffer.toString();
  }

  String _buildBoqCsv(ProjectModel project, ProjectCalculation calculation) {
    final buffer = StringBuffer()
      ..writeln('Category,Item,Quantity,Unit,Amount')
      ..writeln(
        'Roof covering,Roof sheets,${calculation.sheets},sheets,${_amount(calculation, 'Roof covering')}',
      )
      ..writeln(
        'Timber/steel frame,Rafters,${calculation.rafters},pieces,${_amount(calculation, 'Timber/steel frame')}',
      )
      ..writeln(
        'Timber/steel frame,Battens,${calculation.battensNeeded},pieces,',
      )
      ..writeln(
        'Timber/steel frame,Wall plates,${calculation.wallPlatesNeeded},pieces,',
      )
      ..writeln(
        'Accessories,Fixings,${calculation.fasteners},units,${_amount(calculation, 'Accessories')}',
      )
      ..writeln(
          'Labour,Labour allowance,1,item,${_amount(calculation, 'Labour')}')
      ..writeln(
        'Transport,Transport allowance,1,item,${_amount(calculation, 'Transport')}',
      )
      ..writeln('Waste,Waste allowance,1,item,${_amount(calculation, 'Waste')}')
      ..writeln('Profit,Profit margin,1,item,${_amount(calculation, 'Profit')}')
      ..writeln('Total,Project total,1,item,${_amount(calculation, 'Total')}');

    for (var i = 0; i < project.roofSections.length; i++) {
      final section = project.roofSections[i];
      final sectionCalculation = calculation.sectionCalculations[i];
      buffer.writeln(
        'Section,${section.name},${sectionCalculation.roofArea.toStringAsFixed(1)},sqm,',
      );
    }

    return buffer.toString();
  }

  String _buildShareText(ProjectModel project, ProjectCalculation calculation) {
    return [
      'Roofing estimate for ${project.name}',
      if (project.clientName.isNotEmpty) 'Client: ${project.clientName}',
      'Sections: ${project.roofSections.length}',
      'Roof area: ${calculation.roofArea.toStringAsFixed(1)} sqm',
      'Sheets: ${calculation.sheets}',
      'Estimated total: ${_money(calculation.total)}',
    ].join('\n');
  }

  List<MapEntry<String, double>> _orderedCostEntries(
    ProjectCalculation calculation,
  ) {
    const order = [
      'Roof covering',
      'Timber/steel frame',
      'Accessories',
      'Labour',
      'Transport',
      'Waste',
      'Profit',
      'Total',
    ];

    return order
        .map((key) => MapEntry(key, calculation.categoryTotals[key] ?? 0))
        .toList();
  }

  String _amount(ProjectCalculation calculation, String key) {
    return _money(calculation.categoryTotals[key] ?? 0);
  }

  String _money(double value) {
    return _moneyFormatter.format(value);
  }

  pw.Widget _pdfHeader(
    ProjectModel project,
    CompanyProfileModel profile,
    pw.MemoryImage? logo,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blueGrey100, width: 0.8),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            height: 8,
            color: PdfColors.blue800,
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 58,
                        height: 58,
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.blueGrey200),
                          color: PdfColors.blueGrey50,
                        ),
                        child: logo == null
                            ? pw.Text(
                                'RoofMate',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  color: PdfColors.blue800,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              )
                            : pw.Image(logo, fit: pw.BoxFit.contain),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              profile.companyName,
                              style: pw.TextStyle(
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blueGrey900,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              _companyContactLine(profile),
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.blueGrey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 18),
                pw.Container(
                  width: 170,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.blueGrey50,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'QUOTATION',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      _metaLine('Date', _date.format(project.updatedAt)),
                      _metaLine('Reference', project.id),
                      _metaLine('Project', project.name),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _metaLine(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 54,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey600,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value.isEmpty ? '-' : value,
              style: const pw.TextStyle(
                fontSize: 8,
                color: PdfColors.blueGrey900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _companyContactLine(CompanyProfileModel profile) {
    final parts = [
      if (profile.phoneNumber.isNotEmpty) profile.phoneNumber,
      if (profile.email.isNotEmpty) profile.email,
      if (profile.address.isNotEmpty) profile.address,
    ];

    return parts.isEmpty
        ? 'Professional Roofing Quotation by RoofMate'
        : parts.join(' | ');
  }

  pw.Widget _projectDetails(ProjectModel project) {
    return _section(
      title: 'Project Details',
      child: pw.Table(
        columnWidths: const {
          0: pw.FixedColumnWidth(90),
          1: pw.FlexColumnWidth(),
          2: pw.FixedColumnWidth(90),
          3: pw.FlexColumnWidth(),
        },
        children: [
          _detailRow('Project', project.name, 'Client', project.clientName),
          _detailRow(
              'Location', project.siteAddress, 'Mode', project.mode.label),
          _detailRow(
            'Roof Type',
            project.roofType,
            'Sections',
            project.roofSections.length.toString(),
          ),
        ],
      ),
    );
  }

  pw.TableRow _detailRow(
    String leftLabel,
    String leftValue,
    String rightLabel,
    String rightValue,
  ) {
    return pw.TableRow(
      children: [
        _detailLabel(leftLabel),
        _detailValue(leftValue.isEmpty ? '-' : leftValue),
        _detailLabel(rightLabel),
        _detailValue(rightValue.isEmpty ? '-' : rightValue),
      ],
    );
  }

  pw.Widget _detailLabel(String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(
        value,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blueGrey600,
        ),
      ),
    );
  }

  pw.Widget _detailValue(String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(
        value,
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey900),
      ),
    );
  }

  pw.Widget _sectionTable(
      ProjectModel project, ProjectCalculation calculation) {
    final headers = ['Section', 'Type', 'Dimensions', 'Area', 'Sheets'];
    final data = <List<String>>[
      for (var i = 0; i < project.roofSections.length; i++)
        [
          project.roofSections[i].name,
          project.roofSections[i].displayName,
          '${project.roofSections[i].length}m x ${project.roofSections[i].width}m',
          '${calculation.sectionCalculations[i].roofArea.toStringAsFixed(1)} sqm',
          calculation.sectionCalculations[i].sheets.toString(),
        ],
    ];

    return _section(
      title: 'Roof Sections Breakdown',
      child: _pdfTable(headers: headers, data: data),
    );
  }

  pw.Widget _materialsTable(List<_BoqRow> rows) {
    final data = rows
        .map(
          (row) => [
            row.description,
            row.unit,
            row.quantityLabel,
            _money(row.rate),
            _money(row.amount),
          ],
        )
        .toList();

    return _section(
      title: 'Materials and Cost BOQ',
      child: _pdfTable(
        headers: const ['Description', 'Unit', 'Qty', 'Rate', 'Amount'],
        data: data,
        numericColumns: const {2, 3, 4},
      ),
    );
  }

  pw.Widget _categoryTotalsTable(List<MapEntry<String, double>> entries) {
    final subtotalEntries = entries.where((entry) => entry.key != 'Total');
    final data = subtotalEntries
        .map((entry) => [entry.key, _money(entry.value)])
        .toList();

    return _section(
      title: 'Category Totals',
      child: pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.blueGrey100, width: 0.8),
        ),
        child: pw.Column(
          children: [
            for (var i = 0; i < data.length; i++)
              pw.Container(
                color: i.isEven ? PdfColors.white : PdfColors.blueGrey50,
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      data[i][0],
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey800,
                      ),
                    ),
                    pw.Text(
                      data[i][1],
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.blueGrey900,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  pw.Widget _grandTotal(double total) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue800,
        border: pw.Border.all(color: PdfColors.blue900, width: 1),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'GRAND TOTAL',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'Estimated project amount',
                style: const pw.TextStyle(
                  color: PdfColors.blueGrey100,
                  fontSize: 8,
                ),
              ),
            ],
          ),
          pw.Text(
            _money(total),
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _terms() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey50,
        border: pw.Border.all(color: PdfColors.blueGrey100, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Notes and Terms',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 6),
          _termLine('Quotation validity: 14 days from the issue date.'),
          _termLine(
            'Prices are based on supplied dimensions and current editable material rates.',
          ),
          _termLine(
            'Final procurement should follow confirmed site measurements and client approval.',
          ),
          _termLine(
            'Payment terms, delivery schedule, and installation timeline should be agreed before work begins.',
          ),
        ],
      ),
    );
  }

  pw.Widget _termLine(String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '- ',
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColors.blueGrey600,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(
                fontSize: 8,
                color: PdfColors.blueGrey700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _section({
    required String title,
    required pw.Widget child,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey900,
          ),
        ),
        pw.SizedBox(height: 6),
        child,
      ],
    );
  }

  pw.Widget _pageFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.blueGrey100, width: 0.6),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Prepared with RoofMate',
            style: const pw.TextStyle(
              fontSize: 7,
              color: PdfColors.blueGrey500,
            ),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(
              fontSize: 7,
              color: PdfColors.blueGrey500,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfTable({
    required List<String> headers,
    required List<List<String>> data,
    Set<int> numericColumns = const {},
  }) {
    return pw.Table(
      border: const pw.TableBorder(
        top: pw.BorderSide(color: PdfColors.blueGrey300, width: 0.8),
        bottom: pw.BorderSide(color: PdfColors.blueGrey300, width: 0.8),
        left: pw.BorderSide(color: PdfColors.blueGrey200, width: 0.6),
        right: pw.BorderSide(color: PdfColors.blueGrey200, width: 0.6),
        horizontalInside:
            pw.BorderSide(color: PdfColors.blueGrey100, width: 0.5),
        verticalInside: pw.BorderSide(color: PdfColors.blueGrey100, width: 0.5),
      ),
      columnWidths: {
        for (var i = 0; i < headers.length; i++)
          i: i == 0
              ? const pw.FlexColumnWidth(2.4)
              : const pw.FlexColumnWidth(),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue800),
          children: [
            for (var i = 0; i < headers.length; i++)
              pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 8),
                child: pw.Align(
                  alignment: numericColumns.contains(i)
                      ? pw.Alignment.centerRight
                      : pw.Alignment.centerLeft,
                  child: pw.Text(
                    headers[i].toUpperCase(),
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        for (var rowIndex = 0; rowIndex < data.length; rowIndex++)
          pw.TableRow(
            decoration: pw.BoxDecoration(
              color: rowIndex.isEven ? PdfColors.white : PdfColors.blueGrey50,
            ),
            children: [
              for (var columnIndex = 0;
                  columnIndex < data[rowIndex].length;
                  columnIndex++)
                pw.Padding(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                  child: pw.Align(
                    alignment: numericColumns.contains(columnIndex)
                        ? pw.Alignment.centerRight
                        : pw.Alignment.centerLeft,
                    child: pw.Text(
                      data[rowIndex][columnIndex],
                      style: const pw.TextStyle(
                        fontSize: 8.5,
                        color: PdfColors.blueGrey900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  List<_BoqRow> _buildBoqRows(
    ProjectCalculation calculation,
    List<MaterialModel> materials,
  ) {
    if (materials.isNotEmpty) {
      return [
        for (final material in materials)
          _BoqRow(
            description: material.name,
            unit: material.unit,
            quantity: _quantityFor(material, calculation),
            amount: _quantityFor(material, calculation) * material.unitPrice,
          ),
        _BoqRow(
          description: 'Labour allowance',
          unit: 'item',
          quantity: 1,
          amount: calculation.categoryTotals['Labour'] ?? 0,
        ),
        _BoqRow(
          description: 'Transport allowance',
          unit: 'item',
          quantity: 1,
          amount: calculation.categoryTotals['Transport'] ?? 0,
        ),
        _BoqRow(
          description: 'Waste allowance',
          unit: 'item',
          quantity: 1,
          amount: calculation.categoryTotals['Waste'] ?? 0,
        ),
        _BoqRow(
          description: 'Profit margin',
          unit: 'item',
          quantity: 1,
          amount: calculation.categoryTotals['Profit'] ?? 0,
        ),
      ];
    }

    final roofCovering = calculation.categoryTotals['Roof covering'] ?? 0;
    final frame = calculation.categoryTotals['Timber/steel frame'] ?? 0;
    final accessories = calculation.categoryTotals['Accessories'] ?? 0;
    final labour = calculation.categoryTotals['Labour'] ?? 0;
    final transport = calculation.categoryTotals['Transport'] ?? 0;
    final waste = calculation.categoryTotals['Waste'] ?? 0;
    final profit = calculation.categoryTotals['Profit'] ?? 0;

    return [
      _BoqRow(
        description: 'Roof covering sheets',
        unit: 'sheets',
        quantity: calculation.sheets.toDouble(),
        amount: roofCovering,
      ),
      _BoqRow(
        description: 'Rafters',
        unit: 'pieces',
        quantity: calculation.rafters.toDouble(),
        amount: frame * 0.45,
      ),
      _BoqRow(
        description: 'Battens / purlins',
        unit: 'pieces',
        quantity: calculation.battensNeeded.toDouble(),
        amount: frame * 0.35,
      ),
      _BoqRow(
        description: 'Wall plates / ridge members',
        unit: 'pieces',
        quantity: calculation.wallPlatesNeeded.toDouble(),
        amount: frame * 0.20,
      ),
      _BoqRow(
        description: 'Accessories and fixings',
        unit: 'units',
        quantity: calculation.fasteners.toDouble(),
        amount: accessories,
      ),
      _BoqRow(
        description: 'Labour allowance',
        unit: 'item',
        quantity: 1,
        amount: labour,
      ),
      _BoqRow(
        description: 'Transport allowance',
        unit: 'item',
        quantity: 1,
        amount: transport,
      ),
      _BoqRow(
        description: 'Waste allowance',
        unit: 'item',
        quantity: 1,
        amount: waste,
      ),
      _BoqRow(
        description: 'Profit margin',
        unit: 'item',
        quantity: 1,
        amount: profit,
      ),
    ];
  }

  double _quantityFor(MaterialModel material, ProjectCalculation calculation) {
    final name = material.name.toLowerCase();

    if (name.contains('sheet') || name.contains('longspan')) {
      return calculation.sheets.toDouble();
    }
    if (name.contains('ridge')) {
      return calculation.ridgeBoardLength == 0
          ? 0
          : (calculation.ridgeBoardLength / 3).ceilToDouble();
    }
    if (name.contains('2x3') || name.contains('batten')) {
      return calculation.battensNeeded.toDouble();
    }
    if (name.contains('2x4') || name.contains('rafter')) {
      return calculation.rafters.toDouble();
    }
    if (name.contains('wall plate')) {
      return calculation.wallPlatesNeeded.toDouble();
    }
    if (name.contains('screw')) {
      return (calculation.fasteners / 100).ceilToDouble();
    }
    if (name.contains('fascia')) {
      return calculation.ridgeBoardLength;
    }

    return 0;
  }

  String _safeFilename(String value) {
    final safe = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return safe.isEmpty ? 'roofing-quotation' : safe;
  }

  Future<pw.Font> _loadPdfFont(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return pw.Font.ttf(data);
  }
}

class _BoqRow {
  final String description;
  final String unit;
  final double quantity;
  final double amount;

  const _BoqRow({
    required this.description,
    required this.unit,
    required this.quantity,
    required this.amount,
  });

  String get quantityText {
    if (quantity == quantity.roundToDouble()) {
      return quantity.toStringAsFixed(0);
    }
    return quantity.toStringAsFixed(2);
  }

  String get quantityLabel => quantityText;

  double get rate => quantity == 0 ? 0 : amount / quantity;
}
