# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter mobile application called "Sitemate" - a work logging system for construction workers. The app allows workers to log different types of construction work across 8 comprehensive work types, each with specific measurement fields, and view their logged entries.

## Development Commands

### Running the app
```bash
flutter run
```

### Testing
```bash
flutter test
```

### Code analysis and linting
```bash
flutter analyze
```

### Build commands
```bash
# Android
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```

### Package management
```bash
# Install dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Check for outdated packages
flutter pub outdated
```

## Architecture

### Core Structure
- **Single-file architecture**: All UI and logic is contained in `lib/main.dart`
- **Stateful widgets**: Uses StatefulWidget for interactive screens (AddWorkScreen, ViewWorkScreen)
- **Local storage**: Uses SharedPreferences for persistent data storage on device
- **Navigation**: Simple push/pop navigation between screens

### Data Model
- **WorkEntry class**: Represents a single work log entry with standardized fields:
  - `workType`: Required field for type of work (one of 8 work types)
  - `footpathType`: Optional field specific to footpath work (Main/Housing)
  - `metersSquare`: Optional field for square meter measurements (m²)
  - `metersCubic`: Optional field for cubic meter measurements (m³)
  - `metersTotal`: Optional field for total meter measurements
  - `quantity`: Optional field for quantity/count measurements
  - `hours`: Optional field for time-based measurements
  - `dateTime`: Timestamp when entry was created

### Work Types and Required Fields
1. **Footpaths**: Main/Housing selector + m² + m³
2. **Bases**: m³ + quantity
3. **Foundations**: m² + m³
4. **Kerbing**: meters total
5. **Shuttering**: meters total
6. **Manholes**: quantity
7. **Day Works**: hours
8. **Base Prep**: m² (insulation and mesh)

### UI Components
- **Home Screen**: Landing page with navigation buttons
- **AddWorkScreen**: Form-based logging interface with:
  - Horizontal scrolling tile selectors for all 8 work types
  - Conditional form fields based on work type selection (each type shows relevant measurement fields)
  - Comprehensive validation and success/error messaging for all work types
- **ViewWorkScreen**: List view of all saved work entries with date/time stamps

### Key Dependencies
- `shared_preferences: ^2.2.2` - Local device storage
- `flutter_lints: ^5.0.0` - Code linting rules
- `cupertino_icons: ^1.0.8` - iOS-style icons

### Development Notes
- The app uses extensive debug print statements for development tracking
- Form validation is handled inline with setState updates for all 8 work types
- Data persistence uses string serialization with pipe-delimited format (8 fields total)
- Comprehensive color coding system for all work types:
  - Footpaths: Blue
  - Bases: Orange  
  - Foundations: Brown
  - Kerbing: Purple
  - Shuttering: Teal
  - Manholes: Indigo
  - Day Works: Green
  - Base Prep: Red

### Current Limitations
- ViewWorkScreen only displays detailed fields for Footpaths work type
- No edit/delete functionality for saved entries
- No data export capabilities (CSV, PDF, etc.)
- No summary statistics or reporting features

## Working Style

**User Preferences:**
- User prefers to write all code themselves
- Claude should only identify specific problems when asked for debugging
- Claude should provide ideas and directions for app development when requested
- Claude should focus on minimal, targeted problem identification for bugs
- Claude can suggest features, architecture ideas, and development directions

## Code Writing Restrictions

**IMPORTANT**: Claude should operate in read-only mode by default. Claude should NOT write, edit, or modify any code files unless explicitly instructed with the confirmation code: **9226**

When the confirmation code 9226 is provided, Claude may:
- Write new code files
- Edit existing code files
- Make code modifications as requested

Without the confirmation code, Claude should only:
- Read and analyze code
- Provide guidance and suggestions
- Debug and identify issues
- Answer questions about the codebase

## Development Guidelines

- **ONLY THE USER DOES CODE EDITING**