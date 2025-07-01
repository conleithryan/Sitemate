# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter mobile application called "Sitemate" - a work logging system for construction workers. The app allows workers to log different types of construction work (Footpaths, Bases, Foundations, Kerbing) with type-specific fields and view their logged entries.

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
- **WorkEntry class**: Represents a single work log entry with fields:
  - `workType`: Required field for type of work
  - `footpathType`: Optional field specific to footpath work (Main/Housing)
  - `metersCompleted`: Optional field for footpath meters
  - `basesQuantity`: Optional field for number of bases completed
  - `dateTime`: Timestamp when entry was created

### UI Components
- **Home Screen**: Landing page with navigation buttons
- **AddWorkScreen**: Form-based logging interface with:
  - Horizontal scrolling tile selectors for work types
  - Conditional form fields based on work type selection
  - Validation and success/error messaging
- **ViewWorkScreen**: List view of all saved work entries

### Key Dependencies
- `shared_preferences: ^2.2.2` - Local device storage
- `flutter_lints: ^5.0.0` - Code linting rules
- `cupertino_icons: ^1.0.8` - iOS-style icons

### Development Notes
- The app uses extensive debug print statements for development tracking
- Form validation is handled inline with setState updates
- Data persistence uses string serialization with pipe-delimited format
- Color coding is used throughout for different work types (blue=footpaths, orange=bases, etc.)

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