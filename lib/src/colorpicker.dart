/// HSV(HSB)/HSL Color Picker example
///
/// You can create your own layout by importing `picker.dart`.

library hsv_picker;

import 'package:flutter/material.dart';
import 'palette.dart';
import 'utils.dart';

/// The default layout of Color Picker.
class ColorPicker extends StatefulWidget {
  const ColorPicker({
    Key? key,
    required this.pickerColor,
    required this.onColorChanged,
    this.pickerHsvColor,
    this.onHsvColorChanged,
    this.enableAlpha = true,
    @Deprecated('Use empty list in [labelTypes] to disable label.') this.showLabel = true,
    this.labelTypes = const [ColorLabelType.rgb, ColorLabelType.hsv, ColorLabelType.hsl],
    @Deprecated('Use Theme.of(context).textTheme.bodyText1 & 2 to alter text style.')
    this.labelTextStyle,
    this.displayThumbColor = false,
    this.portraitOnly = false,
    this.colorPickerWidth = 300.0,
    this.pickerAreaHeightPercent = 1.0,
    this.pickerAreaBorderRadius = const BorderRadius.all(Radius.zero),
    this.hexInputBar = false,
    this.hexInputController,
    this.colorHistory,
    this.colorTheme,
  }) : super(key: key);

  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;
  final HSVColor? pickerHsvColor;
  final ValueChanged<HSVColor>? onHsvColorChanged;
  final bool enableAlpha;
  final bool showLabel;
  final List<ColorLabelType> labelTypes;
  final TextStyle? labelTextStyle;
  final bool displayThumbColor;
  final bool portraitOnly;
  final double colorPickerWidth;
  final double pickerAreaHeightPercent;
  final BorderRadius pickerAreaBorderRadius;
  final bool hexInputBar;
  final TextEditingController? hexInputController;
  final List<Color>? colorHistory;
  final List<Color>? colorTheme;

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  HSVColor currentHsvColor = const HSVColor.fromAHSV(0.0, 0.0, 0.0, 0.0);
  List<Color> colorHistory = [];
  List<Color> colorTheme = [];

  @override
  void initState() {
    currentHsvColor = (widget.pickerHsvColor != null)
        ? widget.pickerHsvColor as HSVColor
        : HSVColor.fromColor(widget.pickerColor);
    // If there's no initial text in `hexInputController`,
    if (widget.hexInputController?.text.isEmpty == true) {
      // set it to the current's color HEX value.
      widget.hexInputController?.text = colorToHex(
        currentHsvColor.toColor(),
        enableAlpha: widget.enableAlpha,
      );
    }
    // Listen to the text input, If there is an `hexInputController` provided.
    widget.hexInputController?.addListener(colorPickerTextInputListener);
    if (widget.colorHistory != null) {
      colorHistory = widget.colorHistory ?? [];
    }
    if (widget.colorTheme != null) {
      colorTheme = widget.colorTheme ?? [];
    }
    super.initState();
  }

  @override
  void didUpdateWidget(ColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    currentHsvColor = (widget.pickerHsvColor != null)
        ? widget.pickerHsvColor as HSVColor
        : HSVColor.fromColor(widget.pickerColor);
  }

  void colorPickerTextInputListener() {
    // It can't be null really, since it's only listening if the controller
    // is provided, but it may help to calm the Dart analyzer in the future.
    if (widget.hexInputController == null) return;
    // If a user is inserting/typing any text — try to get the color value from it,
    // and interpret its transparency, dependent on the widget's settings.
    final Color? color =
        colorFromHex(widget.hexInputController!.text, enableAlpha: widget.enableAlpha);
    // If it's the valid color:
    if (color != null) {
      // set it as the current color and
      setState(() => currentHsvColor = HSVColor.fromColor(color));
      // notify with a callback.
      widget.onColorChanged(color);
      if (widget.onHsvColorChanged != null) widget.onHsvColorChanged!(currentHsvColor);
    }
  }

  @override
  void dispose() {
    widget.hexInputController?.removeListener(colorPickerTextInputListener);
    super.dispose();
  }

  Widget colorPickerSlider(TrackType trackType) {
    return ColorPickerSlider(
      trackType,
      currentHsvColor,
      (HSVColor color) {
        // Update text in `hexInputController` if provided.
        widget.hexInputController?.text =
            colorToHex(color.toColor(), enableAlpha: widget.enableAlpha);
        setState(() => currentHsvColor = color);
        widget.onColorChanged(currentHsvColor.toColor());
        if (widget.onHsvColorChanged != null) widget.onHsvColorChanged!(currentHsvColor);
      },
      displayThumbColor: widget.displayThumbColor,
    );
  }

  void onColorChanging(HSVColor color) {
    // Update text in `hexInputController` if provided.
    widget.hexInputController?.text =
        colorToHex(color.toColor(), enableAlpha: widget.enableAlpha);
    setState(() => currentHsvColor = color);
    widget.onColorChanged(currentHsvColor.toColor());
    if (widget.onHsvColorChanged != null) widget.onHsvColorChanged!(currentHsvColor);
  }

