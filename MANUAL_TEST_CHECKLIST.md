# Manual Test Checklist

Use this checklist on a real Android device before release builds.

## First Launch

- App opens without network.
- Home screen shows New Estimate, Open Demo Project, Material Price List, and Company Profile.
- Open Demo Project displays a complete multi-section estimate.

## Project Builder

- Simple Mode accepts length, width, roof type, sheet type, price per sheet, and waste percentage.
- Professional Mode shows pitch, overhang, lap allowance, sheet effective width, rafter spacing, and purlin spacing.
- Zero or negative length/width shows a clear error.
- Pitch below 5 degrees or above 60 degrees shows a clear error.
- Unrealistic spacing values are rejected.
- Multiple sections can be added, removed, calculated, saved, edited, duplicated, and deleted.

## Materials and Pricing

- Material Price List opens offline.
- Material prices can be edited and saved.
- Updated prices are reflected in project totals.
- Cost breakdown shows roof covering, frame, accessories, labour, transport, waste, profit, and total.
- Naira amounts display clearly.

## Company Profile

- Company name, phone, email, and address can be saved offline.
- Saved profile remains after app restart.
- PDF quotation uses the saved company profile in the header.

## PDF and Sharing

- Preview PDF opens the native preview sheet.
- Generate PDF saves a file successfully.
- Share PDF opens the platform share sheet.
- If PDF sharing fails, text summary sharing still works.
- PDF includes header, project details, roof sections, BOQ table, category totals, and highlighted grand total.

## Legacy Data

- Existing saved legacy estimates still open.
- Legacy estimate deletion still works.
- New project saving does not affect legacy estimates.
