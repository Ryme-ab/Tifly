import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tifli'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profiles.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get profiles;

  /// No description provided for @logs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs;

  /// No description provided for @schedules.
  ///
  /// In en, this message translates to:
  /// **'Schedules'**
  String get schedules;

  /// No description provided for @memories.
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get memories;

  /// No description provided for @souvenirs.
  ///
  /// In en, this message translates to:
  /// **'Souvenirs'**
  String get souvenirs;

  /// No description provided for @feeding.
  ///
  /// In en, this message translates to:
  /// **'Feeding'**
  String get feeding;

  /// No description provided for @sleeping.
  ///
  /// In en, this message translates to:
  /// **'Sleeping'**
  String get sleeping;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @growth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growth;

  /// No description provided for @medication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get medication;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @addChild.
  ///
  /// In en, this message translates to:
  /// **'Add Child'**
  String get addChild;

  /// No description provided for @editChild.
  ///
  /// In en, this message translates to:
  /// **'Edit Child'**
  String get editChild;

  /// No description provided for @deleteChild.
  ///
  /// In en, this message translates to:
  /// **'Delete Child'**
  String get deleteChild;

  /// No description provided for @noChildren.
  ///
  /// In en, this message translates to:
  /// **'No children added yet'**
  String get noChildren;

  /// No description provided for @addLog.
  ///
  /// In en, this message translates to:
  /// **'Add Log'**
  String get addLog;

  /// No description provided for @viewLogs.
  ///
  /// In en, this message translates to:
  /// **'View Logs'**
  String get viewLogs;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @appointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// No description provided for @addAppointment.
  ///
  /// In en, this message translates to:
  /// **'Add Appointment'**
  String get addAppointment;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @addVideo.
  ///
  /// In en, this message translates to:
  /// **'Add Video'**
  String get addVideo;

  /// No description provided for @medicalRecords.
  ///
  /// In en, this message translates to:
  /// **'Medical Records'**
  String get medicalRecords;

  /// No description provided for @addRecord.
  ///
  /// In en, this message translates to:
  /// **'Add Medical Record'**
  String get addRecord;

  /// No description provided for @babyProfiles.
  ///
  /// In en, this message translates to:
  /// **'Baby Profiles'**
  String get babyProfiles;

  /// No description provided for @feedingLog.
  ///
  /// In en, this message translates to:
  /// **'Feeding Log'**
  String get feedingLog;

  /// No description provided for @sleepLog.
  ///
  /// In en, this message translates to:
  /// **'Sleep Log'**
  String get sleepLog;

  /// No description provided for @medicationTracking.
  ///
  /// In en, this message translates to:
  /// **'Medication Tracking'**
  String get medicationTracking;

  /// No description provided for @checklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get checklist;

  /// No description provided for @helpAndAbout.
  ///
  /// In en, this message translates to:
  /// **'Help & About'**
  String get helpAndAbout;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get track;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @babyProfile.
  ///
  /// In en, this message translates to:
  /// **'Baby Profile'**
  String get babyProfile;

  /// No description provided for @mealPlanner.
  ///
  /// In en, this message translates to:
  /// **'Meal Planner'**
  String get mealPlanner;

  /// No description provided for @appointmentSchedule.
  ///
  /// In en, this message translates to:
  /// **'Appointment Schedule'**
  String get appointmentSchedule;

  /// No description provided for @addTrackers.
  ///
  /// In en, this message translates to:
  /// **'Add Trackers'**
  String get addTrackers;

  /// No description provided for @editSleepLog.
  ///
  /// In en, this message translates to:
  /// **'Edit Sleep Log'**
  String get editSleepLog;

  /// No description provided for @trackYourBabyEasily.
  ///
  /// In en, this message translates to:
  /// **'Track Your Baby Easily'**
  String get trackYourBabyEasily;

  /// No description provided for @foodTracker.
  ///
  /// In en, this message translates to:
  /// **'Food Tracker'**
  String get foodTracker;

  /// No description provided for @sleepTracker.
  ///
  /// In en, this message translates to:
  /// **'Sleep Tracker'**
  String get sleepTracker;

  /// No description provided for @growthTracker.
  ///
  /// In en, this message translates to:
  /// **'Growth Tracker'**
  String get growthTracker;

  /// No description provided for @medicineSchedule.
  ///
  /// In en, this message translates to:
  /// **'Medicine Schedule'**
  String get medicineSchedule;

  /// No description provided for @yourBabysSchedule.
  ///
  /// In en, this message translates to:
  /// **'Your Baby\'s Schedule'**
  String get yourBabysSchedule;

  /// No description provided for @monitorSleepGrowthFeeding.
  ///
  /// In en, this message translates to:
  /// **'Monitor sleep, growth, and feeding in one place.'**
  String get monitorSleepGrowthFeeding;

  /// No description provided for @manageDoctorVisits.
  ///
  /// In en, this message translates to:
  /// **'Manage doctor visits, medication reminders and daily meals.'**
  String get manageDoctorVisits;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @tapToLog.
  ///
  /// In en, this message translates to:
  /// **'Tap to log'**
  String get tapToLog;

  /// No description provided for @failedToLoadHomeData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load home data'**
  String get failedToLoadHomeData;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noLittleOnesYet.
  ///
  /// In en, this message translates to:
  /// **'No little ones yet'**
  String get noLittleOnesYet;

  /// No description provided for @noChildrenAddedYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any children yet. Want to add one?'**
  String get noChildrenAddedYet;

  /// No description provided for @addBaby.
  ///
  /// In en, this message translates to:
  /// **'Add Baby'**
  String get addBaby;

  /// No description provided for @lastUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last update'**
  String get lastUpdate;

  /// No description provided for @head.
  ///
  /// In en, this message translates to:
  /// **'Head'**
  String get head;

  /// No description provided for @todaysSchedule.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Schedule'**
  String get todaysSchedule;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @noScheduledItems.
  ///
  /// In en, this message translates to:
  /// **'No scheduled items for today'**
  String get noScheduledItems;

  /// No description provided for @addMemory.
  ///
  /// In en, this message translates to:
  /// **'Add Memory'**
  String get addMemory;

  /// No description provided for @boy.
  ///
  /// In en, this message translates to:
  /// **'Boy'**
  String get boy;

  /// No description provided for @girl.
  ///
  /// In en, this message translates to:
  /// **'Girl'**
  String get girl;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @pleaseSelectBaby.
  ///
  /// In en, this message translates to:
  /// **'Please select a baby first'**
  String get pleaseSelectBaby;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @logsAndReports.
  ///
  /// In en, this message translates to:
  /// **'Logs & Reports'**
  String get logsAndReports;

  /// No description provided for @feedingLogs.
  ///
  /// In en, this message translates to:
  /// **'Feeding Logs'**
  String get feedingLogs;

  /// No description provided for @growthLogs.
  ///
  /// In en, this message translates to:
  /// **'Growth Logs'**
  String get growthLogs;

  /// No description provided for @sleepingLogs.
  ///
  /// In en, this message translates to:
  /// **'Sleeping Logs'**
  String get sleepingLogs;

  /// No description provided for @medicationLogs.
  ///
  /// In en, this message translates to:
  /// **'Medication Logs'**
  String get medicationLogs;

  /// No description provided for @activityLogs.
  ///
  /// In en, this message translates to:
  /// **'Activity Logs'**
  String get activityLogs;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @noActivityLogsYet.
  ///
  /// In en, this message translates to:
  /// **'No activity logs yet'**
  String get noActivityLogsYet;

  /// No description provided for @selectBabyToViewLogs.
  ///
  /// In en, this message translates to:
  /// **'Select a baby to view logs.'**
  String get selectBabyToViewLogs;

  /// No description provided for @generateReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Report'**
  String get generateReport;

  /// No description provided for @sleepingTracker.
  ///
  /// In en, this message translates to:
  /// **'Sleeping Tracker'**
  String get sleepingTracker;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @noSleepLogsYet.
  ///
  /// In en, this message translates to:
  /// **'No sleep logs yet'**
  String get noSleepLogsYet;

  /// No description provided for @growthDashboard.
  ///
  /// In en, this message translates to:
  /// **'Growth Dashboard'**
  String get growthDashboard;

  /// No description provided for @growthLog.
  ///
  /// In en, this message translates to:
  /// **'Growth Log'**
  String get growthLog;

  /// No description provided for @feedingTracker.
  ///
  /// In en, this message translates to:
  /// **'Feeding Tracker'**
  String get feedingTracker;

  /// No description provided for @noLogsYet.
  ///
  /// In en, this message translates to:
  /// **'No logs yet'**
  String get noLogsYet;

  /// No description provided for @medicationTracker.
  ///
  /// In en, this message translates to:
  /// **'Medication Tracker'**
  String get medicationTracker;

  /// No description provided for @noMedicationsYet.
  ///
  /// In en, this message translates to:
  /// **'No medications yet'**
  String get noMedicationsYet;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @managePreferences.
  ///
  /// In en, this message translates to:
  /// **'Manage your preferences and app settings.'**
  String get managePreferences;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @filterFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Filter feature coming soon'**
  String get filterFeatureComingSoon;

  /// No description provided for @generatingPdf.
  ///
  /// In en, this message translates to:
  /// **'Generating PDF...'**
  String get generatingPdf;

  /// No description provided for @pdfGeneratedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'PDF generated successfully!'**
  String get pdfGeneratedSuccessfully;

  /// No description provided for @errorGeneratingPdf.
  ///
  /// In en, this message translates to:
  /// **'Error generating PDF'**
  String get errorGeneratingPdf;

  /// No description provided for @noLogsFound.
  ///
  /// In en, this message translates to:
  /// **'No logs found'**
  String get noLogsFound;

  /// No description provided for @summaryStatistics.
  ///
  /// In en, this message translates to:
  /// **'Summary Statistics'**
  String get summaryStatistics;

  /// No description provided for @visualAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Visual Analytics'**
  String get visualAnalytics;

  /// No description provided for @activityComparison.
  ///
  /// In en, this message translates to:
  /// **'Activity Comparison'**
  String get activityComparison;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get showMore;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @breastMilk.
  ///
  /// In en, this message translates to:
  /// **'Breast Milk'**
  String get breastMilk;

  /// No description provided for @formula.
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get formula;

  /// No description provided for @solidFood.
  ///
  /// In en, this message translates to:
  /// **'Solid Food'**
  String get solidFood;

  /// No description provided for @juice.
  ///
  /// In en, this message translates to:
  /// **'Juice'**
  String get juice;

  /// No description provided for @sleepQuality.
  ///
  /// In en, this message translates to:
  /// **'Sleep Quality'**
  String get sleepQuality;

  /// No description provided for @notGood.
  ///
  /// In en, this message translates to:
  /// **'Not Good'**
  String get notGood;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get endTime;

  /// No description provided for @headCircumference.
  ///
  /// In en, this message translates to:
  /// **'Head Circumference'**
  String get headCircumference;

  /// No description provided for @editFoodTracker.
  ///
  /// In en, this message translates to:
  /// **'Edit Food Tracker'**
  String get editFoodTracker;

  /// No description provided for @feedingName.
  ///
  /// In en, this message translates to:
  /// **'Feeding Name'**
  String get feedingName;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity (ml)'**
  String get quantity;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @updateMeal.
  ///
  /// In en, this message translates to:
  /// **'Update Meal'**
  String get updateMeal;

  /// No description provided for @saveMeal.
  ///
  /// In en, this message translates to:
  /// **'Save Meal'**
  String get saveMeal;

  /// No description provided for @editMemory.
  ///
  /// In en, this message translates to:
  /// **'Edit Memory'**
  String get editMemory;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @deleteMemory.
  ///
  /// In en, this message translates to:
  /// **'Delete memory?'**
  String get deleteMemory;

  /// No description provided for @actionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get actionCannotBeUndone;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @tapToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add photo'**
  String get tapToAddPhoto;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @dailyChecklist.
  ///
  /// In en, this message translates to:
  /// **'Daily Checklist'**
  String get dailyChecklist;

  /// No description provided for @addMeal.
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get addMeal;

  /// No description provided for @editMeal.
  ///
  /// In en, this message translates to:
  /// **'Edit Meal'**
  String get editMeal;

  /// No description provided for @mealType.
  ///
  /// In en, this message translates to:
  /// **'Meal Type'**
  String get mealType;

  /// No description provided for @deleteMeal.
  ///
  /// In en, this message translates to:
  /// **'Delete Meal'**
  String get deleteMeal;

  /// No description provided for @viewRecipe.
  ///
  /// In en, this message translates to:
  /// **'View Recipe'**
  String get viewRecipe;

  /// No description provided for @plannedMeals.
  ///
  /// In en, this message translates to:
  /// **'Planned Meals'**
  String get plannedMeals;

  /// No description provided for @addFirstMeal.
  ///
  /// In en, this message translates to:
  /// **'Add First Meal'**
  String get addFirstMeal;

  /// No description provided for @areYouSureDeleteMeal.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String areYouSureDeleteMeal(String title);

  /// No description provided for @mealAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Meal added successfully'**
  String get mealAddedSuccessfully;

  /// No description provided for @mealDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Meal deleted successfully'**
  String get mealDeletedSuccessfully;

  /// No description provided for @pleaseEnterMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a meal title'**
  String get pleaseEnterMealTitle;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get appLock;

  /// No description provided for @shareAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Share analytics'**
  String get shareAnalytics;

  /// No description provided for @shoppingList.
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get shoppingList;

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editItem;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get itemName;

  /// No description provided for @addNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Add New Category'**
  String get addNewCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @addNewItem.
  ///
  /// In en, this message translates to:
  /// **'Add New Item'**
  String get addNewItem;

  /// No description provided for @manageDoctors.
  ///
  /// In en, this message translates to:
  /// **'Manage Doctors'**
  String get manageDoctors;

  /// No description provided for @addDoctor.
  ///
  /// In en, this message translates to:
  /// **'Add Doctor'**
  String get addDoctor;

  /// No description provided for @deleteDoctor.
  ///
  /// In en, this message translates to:
  /// **'Delete Doctor'**
  String get deleteDoctor;

  /// No description provided for @doctorInformation.
  ///
  /// In en, this message translates to:
  /// **'Doctor Information'**
  String get doctorInformation;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @saveDoctor.
  ///
  /// In en, this message translates to:
  /// **'Save Doctor'**
  String get saveDoctor;

  /// No description provided for @failedToSaveDoctor.
  ///
  /// In en, this message translates to:
  /// **'Failed to save doctor'**
  String get failedToSaveDoctor;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @appointmentReminders.
  ///
  /// In en, this message translates to:
  /// **'Appointment reminders'**
  String get appointmentReminders;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email notifications'**
  String get emailNotifications;

  /// No description provided for @importantAlerts.
  ///
  /// In en, this message translates to:
  /// **'Important alerts'**
  String get importantAlerts;

  /// No description provided for @noAppointments.
  ///
  /// In en, this message translates to:
  /// **'No appointments'**
  String get noAppointments;

  /// No description provided for @editAppointment.
  ///
  /// In en, this message translates to:
  /// **'Edit Appointment'**
  String get editAppointment;

  /// No description provided for @newAppointment.
  ///
  /// In en, this message translates to:
  /// **'New Appointment'**
  String get newAppointment;

  /// No description provided for @enableReminder.
  ///
  /// In en, this message translates to:
  /// **'Enable Reminder'**
  String get enableReminder;

  /// No description provided for @testNotification.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotification;

  /// No description provided for @saveAppointment.
  ///
  /// In en, this message translates to:
  /// **'Save Appointment'**
  String get saveAppointment;

  /// No description provided for @updateAppointment.
  ///
  /// In en, this message translates to:
  /// **'Update Appointment'**
  String get updateAppointment;

  /// No description provided for @selectDoctor.
  ///
  /// In en, this message translates to:
  /// **'Select Doctor'**
  String get selectDoctor;

  /// No description provided for @pleasSelectDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Please select date and time'**
  String get pleasSelectDateAndTime;

  /// No description provided for @errorSavingAppointment.
  ///
  /// In en, this message translates to:
  /// **'Error saving appointment'**
  String get errorSavingAppointment;

  /// No description provided for @appointmentDetails.
  ///
  /// In en, this message translates to:
  /// **'Appointment Details'**
  String get appointmentDetails;

  /// No description provided for @unknownDoctor.
  ///
  /// In en, this message translates to:
  /// **'Unknown Doctor'**
  String get unknownDoctor;

  /// No description provided for @appointmentTime.
  ///
  /// In en, this message translates to:
  /// **'Appointment Time'**
  String get appointmentTime;

  /// No description provided for @noAppointmentData.
  ///
  /// In en, this message translates to:
  /// **'No appointment data'**
  String get noAppointmentData;

  /// No description provided for @noDoctorAssigned.
  ///
  /// In en, this message translates to:
  /// **'No doctor assigned'**
  String get noDoctorAssigned;

  /// No description provided for @medicineName.
  ///
  /// In en, this message translates to:
  /// **'Medicine Name'**
  String get medicineName;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @weeks.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get weeks;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get months;

  /// No description provided for @every.
  ///
  /// In en, this message translates to:
  /// **'Every:'**
  String get every;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours  Start:'**
  String get hours;

  /// No description provided for @notesFieldCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Notes field cannot be empty! Please add notes.'**
  String get notesFieldCannotBeEmpty;

  /// No description provided for @pleaseSelectSleepQuality.
  ///
  /// In en, this message translates to:
  /// **'Please select sleep quality.'**
  String get pleaseSelectSleepQuality;

  /// No description provided for @userNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'User not authenticated'**
  String get userNotAuthenticated;

  /// No description provided for @sleepLogUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Sleep log updated successfully!'**
  String get sleepLogUpdatedSuccessfully;

  /// No description provided for @sleepLoggedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Sleep logged successfully!'**
  String get sleepLoggedSuccessfully;

  /// No description provided for @failedToLogSleep.
  ///
  /// In en, this message translates to:
  /// **'Failed to log sleep.'**
  String get failedToLogSleep;

  /// No description provided for @thisSleepLogAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This sleep log already exists!'**
  String get thisSleepLogAlreadyExists;

  /// No description provided for @growthLogUpdated.
  ///
  /// In en, this message translates to:
  /// **'Growth log updated'**
  String get growthLogUpdated;

  /// No description provided for @growthDataLoggedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Growth data logged successfully!'**
  String get growthDataLoggedSuccessfully;

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save'**
  String get failedToSave;

  /// No description provided for @mealUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Meal updated successfully'**
  String get mealUpdatedSuccessfully;

  /// No description provided for @selectBaby.
  ///
  /// In en, this message translates to:
  /// **'Select Baby'**
  String get selectBaby;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @unknownTab.
  ///
  /// In en, this message translates to:
  /// **'Unknown Tab'**
  String get unknownTab;

  /// No description provided for @emergencyCard.
  ///
  /// In en, this message translates to:
  /// **'Emergency Card'**
  String get emergencyCard;

  /// No description provided for @errorLoadingBabyData.
  ///
  /// In en, this message translates to:
  /// **'Error loading baby data'**
  String get errorLoadingBabyData;

  /// No description provided for @openDrawer.
  ///
  /// In en, this message translates to:
  /// **'Open Drawer'**
  String get openDrawer;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @babyInformationUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Baby information updated successfully!'**
  String get babyInformationUpdatedSuccessfully;

  /// No description provided for @errorUpdating.
  ///
  /// In en, this message translates to:
  /// **'Error updating'**
  String get errorUpdating;

  /// No description provided for @imageUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Image upload failed'**
  String get imageUploadFailed;

  /// No description provided for @editBabyProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Baby Profile'**
  String get editBabyProfile;

  /// No description provided for @imageUploadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Image uploaded successfully'**
  String get imageUploadedSuccessfully;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get uploadFailed;

  /// No description provided for @uploadProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Upload Profile Picture'**
  String get uploadProfilePicture;

  /// No description provided for @chooseAndUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Choose & Upload Image'**
  String get chooseAndUploadImage;

  /// No description provided for @saveEmergencyCard.
  ///
  /// In en, this message translates to:
  /// **'Save Emergency Card'**
  String get saveEmergencyCard;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @addAllergy.
  ///
  /// In en, this message translates to:
  /// **'Add Allergy'**
  String get addAllergy;

  /// No description provided for @addMedication.
  ///
  /// In en, this message translates to:
  /// **'Add Medication'**
  String get addMedication;

  /// No description provided for @medications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// No description provided for @createEmergencyCard.
  ///
  /// In en, this message translates to:
  /// **'Create Emergency Card'**
  String get createEmergencyCard;

  /// No description provided for @selectChildToViewEmergencyCard.
  ///
  /// In en, this message translates to:
  /// **'Select a child to view emergency card.'**
  String get selectChildToViewEmergencyCard;

  /// No description provided for @generatingEmergencyCardPdf.
  ///
  /// In en, this message translates to:
  /// **'Generating Emergency Card PDF...'**
  String get generatingEmergencyCardPdf;

  /// No description provided for @emergencyCardPdfGeneratedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Emergency Card PDF generated successfully!'**
  String get emergencyCardPdfGeneratedSuccessfully;

  /// No description provided for @myBabies.
  ///
  /// In en, this message translates to:
  /// **'My Babies'**
  String get myBabies;

  /// No description provided for @deleteBaby.
  ///
  /// In en, this message translates to:
  /// **'Delete Baby'**
  String get deleteBaby;

  /// No description provided for @areYouSureDeleteBaby.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this baby?'**
  String get areYouSureDeleteBaby;

  /// No description provided for @noChildSelected.
  ///
  /// In en, this message translates to:
  /// **'No child selected for gallery'**
  String get noChildSelected;

  /// No description provided for @pleasePickImageAndEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please pick an image and enter a title'**
  String get pleasePickImageAndEnterTitle;

  /// No description provided for @uploadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get uploadFailedError;

  /// No description provided for @babyDetailsSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Baby details saved successfully'**
  String get babyDetailsSavedSuccessfully;

  /// No description provided for @pdfExportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'PDF exported successfully!'**
  String get pdfExportedSuccessfully;

  /// No description provided for @errorExportingPdf.
  ///
  /// In en, this message translates to:
  /// **'Error exporting PDF'**
  String get errorExportingPdf;

  /// No description provided for @noLogsToExport.
  ///
  /// In en, this message translates to:
  /// **'No logs to export'**
  String get noLogsToExport;

  /// No description provided for @totalLogs.
  ///
  /// In en, this message translates to:
  /// **'Total Logs'**
  String get totalLogs;

  /// No description provided for @child.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get child;

  /// No description provided for @generated.
  ///
  /// In en, this message translates to:
  /// **'Generated'**
  String get generated;

  /// No description provided for @sleepLogsReport.
  ///
  /// In en, this message translates to:
  /// **'Sleep Logs Report'**
  String get sleepLogsReport;

  /// No description provided for @medicationLogsReport.
  ///
  /// In en, this message translates to:
  /// **'Medication Logs Report'**
  String get medicationLogsReport;

  /// No description provided for @growthLogsReport.
  ///
  /// In en, this message translates to:
  /// **'Growth Logs Report'**
  String get growthLogsReport;

  /// No description provided for @feedingLogsReport.
  ///
  /// In en, this message translates to:
  /// **'Feeding Logs Report'**
  String get feedingLogsReport;

  /// No description provided for @noDataToDisplay.
  ///
  /// In en, this message translates to:
  /// **'No data to display'**
  String get noDataToDisplay;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login Successful'**
  String get loginSuccessful;

  /// No description provided for @signUpSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Sign Up Successful!'**
  String get signUpSuccessful;

  /// No description provided for @failedToMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Failed to mark done'**
  String get failedToMarkDone;

  /// No description provided for @noRouteDefinedFor.
  ///
  /// In en, this message translates to:
  /// **'No route defined for'**
  String get noRouteDefinedFor;

  /// No description provided for @monthView.
  ///
  /// In en, this message translates to:
  /// **'Month View'**
  String get monthView;

  /// No description provided for @weekView.
  ///
  /// In en, this message translates to:
  /// **'Week View'**
  String get weekView;

  /// No description provided for @dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// No description provided for @pill.
  ///
  /// In en, this message translates to:
  /// **'Pill'**
  String get pill;

  /// No description provided for @ml.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get ml;

  /// No description provided for @drugDrop.
  ///
  /// In en, this message translates to:
  /// **'Drop'**
  String get drugDrop;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @onceADay.
  ///
  /// In en, this message translates to:
  /// **'Once a day'**
  String get onceADay;

  /// No description provided for @twiceADay.
  ///
  /// In en, this message translates to:
  /// **'Twice a day'**
  String get twiceADay;

  /// No description provided for @threeTimesADay.
  ///
  /// In en, this message translates to:
  /// **'Three times a day'**
  String get threeTimesADay;

  /// No description provided for @times.
  ///
  /// In en, this message translates to:
  /// **'Times'**
  String get times;

  /// No description provided for @scheduleDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get scheduleDuration;

  /// No description provided for @saveSchedule.
  ///
  /// In en, this message translates to:
  /// **'Save Schedule'**
  String get saveSchedule;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @pleaseSelectTime.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one time'**
  String get pleaseSelectTime;

  /// No description provided for @medicationSummary.
  ///
  /// In en, this message translates to:
  /// **'Medication Summary'**
  String get medicationSummary;

  /// No description provided for @scheduledPrefix.
  ///
  /// In en, this message translates to:
  /// **'Scheduled: '**
  String get scheduledPrefix;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// No description provided for @doctorOptional.
  ///
  /// In en, this message translates to:
  /// **'Doctor (Optional)'**
  String get doctorOptional;

  /// No description provided for @addNewDoctor.
  ///
  /// In en, this message translates to:
  /// **'Add New Doctor'**
  String get addNewDoctor;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @durationMinutesOptional.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes, optional)'**
  String get durationMinutesOptional;

  /// No description provided for @locationOptional.
  ///
  /// In en, this message translates to:
  /// **'Location (Optional)'**
  String get locationOptional;

  /// No description provided for @hospitalNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Hospital Name (Optional)'**
  String get hospitalNameOptional;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @statusScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get statusScheduled;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get statusMissed;

  /// No description provided for @remindMeMinutesBefore.
  ///
  /// In en, this message translates to:
  /// **'Remind me (minutes before)'**
  String get remindMeMinutesBefore;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notesOptional;

  /// No description provided for @pleaseSelectDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Please select date and time'**
  String get pleaseSelectDateAndTime;

  /// No description provided for @appointmentReminder.
  ///
  /// In en, this message translates to:
  /// **'Appointment Reminder'**
  String get appointmentReminder;

  /// No description provided for @quantityMl.
  ///
  /// In en, this message translates to:
  /// **'Quantity (ml)'**
  String get quantityMl;

  /// No description provided for @addAnyNotes.
  ///
  /// In en, this message translates to:
  /// **'Add any notes...'**
  String get addAnyNotes;

  /// No description provided for @editGrowthLog.
  ///
  /// In en, this message translates to:
  /// **'Edit Growth Log'**
  String get editGrowthLog;

  /// No description provided for @addGrowthData.
  ///
  /// In en, this message translates to:
  /// **'Add Growth Data'**
  String get addGrowthData;

  /// No description provided for @enter.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get enter;

  /// No description provided for @updateGrowthData.
  ///
  /// In en, this message translates to:
  /// **'Update Growth Data'**
  String get updateGrowthData;

  /// No description provided for @logGrowthData.
  ///
  /// In en, this message translates to:
  /// **'Log Growth Data'**
  String get logGrowthData;

  /// No description provided for @pleaseEnterValidNumericValues.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid numeric values for weight, height and head circumference.'**
  String get pleaseEnterValidNumericValues;

  /// No description provided for @chooseTracker.
  ///
  /// In en, this message translates to:
  /// **'Choose a tracker'**
  String get chooseTracker;

  /// No description provided for @whenDoesBabySleep.
  ///
  /// In en, this message translates to:
  /// **'When does your baby sleep?'**
  String get whenDoesBabySleep;

  /// No description provided for @addSleepNotes.
  ///
  /// In en, this message translates to:
  /// **'Add sleep notes...'**
  String get addSleepNotes;

  /// No description provided for @selectSleepQuality.
  ///
  /// In en, this message translates to:
  /// **'Select sleep quality'**
  String get selectSleepQuality;

  /// No description provided for @qualityNotGood.
  ///
  /// In en, this message translates to:
  /// **'Not Good'**
  String get qualityNotGood;

  /// No description provided for @qualityGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get qualityGood;

  /// No description provided for @qualityExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get qualityExcellent;

  /// No description provided for @updateSleepLog.
  ///
  /// In en, this message translates to:
  /// **'Update Sleep Log'**
  String get updateSleepLog;

  /// No description provided for @logSleepTime.
  ///
  /// In en, this message translates to:
  /// **'Log Sleep Time'**
  String get logSleepTime;

  /// No description provided for @notesCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Notes field cannot be empty! Please add notes.'**
  String get notesCannotBeEmpty;

  /// No description provided for @sleepLogExists.
  ///
  /// In en, this message translates to:
  /// **'This sleep log already exists!'**
  String get sleepLogExists;

  /// No description provided for @pleaseSelectBabyFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a baby first'**
  String get pleaseSelectBabyFirst;

  /// No description provided for @medicineScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Medicine Schedule'**
  String get medicineScheduleTitle;

  /// No description provided for @noMedicinesScheduled.
  ///
  /// In en, this message translates to:
  /// **'No medicines scheduled'**
  String get noMedicinesScheduled;

  /// No description provided for @noMedicinesForDate.
  ///
  /// In en, this message translates to:
  /// **'No medicines for this date'**
  String get noMedicinesForDate;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get night;

  /// No description provided for @weekOf.
  ///
  /// In en, this message translates to:
  /// **'Week of'**
  String get weekOf;

  /// No description provided for @shoppingListTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get shoppingListTitle;

  /// No description provided for @searchShoppingItems.
  ///
  /// In en, this message translates to:
  /// **'Search shopping items...'**
  String get searchShoppingItems;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @areYouSureDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String areYouSureDelete(String title);

  /// No description provided for @mealPlannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal Planner'**
  String get mealPlannerTitle;

  /// No description provided for @mealsDoneCount.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} done'**
  String mealsDoneCount(int done, int total);

  /// No description provided for @noMealsPlanned.
  ///
  /// In en, this message translates to:
  /// **'No meals planned for this day'**
  String get noMealsPlanned;

  /// No description provided for @mealTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get mealTitle;

  /// No description provided for @mealSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Subtitle'**
  String get mealSubtitle;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @recipe.
  ///
  /// In en, this message translates to:
  /// **'Recipe'**
  String get recipe;

  /// No description provided for @mealTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Meal title (e.g., Oatmeal Cereal)'**
  String get mealTitleHint;

  /// No description provided for @ingredientsHint.
  ///
  /// In en, this message translates to:
  /// **'List ingredients (optional)'**
  String get ingredientsHint;

  /// No description provided for @recipeHint.
  ///
  /// In en, this message translates to:
  /// **'Recipe instructions (optional)'**
  String get recipeHint;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @mealAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Meal added successfully'**
  String get mealAddedSuccess;

  /// No description provided for @mealDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Meal deleted successfully'**
  String get mealDeletedSuccess;

  /// No description provided for @markAsDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as Done'**
  String get markAsDone;

  /// No description provided for @markAsNotDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as Not Done'**
  String get markAsNotDone;

  /// No description provided for @doneStatus.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get doneStatus;

  /// No description provided for @noMemoriesYetPrompt.
  ///
  /// In en, this message translates to:
  /// **'No memories yet.\nTap the + button or Add Memory tile to add one.'**
  String get noMemoriesYetPrompt;

  /// No description provided for @uploadFailedWithError.
  ///
  /// In en, this message translates to:
  /// **'Upload failed: {error}'**
  String uploadFailedWithError(String error);

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String dateLabel(String date);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
