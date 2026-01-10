import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';
// Note: Adjust the import if your ChildSelectionState is in a separate file but exported by cubit, 
// which it is (part/part of relationship), so importing cubit is enough.

import 'package:tifli/features/logs/data/models/growth_logs_model.dart';
import 'package:tifli/features/trackers/presentation/cubit/growth_cubit.dart';
import 'package:tifli/features/trackers/presentation/screens/growth_tracker_screen.dart';
import 'package:tifli/l10n/app_localizations.dart';

// --- Mocks ---
// We mock the Cubits to avoid depending on the real backend (Supabase/Firebase) 
// and to control the state precisely for the UI test.

class MockChildSelectionCubit extends MockCubit<ChildSelectionState>
    implements ChildSelectionCubit {}

class MockGrowthCubit extends MockCubit<List<GrowthLog>> implements GrowthCubit {}

void main() {
  // Initialize Integration Test binding. This is required for integration tests.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockChildSelectionCubit mockChildSelectionCubit;
  late MockGrowthCubit mockGrowthCubit;

  setUp(() {
    mockChildSelectionCubit = MockChildSelectionCubit();
    mockGrowthCubit = MockGrowthCubit();
  });

  // --- Test Description ---
  // This test verifies that a user can:
  // 1. View the Growth Tracker form.
  // 2. Enter valid numeric data for Weight, Height, and Head Circumference.
  // 3. Tap the "Log Growth Data" button.
  // 4. Trigger the correct Cubit method call.
  // 5. See a success message.
  
  testWidgets('Integration Test: Add Growth Record Flow', (tester) async {
    
    // 1. Setup Mock States
    const testChildId = 'test_child_123';
    const testChildName = 'Test Baby';
    
    // Simulate that a child is already selected
    when(() => mockChildSelectionCubit.state)
        .thenReturn(ChildSelected(childId: testChildId, childName: testChildName));

    // Stub the addGrowthLog method to return void (simulating success)
    when(() => mockGrowthCubit.addGrowthLog(
          childId: any(named: 'childId'),
          date: any(named: 'date'),
          weight: any(named: 'weight'),
          height: any(named: 'height'),
          headCircumference: any(named: 'headCircumference'),
          notes: any(named: 'notes'),
        )).thenAnswer((_) async {});

    // 2. Load the Widget under test
    // We wrap GrowthPage with the necessary Providers and MaterialApp 
    // to provide context (Theme, Localization, Cubits).
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ChildSelectionCubit>.value(
            value: mockChildSelectionCubit,
          ),
          BlocProvider<GrowthCubit>.value(
            value: mockGrowthCubit,
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: GrowthPage(),
        ),
      ),
    );

    // Wait for the UI to settle (animations, etc.)
    await tester.pumpAndSettle();
    
    // Check for errors
    expect(find.byType(ErrorWidget), findsNothing);

    // 3. Verify Initial UI
    // Check if the AppBar title is correct (using a Localized string search might be brittle if we don't know the exact string, 
    // but in En it is "Add Growth Data"). 
    // Note: We depend on english locale by default test setup.
    expect(find.byType(AppBar), findsOneWidget);
    
    // 4. Interact with the Form
    // Find TextFields. There are 4 TextFields (Weight, Height, Head Circ, Notes).
    // We can interact by finding the label text which is part of the implementation we viewed.
    // The implementation uses `_buildMeasurementField` which has `Text(label, ...)` above the field.
    // However, `recorder` might see the `hintText` inside the InputDecoration roughly matching the label.
    
    // Enter Weight
    await tester.enterText(find.byKey(const Key('weight_field')), '6.5');
    await tester.pump(); // allow text update

    // Enter Height
    await tester.enterText(find.byKey(const Key('height_field')), '62.0');
    await tester.pump();
    
    // Enter Head Circumference
    await tester.enterText(find.byKey(const Key('head_circumference_field')), '40.0');
    await tester.pump();

    // 5. Submit Form
    // Find the save button using Key
    final saveButton = find.byKey(const Key('save_growth_button'));
    
    // Scroll until visible (essential for smaller screens or virtual devices)
    await tester.scrollUntilVisible(saveButton, 50);
    expect(saveButton, findsOneWidget);
    
    await tester.tap(saveButton);
    
    // 6. Verify Logic
    // Pump to process the tap and the async Cubit call
    await tester.pump(); 

    // Verify correct data was passed to the Cubit
    verify(() => mockGrowthCubit.addGrowthLog(
          childId: testChildId,
          date: any(named: 'date'), // exact date is Now(), so tough to match exactly, use any()
          weight: 6.5,
          height: 62.0,
          headCircumference: 40.0,
          notes: any(named: 'notes'),
        )).called(1);
    
    // 7. Verify Feedback
    // Wait for SnackBar animation
    await tester.pump(const Duration(milliseconds: 500)); 
    expect(find.text('Growth data logged successfully'), findsOneWidget);
  });
}