  Widget colorPicker() {
    return ClipRRect(
      borderRadius: widget.pickerAreaBorderRadius,
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: ColorPickerArea(currentHsvColor, onColorChanging),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait || widget.portraitOnly) {
      return Column(
        children: <Widget>[
          SizedBox(
            width: widget.colorPickerWidth,
            height: widget.colorPickerWidth * widget.pickerAreaHeightPercent,
            child: colorPicker(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 5.0, 10.0, 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ColorIndicator(currentHsvColor),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                          height: 40.0,
                          width: widget.colorPickerWidth - 75.0,
                          child: colorPickerSlider(TrackType.hue)),
                      if (widget.enableAlpha)
                        SizedBox(
                          height: 40.0,
                          width: widget.colorPickerWidth - 75.0,
                          child: colorPickerSlider(TrackType.alpha),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (colorTheme.isNotEmpty)
            SizedBox(
              width: widget.colorPickerWidth,
              height: 40,
              child: ListView(scrollDirection: Axis.horizontal, children: <Widget>[
                for (Color color in colorTheme)
                  Padding(
                    key: Key(color.hashCode.toString()),
                    padding: const EdgeInsets.fromLTRB(15, 0, 0, 10),
                    child: Center(
                      child: GestureDetector(
                        onTap: () => onColorChanging(HSVColor.fromColor(color)),
                        child:
                            ColorIndicator(HSVColor.fromColor(color), width: 30, height: 30),
                      ),
                    ),
                  ),
                const SizedBox(width: 15),
              ]),
            ),
          if (colorHistory.isNotEmpty)
            SizedBox(
              width: widget.colorPickerWidth,
              height: 40,
              child: ListView(scrollDirection: Axis.horizontal, children: <Widget>[
                for (Color color in colorHistory)
                  Padding(
                    key: Key(color.hashCode.toString()),
                    padding: const EdgeInsets.fromLTRB(15, 0, 0, 10),
                    child: Center(
                      child: GestureDetector(
                        onTap: () => onColorChanging(HSVColor.fromColor(color)),
                        child:
                            ColorIndicator(HSVColor.fromColor(color), width: 30, height: 30),
                      ),
                    ),
                  ),
                const SizedBox(width: 15),
              ]),
            ),
          if (widget.showLabel && widget.labelTypes.isNotEmpty)
            FittedBox(
              child: ColorPickerLabel(
                currentHsvColor,
                enableAlpha: widget.enableAlpha,
                textStyle: widget.labelTextStyle,
                colorLabelTypes: widget.labelTypes,
              ),
            ),
          if (widget.hexInputBar)
            ColorPickerInput(
              currentHsvColor.toColor(),
              (Color color) {
                setState(() => currentHsvColor = HSVColor.fromColor(color));
                widget.onColorChanged(currentHsvColor.toColor());
                if (widget.onHsvColorChanged != null) {
                  widget.onHsvColorChanged!(currentHsvColor);
                }
              },
              enableAlpha: widget.enableAlpha,
              embeddedText: false,
            ),
          const SizedBox(height: 20.0),
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          SizedBox(
              width: widget.colorPickerWidth,
              height: widget.colorPickerWidth * widget.pickerAreaHeightPercent,
              child: colorPicker()),
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  const SizedBox(width: 20.0),
                  ColorIndicator(currentHsvColor),
                  Column(
                    children: <Widget>[
                      SizedBox(
                        height: 40.0,
                        width: 260.0,
                        child: colorPickerSlider(TrackType.hue),
                      ),
                      if (widget.enableAlpha)
                        SizedBox(
                            height: 40.0,
                            width: 260.0,
                            child: colorPickerSlider(TrackType.alpha)),
                    ],
                  ),
                  const SizedBox(width: 10.0),
                ],
              ),
              if (colorHistory.isNotEmpty)
                SizedBox(
                  width: widget.colorPickerWidth,
                  height: 50,
                  child: ListView(scrollDirection: Axis.horizontal, children: <Widget>[
                    for (Color color in colorHistory)
                      Padding(
                        key: Key(color.hashCode.toString()),
                        padding: const EdgeInsets.fromLTRB(15, 18, 0, 0),
                        child: Center(
                          child: GestureDetector(
                            onTap: () => onColorChanging(HSVColor.fromColor(color)),
                            child: ColorIndicator(HSVColor.fromColor(color),
                                width: 30, height: 30),
                          ),
                        ),
                      ),
                    const SizedBox(width: 15),
                  ]),
                ),
              const SizedBox(height: 20.0),
              if (widget.showLabel && widget.labelTypes.isNotEmpty)
                FittedBox(
                  child: ColorPickerLabel(
                    currentHsvColor,
                    enableAlpha: widget.enableAlpha,
                    textStyle: widget.labelTextStyle,
                    colorLabelTypes: widget.labelTypes,
                  ),
                ),
              if (widget.hexInputBar)
                ColorPickerInput(
                  currentHsvColor.toColor(),
                  (Color color) {
                    setState(() => currentHsvColor = HSVColor.fromColor(color));
                    widget.onColorChanged(currentHsvColor.toColor());
                    if (widget.onHsvColorChanged != null) {
                      widget.onHsvColorChanged!(currentHsvColor);
                    }
                  },
                  enableAlpha: widget.enableAlpha,
                  embeddedText: false,
                ),
              const SizedBox(height: 5),
            ],
          ),
        ],
      );
    }
  }
}
