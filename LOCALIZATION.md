# Localization Guide for Tifli App

This guide explains how to use the localization feature that supports English and French languages.

## Overview

The Tifli app now supports multiple languages with persistent language selection. Users can switch between English and French at any time using the language selector in the app drawer.

## Features

- ✅ Support for English and French languages
- ✅ Persistent language selection (saved across app restarts)
- ✅ Easy-to-use language selector in the drawer
- ✅ Comprehensive translations for common app terms

## How to Use

### For Users

1. **Open the App Drawer**: Tap the menu icon (☰) in the top-left corner
2. **Select Language**: Tap the language icon (🌐) next to the close button
3. **Choose Your Language**: Select either "English" or "Français"
4. **Language Saved**: Your selection is automatically saved and will persist across app restarts

### For Developers

#### Adding New Translations

1. **Edit ARB Files**: Add new translation keys to both files:
   - `lib/l10n/app_en.arb` (English)
   - `lib/l10n/app_fr.arb` (French)

Example:
```json
// In app_en.arb
{
  "@@locale": "en",
  "myNewKey": "My New Text"
}

// In app_fr.arb
{
  "@@locale": "fr",
  "myNewKey": "Mon Nouveau Texte"
}
```

2. **Generate Localization Files**: Run the following command:
```bash
flutter gen-l10n
```

3. **Use in Your Code**:
```dart
import 'package:tifli/l10n/app_localizations.dart';

// In your widget:
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  return Text(l10n.myNewKey);
}
```

#### Available Translations

Current translations include:
- App navigation: home, profile, logs, schedules, memories, etc.
- Actions: save, cancel, delete, edit, add
- Settings: language, settings, selectLanguage
- Child management: addChild, editChild, deleteChild, noChildren
- And more...

See `lib/l10n/app_en.arb` for the complete list.

## Technical Details

### Architecture

- **LocaleCubit**: Manages the current locale state using BLoC pattern
- **SharedPreferences**: Persists the selected language
- **LanguageSelector**: Widget that displays the language picker
- **AppLocalizations**: Generated class that provides access to translations

### File Structure

```
lib/
├── l10n/
│   ├── app_en.arb              # English translations
│   ├── app_fr.arb              # French translations
│   ├── app_localizations.dart   # Generated base class
│   ├── app_localizations_en.dart # Generated English class
│   └── app_localizations_fr.dart # Generated French class
├── core/
│   ├── state/
│   │   └── locale_cubit.dart    # Language state management
│   └── widgets/
│       └── language_selector.dart # Language picker widget
└── main.dart                    # App configuration
```

### Configuration Files

- `l10n.yaml`: Localization configuration
- `pubspec.yaml`: Dependencies and Flutter configuration

## Testing

To test the localization feature:

1. Run the app
2. Navigate to Settings or open the drawer
3. Change the language using the language selector
4. Verify that the UI updates immediately
5. Restart the app and verify the language persists

## Troubleshooting

### Issue: Translations not showing

**Solution**: Make sure you've run `flutter gen-l10n` after adding new translations.

### Issue: Import errors for AppLocalizations

**Solution**: Run `flutter pub get` followed by `flutter gen-l10n` to regenerate the localization files.

### Issue: Language not persisting

**Solution**: Ensure `shared_preferences` package is properly installed and the LocaleCubit is provided at the app level in `main.dart`.

## Future Enhancements

Potential improvements:
- Add more languages (Spanish, Arabic, etc.)
- Implement RTL (Right-to-Left) support for Arabic
- Add region-specific formatting for dates and numbers
- Implement dynamic translation loading

## Contributing

When adding new features:
1. Always add translations for both English and French
2. Use descriptive keys in camelCase
3. Run `flutter gen-l10n` before committing
4. Test language switching before submitting changes

## Resources

- [Flutter Internationalization](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [ARB File Format](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)
- [Intl Package](https://pub.dev/packages/intl)
