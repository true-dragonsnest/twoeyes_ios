# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## High-Level Architecture

The codebase follows **Clean Architecture + MVVM** pattern with clear separation:

### Layer Structure
- **App/**: Entry point and app lifecycle
- **View/**: SwiftUI views and view models (MVVM)
  - Feature views are organized by function: `Home/`, `Login/`, `Feeds/`, `Threads/`, etc.
  - Shared components in `Components/`
  - Global state via `ContentViewModel.shared`
- **Domain/UseCase/**: Business logic layer (currently minimal)
- **Data/**: 
  - `Entity/`: Data models
  - `Repository/`: Data access patterns
  - `Backend/`: API integration
- **Common/**: Shared utilities and services

### Key Services Architecture
Services are implemented as singletons in `/Common/Services/`:
- **AuthService**: Apple/Google authentication
- **BackendService**: Supabase integration
- **CloudStorageService**: AWS S3/CloudFlare R2
- **PushNotificationService**: Firebase messaging

### Important Patterns
1. **Dependency Management**: Swift Package Manager (SPM) only - no CocoaPods/Carthage
2. **State Management**: Combine framework with `@Published` properties
3. **Navigation**: SwiftUI navigation with view models
4. **Backend**: Supabase for auth/database, Firebase for analytics/push
5. **Environment Configuration**: API keys in `App-Info.plist` and `Environment.plist`

### Key Dependencies
- **UI**: SwiftUI, MarkdownUI, Kingfisher (image loading)
- **Backend**: Supabase, Firebase, AWS SDK
- **Auth**: Google Sign-In, Apple Sign-In

### Platform Support
- iOS 18.0+ (iPhone only)

## Development Notes
- No test infrastructure exists - consider adding when implementing new features
- API keys are stored in plist files - be careful not to expose in commits
- The project uses modern Swift concurrency (async/await)
- Localization supports English and Korean using `.xcstrings` format