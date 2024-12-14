import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' as flutter_color_picker;

class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final void Function(Color)? onColorChanged;
  final List<Color> colorHistory;
  final List<Color> colorTheme;

  const ColorPickerDialog({
    super.key,
    this.initialColor = Colors.white,
    this.onColorChanged,
    this.colorHistory = const [],
    this.colorTheme = const [],
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _pickerColor;

  @override
  void initState() {
    super.initState();
    _pickerColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Color Picker'),
          IconButton(
            onPressed: () => Navigator.of(context).pop(null),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: flutter_color_picker.ColorPicker(
          labelTypes: const [],
          hexInputBar: true,
          colorPickerWidth: 250,
          pickerAreaHeightPercent: 0.7,
          pickerColor: _pickerColor,
          portraitOnly: true,
          enableAlpha: true,
          colorTheme: widget.colorTheme,
          colorHistory: widget.colorHistory,
          onColorChanged: (color) {
            // Weird behavior where the hue bar looks like it is not working because
            // at value 0xFFFFFFFF or 0xFF0000 changing hue bar and rebuilding widget
            // creates the widget with hue bar point all the way to left side.
            if (color != Colors.white && color != Colors.black) {
              setState(() => _pickerColor = color);
            }

            // Run the custom onColorChanged function if it was passed
            if (widget.onColorChanged != null) widget.onColorChanged!(color);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_pickerColor),
          child: const Text('Done'),
        )
      ],
    );
  }
}
