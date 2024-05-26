import 'package:flutter/material.dart';

class DynamicToastMessageConfiguration {
  final Offset offset;
  final Alignment alignment;
  final Type? type;

  const DynamicToastMessageConfiguration({
    this.offset = const Offset(0, 0),
    this.alignment = Alignment.bottomCenter,
    this.type,
  });
}

abstract class DynamicToastMessage {
  /// ignore: library_private_types_in_public_api
  static _DynamicToastMessageState of(BuildContext context) {
    return _DynamicToastMessageState(context);
  }

  static configure({
    required Function(BuildContext context, Widget child) builder,
    Map<Type, DynamicToastMessageConfiguration> consideredWidgetTypes = const {},
    Duration duration = const Duration(seconds: 2),
    Duration fadeDuration = const Duration(milliseconds: 500),
    bool autoDismiss = true,
    Function(BuildContext context, AnimationController controller, Widget child, Alignment alignment, Offset offset)? animationBuilder,
  }) {
    _consideredWidgetTypes = consideredWidgetTypes;
    _builder = builder;
    _duration = duration;
    _fadeDuration = fadeDuration;
    _autoDismiss = autoDismiss;
    _animationBuilder = animationBuilder;
  }

  static late Map<Type, DynamicToastMessageConfiguration> _consideredWidgetTypes;
  static Map<Type, DynamicToastMessageConfiguration> get consideredWidgetTypes => _consideredWidgetTypes;

  static late Function(BuildContext context, Widget child) _builder;
  static Function(BuildContext context, Widget child) get builder => _builder;

  static late Duration _duration;
  static Duration get duration => _duration;

  static late Duration _fadeDuration;
  static Duration get fadeDuration => _fadeDuration;

  static late bool _autoDismiss;
  static bool get autoDismiss => _autoDismiss;

  static late Function(BuildContext context, AnimationController controller, Widget child, Alignment alignment, Offset offset)? _animationBuilder;
  static Function(BuildContext context, AnimationController controller, Widget child, Alignment alignment, Offset offset)? get animationBuilder => _animationBuilder;
}

class _DynamicToastMessageState {
  final BuildContext context;

  _DynamicToastMessageState(this.context);

  void show(Widget child, {DynamicToastMessageConfiguration? configuration}) {
    final List<Type> types = _findConsideredWidgetTypes(DynamicToastMessage.consideredWidgetTypes.keys.toList());

    OverlayEntry entry = OverlayEntry(
      builder: (context) {
        return _DynamicToastMessageWidget(
          type: types.firstOrNull,
          configuration: configuration,
          child: child,
        );
      },
    );

    Overlay.of(context).insert(entry);
    if (DynamicToastMessage.autoDismiss) {
      Future.delayed(DynamicToastMessage.duration, () {
        entry.remove();
      });
    }
  }

  BuildContext? _findPageBuildContext(BuildContext context) {
    BuildContext? result;

    context.visitChildElements((element) {
      if (element.widget.runtimeType == Scaffold) {
        result = element;
        return;
      }
    });

    if (result != null) {
      return result;
    }

    return context.findAncestorStateOfType<ScaffoldState>()?.context;
  }

  List<Type> _findConsideredWidgetTypes(List<Type> types) {
    final rootContext = _findPageBuildContext(context);
    final found = <Type>[];

    void search(Element element) {
      if (types.contains(element.widget.runtimeType)) {
        found.add(element.widget.runtimeType);
        return;
      }
      element.visitChildren(search);
    }

    rootContext?.visitChildElements(search);
    return found;
  }
}

class _DynamicToastMessageWidget extends StatefulWidget {
  const _DynamicToastMessageWidget({
    required this.type,
    required this.child,
    this.configuration,
  });

  final Type? type;
  final Widget child;
  final DynamicToastMessageConfiguration? configuration;

  @override
  State<_DynamicToastMessageWidget> createState() => _DynamicToastMessageWidgetState();
}

class _DynamicToastMessageWidgetState extends State<_DynamicToastMessageWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(duration: DynamicToastMessage.fadeDuration, vsync: this);

  @override
  void initState() {
    _controller.forward();
    if (DynamicToastMessage.autoDismiss) {
      Future.delayed(DynamicToastMessage.duration - DynamicToastMessage.fadeDuration, () {
        _controller.reverse();
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: widget.configuration?.alignment ?? DynamicToastMessage.consideredWidgetTypes[widget.type]?.alignment ?? Alignment.bottomCenter,
        child: Transform.translate(
          offset: widget.configuration?.offset ?? DynamicToastMessage.consideredWidgetTypes[widget.type]?.offset ?? const Offset(0, -8),
          child: Material(
            color: Colors.transparent,
            child: DynamicToastMessage.animationBuilder?.call(
                  context,
                  _controller,
                  DynamicToastMessage.builder(context, widget.child),
                  widget.configuration?.alignment ?? DynamicToastMessage.consideredWidgetTypes[widget.type]?.alignment ?? Alignment.bottomCenter,
                  widget.configuration?.offset ?? DynamicToastMessage.consideredWidgetTypes[widget.type]?.offset ?? const Offset(0, -8),
                ) ??
                FadeTransition(
                  opacity: _controller,
                  child: DynamicToastMessage.builder(context, widget.child),
                ),
          ),
        ),
      ),
    );
  }
}
