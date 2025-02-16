import 'package:flutter/material.dart';

import '../enums/enums.dart';
import '../models/models.dart';

/// A widget that displays a simple bar chart with customizable decorations.
class SliderBarChartWidget extends StatefulWidget {
  /// The data used to generate the bar chart.
  final SbcData data;

  /// The decoration settings for the bar chart.
  final SbcDecoration decoration;

  /// Optional scroll controller for the horizontal scroll view.
  final ScrollController? scrollController;
  const SliderBarChartWidget({
    super.key,
    required this.data,
    this.decoration = const SbcDecoration(),
    this.scrollController,
  });

  @override
  State<SliderBarChartWidget> createState() => _SliderBarChartWidgetState();
}

class _SliderBarChartWidgetState extends State<SliderBarChartWidget> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    if (widget.scrollController == null) {
      _scrollController = ScrollController();
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  String _formatYTitle(double value) {
    if (widget.decoration.titleDecoration.yTitleTextFormatter != null) {
      return widget.decoration.titleDecoration.yTitleTextFormatter!.call(value);
    }

    final valueString = value.toStringAsFixed(2).replaceAll('.00', '');
    return valueString.endsWith('0') && valueString != '0'
        ? valueString.substring(0, valueString.length)
        : valueString;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.decoration.height,
      child: Row(
        children: [
          if (widget.decoration.titleDecoration.showYTitles &&
              widget.decoration.titleDecoration.fixedYTitles &&
              widget.decoration.titleDecoration.yTitlePosition !=
                  YTitlePosition.end) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: SizedBox(
                height: widget.decoration.height - 30,
                child: _yTitles,
              ),
            ),
            const VerticalDivider(thickness: 0.7, width: 0),
          ],
          Expanded(
            child: Scrollbar(
              thumbVisibility: widget.decoration.showScrollbar,
              controller: widget.scrollController ?? _scrollController,
              child: SingleChildScrollView(
                controller: widget.scrollController ?? _scrollController,
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      if (widget.decoration.titleDecoration.showYTitles &&
                          !widget.decoration.titleDecoration.fixedYTitles &&
                          widget.decoration.titleDecoration.yTitlePosition !=
                              YTitlePosition.end)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: SizedBox(
                            height: widget.decoration.height - 30,
                            child: _yTitles,
                          ),
                        ),
                      Row(
                        children: widget.data.xValues
                            .map(
                              (x) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 1),
                                child: _chartWidget(x),
                              ),
                            )
                            .toList(),
                      ),
                      if (widget.decoration.titleDecoration.showYTitles &&
                          !widget.decoration.titleDecoration.fixedYTitles &&
                          widget.decoration.titleDecoration.yTitlePosition !=
                              YTitlePosition.start)
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: SizedBox(
                            height: widget.decoration.height - 30,
                            child: _yTitles,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (widget.decoration.titleDecoration.showYTitles &&
              widget.decoration.titleDecoration.fixedYTitles &&
              widget.decoration.titleDecoration.yTitlePosition !=
                  YTitlePosition.start) ...[
            const VerticalDivider(thickness: 0.7, width: 0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: SizedBox(
                height: widget.decoration.height - 30,
                child: _yTitles,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _xTitle(int x, bool showLabel) {
    return SizedBox(
      height: widget.decoration.titleDecoration.xHeightSpace,
      width: showLabel
          ? widget.decoration.titleDecoration.xWidthSpace
          : widget.decoration.barDecoration.width,
      child: Column(
        children: [
          const Divider(height: 0),
          Expanded(
            child: showLabel
                ? Center(
                    child: FittedBox(
                      child: Text('$x'),
                    ),
                  )
                : const SizedBox(),
          ),
          if (widget.data.y2Values != null) const Divider(height: 0),
        ],
      ),
    );
  }

  Widget get _yTitles {
    final String maxString = _formatYTitle(widget.data.maxY);
    final String midString = _formatYTitle(
      (widget.data.maxY / 2).round().toDouble(),
    );
    final String minString = _formatYTitle(widget.data.minY);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: widget.data.y2Values == null
          ? [
              if (widget.decoration.singleBarPosition == SingleBarPosition.top)
                SizedBox(
                  height: widget.decoration.titleDecoration.xHeightSpace - 10,
                ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.decoration.singleBarPosition ==
                              SingleBarPosition.bottom
                          ? maxString
                          : minString,
                    ),
                    Text(midString),
                    Text(
                      widget.decoration.singleBarPosition ==
                              SingleBarPosition.top
                          ? maxString
                          : minString,
                    ),
                  ],
                ),
              ),
              if (widget.decoration.singleBarPosition ==
                  SingleBarPosition.bottom)
                SizedBox(
                  height: widget.decoration.titleDecoration.xHeightSpace - 10,
                ),
            ]
          : [
              Text(maxString),
              Text(midString),
              Column(
                children: [
                  Text(minString),
                  const SizedBox(height: 20),
                  Text(minString),
                ],
              ),
              Text(midString),
              Text(maxString),
            ],
    );
  }

  Widget _chartWidget(int x) {
    final bool showLabel = x % widget.data.xInterval == 0;
    final double yValue =
        widget.data.yValues.length - 1 >= x ? widget.data.yValues[x] : 0;

    final double? y2Value = widget.data.y2Values == null
        ? null
        : widget.data.y2Values!.length - 1 >= x
            ? widget.data.y2Values![x]
            : 0;

    final double barHeightByMaxY = widget.data.maxY > 0
        ? (widget.data.y2Values == null
                ? widget.decoration.singleBarMaxHeight + 5
                : widget.decoration.doubleBarMaxHeight) /
            widget.data.maxY
        : 0;

    final double yHeight = barHeightByMaxY * yValue;
    final double? y2Height = y2Value == null ? null : barHeightByMaxY * y2Value;

    return SizedBox(
      width: showLabel
          ? widget.decoration.titleDecoration.xWidthSpace
          : widget.decoration.barDecoration.width,
      child: Column(
        children: [
          if (widget.data.y2Values == null &&
              widget.decoration.singleBarPosition == SingleBarPosition.top)
            _xTitle(x, showLabel),
          Expanded(
            child: _barWidget(
              x: x,
              y: yValue,
              yHeight: yHeight,
              color: widget.decoration.barDecoration.yColor ??
                  Theme.of(context).primaryColor,
              position: widget.data.y2Values == null
                  ? switch (widget.decoration.singleBarPosition) {
                      SingleBarPosition.top => _BarWidgetPosition.bottom,
                      SingleBarPosition.bottom => _BarWidgetPosition.top,
                    }
                  : _BarWidgetPosition.top,
            ),
          ),
          if (widget.data.y2Values != null ||
              widget.decoration.singleBarPosition == SingleBarPosition.bottom)
            _xTitle(x, showLabel),
          if (y2Value != null && y2Height != null)
            Expanded(
              child: _barWidget(
                x: x,
                y: y2Value,
                yHeight: y2Height,
                color: Theme.of(context).colorScheme.secondary,
                position: _BarWidgetPosition.bottom,
              ),
            ),
        ],
      ),
    );
  }

  Widget _barWidget({
    required int x,
    required double y,
    required double yHeight,
    required Color color,
    required _BarWidgetPosition position,
  }) {
    return SizedBox(
      width: widget.decoration.barDecoration.width,
      child: Tooltip(
        message: (position == _BarWidgetPosition.top
                ? widget.decoration.tooltipDecoration.yTextFormatter?.call(x, y)
                : widget.decoration.tooltipDecoration.y2TextFormatter
                    ?.call(x, y)) ??
            "${_formatYTitle(y)} ($x)",
        triggerMode: widget.decoration.tooltipDecoration.triggerMode,
        waitDuration: widget.decoration.tooltipDecoration.waitDuration,
        padding: widget.decoration.tooltipDecoration.padding,
        textStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
        ),
        decoration: BoxDecoration(
          color: widget.decoration.tooltipDecoration.backgroundColor ??
              Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(
            widget.decoration.tooltipDecoration.borderRadius,
          ),
          border: widget.decoration.tooltipDecoration.border,
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: Stack(
            children: [
              if (widget.decoration.barDecoration.showAsProgress)
                Positioned(
                  top: position == _BarWidgetPosition.top ? 5 : 0,
                  bottom: position == _BarWidgetPosition.bottom ? 5 : 0,
                  child: Container(
                    width: widget.decoration.barDecoration.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: position == _BarWidgetPosition.top
                            ? const Radius.circular(14)
                            : Radius.zero,
                        topRight: position == _BarWidgetPosition.top
                            ? const Radius.circular(14)
                            : Radius.zero,
                        bottomLeft: position == _BarWidgetPosition.bottom
                            ? const Radius.circular(14)
                            : Radius.zero,
                        bottomRight: position == _BarWidgetPosition.bottom
                            ? const Radius.circular(14)
                            : Radius.zero,
                      ),
                      color: Colors.grey.withAlpha(30),
                    ),
                  ),
                ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: Column(
                  children: [
                    if (position == _BarWidgetPosition.top)
                      const Expanded(child: SizedBox()),
                    Container(
                      height: yHeight,
                      width: widget.decoration.barDecoration.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: position == _BarWidgetPosition.top
                              ? const Radius.circular(14)
                              : Radius.zero,
                          topRight: position == _BarWidgetPosition.top
                              ? const Radius.circular(14)
                              : Radius.zero,
                          bottomLeft: position == _BarWidgetPosition.bottom
                              ? const Radius.circular(14)
                              : Radius.zero,
                          bottomRight: position == _BarWidgetPosition.bottom
                              ? const Radius.circular(14)
                              : Radius.zero,
                        ),
                        color: color,
                      ),
                    ),
                    if (position == _BarWidgetPosition.bottom)
                      const Expanded(child: SizedBox()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _BarWidgetPosition {
  top,
  bottom,
}
