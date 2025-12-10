import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/l10n/app_localizations.dart';
import 'package:tifli/core/state/locale_cubit.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = context.watch<LocaleCubit>().state;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      tooltip: l10n.selectLanguage,
      onSelected: (String languageCode) {
        context.read<LocaleCubit>().changeLocale(languageCode);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              if (currentLocale.languageCode == 'en')
                Icon(Icons.check, color: Theme.of(context).primaryColor),
              if (currentLocale.languageCode == 'en') const SizedBox(width: 8),
              Text(l10n.english),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'fr',
          child: Row(
            children: [
              if (currentLocale.languageCode == 'fr')
                Icon(Icons.check, color: Theme.of(context).primaryColor),
              if (currentLocale.languageCode == 'fr') const SizedBox(width: 8),
              Text(l10n.french),
            ],
          ),
        ),
      ],
    );
  }
}
