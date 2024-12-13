import 'package:flutter/material.dart';
import 'color_picker_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'main_bloc.dart';

const List<Color> themeAColors = [Color(0xffffeb3b), Color(0xffff7043)];
const List<Color> themeBColors = [
  Color(0xff2196f3),
  Color(0xfff44336),
  Color(0xffffeb3b),
  Color(0xff4caf50),
  Color(0xff00bcd4),
];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => MainBloc(),
        child: const Scaffold(
          body: Center(child: ColorPicker()),
        ),
      ),
    );
  }
}

class ColorPicker extends StatelessWidget {
  const ColorPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MainBloc>();
    final Color initialColor = context.select((MainBloc bloc) => bloc.state.color);
    final ColorTheme cTheme = context.select((MainBloc bloc) => bloc.state.theme);
    final List<Color> colorHistory = context.select((MainBloc bloc) => bloc.state.history);

    final List<Color> colorTheme = [];

    switch (cTheme) {
      case ColorTheme.none:
        break;
      case ColorTheme.a:
        colorTheme.addAll(themeAColors);
        break;
      case ColorTheme.b:
        colorTheme.addAll(themeBColors);
        break;
    }

    return Column(
      children: [
        const _ThemeChooser(),
        const SizedBox(height: 25),
        SizedBox(
          width: 100,
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              color: initialColor,
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(4),
            ),
            child: InkWell(
              onTap: () {
                showDialog<Color?>(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogContext) => ColorPickerDialog(
                    initialColor: initialColor,
                    colorTheme: colorTheme,
                    colorHistory: colorHistory,
                  ),
                ).then((color) {
                  // If color picker dialog is closed with positive action,
                  // pass the color to the onColorChosen callback if it is defined
                  if (color != null) {
                    bloc.add(ColorChanged(color));

                    // Don't add to history if already in the theme color list
                    if (cTheme == ColorTheme.a && themeAColors.contains(color)) return;
                    if (cTheme == ColorTheme.b && themeBColors.contains(color)) return;
                    bloc.add(HistoryColorAdded(color));
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeChooser extends StatelessWidget {
  const _ThemeChooser();

  @override
  Widget build(BuildContext context) {
    final ColorTheme selection = context.select((MainBloc bloc) => bloc.state.theme);

    return SegmentedButton(
      segments: const <ButtonSegment<ColorTheme>>[
        ButtonSegment(value: ColorTheme.none, label: Text('None')),
        ButtonSegment(value: ColorTheme.a, label: Text('Theme A')),
        ButtonSegment(value: ColorTheme.b, label: Text('Theme B')),
      ],
      selected: <ColorTheme>{selection},
      onSelectionChanged: (newSelection) =>
          context.read<MainBloc>().add(ColorThemeChanged(newSelection.first)),
    );
  }
}
