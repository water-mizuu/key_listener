import "dart:async";
import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:window_manager/window_manager.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();

    await WindowManager.instance.setMinimumSize(const Size(600, 700));
    // await WindowManager.instance.setSize(const Size(400, 650));
  }
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final FocusNode focusNode;
  late final Set<LogicalKeyboardKey> active;

  late bool hasCopied;
  late (double, double) mousePosition;
  KeyEvent? lastKeyEvent;

  @override
  void initState() {
    super.initState();

    hasCopied = false;
    mousePosition = (0.0, 0.0);
    focusNode = new FocusNode();
    active = <LogicalKeyboardKey>{};
  }

  @override
  Widget build(BuildContext context) {
    KeyEvent? lastKeyEvent = this.lastKeyEvent;

    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double normalTextSize = constraints.maxHeight * 0.045;
          double highlightTextSize = constraints.maxHeight * 0.20;
          double spacingTextSize = constraints.maxHeight * 0.035;

          return KeyboardListener(
            autofocus: true,
            focusNode: focusNode,
            onKeyEvent: (KeyEvent event) {
              if (event case KeyUpEvent()) {
                setState(() {
                  active.remove(event.logicalKey);
                });
              } else if (event case KeyDownEvent()) {
                setState(() {
                  active.add(event.logicalKey);
                  this.lastKeyEvent = event;
                });
              }
            },
            child: Scaffold(
              body: MouseRegion(
                onHover: (PointerHoverEvent event) {
                  setState(() {
                    mousePosition = (event.position.dx, event.position.dy);
                  });
                },
                child: Stack(
                  children: <Widget>[
                    SingleChildScrollView(
                      child: Container(
                        margin: EdgeInsets.all(constraints.maxWidth * 0.05),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              if (lastKeyEvent != null) ...<Widget>[
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Column(
                                    children: <Widget>[
                                      RichText(
                                        text: TextSpan(
                                          children: <InlineSpan>[
                                            TextSpan(
                                              text: "Flutter Key Code",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: normalTextSize,
                                              ),
                                            ),
                                            TextSpan(
                                              text: " ",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: normalTextSize,
                                              ),
                                            ),
                                            TextSpan(
                                              text: "(logicalKey.keyId)",
                                              style: TextStyle(
                                                fontFamily: "Consolas",
                                                color: Colors.grey,
                                                fontSize: normalTextSize,
                                              ),
                                            ),
                                            TextSpan(
                                              text: " ",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: normalTextSize,
                                              ),
                                            ),
                                            TextSpan(
                                              text: lastKeyEvent.logicalKey.keyId.toString(),
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: normalTextSize,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () {
                                            unawaited(
                                              Clipboard.setData(ClipboardData(text: "${lastKeyEvent.logicalKey.keyId}"))
                                                  .then((_) => setState(() => hasCopied = true)),
                                            );
                                          },
                                          child: Text(
                                            "${lastKeyEvent.logicalKey.keyId}",
                                            style: TextStyle(fontSize: highlightTextSize),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        lastKeyEvent.logicalKey.keyLabel,
                                        style: TextStyle(fontSize: normalTextSize),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: spacingTextSize),
                                Center(
                                  child: Text(
                                    "Keycode Information",
                                    style: TextStyle(fontSize: constraints.maxHeight * 0.025),
                                  ),
                                ),
                                SizedBox(height: spacingTextSize),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 16.0,
                                  runSpacing: 16.0,
                                  runAlignment: WrapAlignment.center,
                                  children: <Widget>[
                                    Tile(
                                      title: "logicalKey.keyId",
                                      description:
                                          "This is an opaque code. It should not be unpacked to derive information from it, as the representation of the code could change at any time.",
                                      child: Text(
                                        "${lastKeyEvent.logicalKey.keyId}",
                                        style: TextStyle(
                                          fontSize: constraints.maxHeight * 0.025,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Tile(
                                      title: "logicalKey.debugName",
                                      description:
                                          "The debug string to print for this keyboard key, which will be null in release mode.",
                                      child: Text(
                                        "${lastKeyEvent.logicalKey.debugName}",
                                        style: TextStyle(
                                          fontSize: constraints.maxHeight * 0.025,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Tile(
                                      title: "logicalKey.isAutogenerated",
                                      description:
                                          "Auto-generated key IDs are generated in response to platform key codes which Flutter doesn't recognize, and their IDs shouldn't be used in a persistent way.",
                                      child: Text(
                                        "${lastKeyEvent.logicalKey.isAutogenerated}",
                                        style: TextStyle(
                                          fontSize: constraints.maxHeight * 0.025,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Tile(
                                      title: "logicalKey.keyLabel",
                                      description:
                                          "This value is useful for providing readable strings for keys or keyboard shortcuts. Do not use this value to compare equality of keys; compare [keyId] instead.",
                                      child: Text(
                                        lastKeyEvent.logicalKey.keyLabel,
                                        style: TextStyle(
                                          fontSize: constraints.maxHeight * 0.025,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Tile(
                                      title: "physicalKey.usbHidUsage",
                                      description:
                                          "The unique USB HID usage ID of this physical key on the keyboard. May not be the actual HID usage code from the hardware.",
                                      child: Text(
                                        "${lastKeyEvent.physicalKey.usbHidUsage}",
                                        style: TextStyle(
                                          fontSize: constraints.maxHeight * 0.025,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Tile(
                                      title: "Modifiers",
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                ModifierSquare(
                                                  isActivated: active.contains(LogicalKeyboardKey.shift) ||
                                                      active.contains(LogicalKeyboardKey.shiftLeft) ||
                                                      active.contains(LogicalKeyboardKey.shiftRight),
                                                  icon: "⇧",
                                                ),
                                                ModifierSquare(
                                                  isActivated: active.contains(LogicalKeyboardKey.control) ||
                                                      active.contains(LogicalKeyboardKey.controlLeft) ||
                                                      active.contains(LogicalKeyboardKey.controlRight),
                                                  icon: "^",
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                ModifierSquare(
                                                  isActivated: active.contains(LogicalKeyboardKey.meta) ||
                                                      active.contains(LogicalKeyboardKey.metaLeft) ||
                                                      active.contains(LogicalKeyboardKey.metaRight),
                                                  icon: "⌘",
                                                ),
                                                ModifierSquare(
                                                  isActivated: active.contains(LogicalKeyboardKey.alt) ||
                                                      active.contains(LogicalKeyboardKey.altLeft) ||
                                                      active.contains(LogicalKeyboardKey.altRight),
                                                  icon: "⌥",
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...<Widget>[
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        "Flutter Key Code",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: normalTextSize,
                                        ),
                                      ),
                                      SizedBox(height: spacingTextSize),
                                      Container(
                                        width: constraints.maxWidth * 0.45,
                                        height: constraints.maxHeight * 0.45,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey[400]!),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: const Center(
                                          child: Text("Press a key on the keyboard!"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (hasCopied)
                      Positioned(
                        left: mousePosition.$1 + 16,
                        top: mousePosition.$2 + 8,
                        child: ClipboardMessage(
                          animationCallback: () => setState(() => hasCopied = false),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class Tile extends StatefulWidget {
  const Tile({
    required this.title,
    required this.child,
    this.description,
    super.key,
  });

  final String title;
  final Widget child;
  final String? description;

  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> with SingleTickerProviderStateMixin {
  late Animation<double> _scale;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = new AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.ease) //
        .drive(new Tween<double>(begin: 1, end: 1.0675));
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => _controller.forward(),
        onExit: (_) => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) => Transform.scale(scale: _scale.value, child: child),
          child: Container(
            width: 225,
            height: 256,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
              color: Colors.black,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  color: Colors.blue,
                  child: Center(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ColoredBox(
                    color: Colors.white,
                    child: Center(child: widget.child),
                  ),
                ),
                if (widget.description != null)
                  Container(
                    constraints: BoxConstraints.loose(const Size(double.infinity, 256)),
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.grey[200],
                    child: Text(widget.description!, overflow: TextOverflow.fade),
                  ),
              ],
            ),
          ),
        ),
      );
}

class ModifierSquare extends StatelessWidget {
  const ModifierSquare({
    required this.isActivated,
    required this.icon,
    super.key,
  });

  final bool isActivated;
  final String icon;

  @override
  Widget build(BuildContext context) => Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          border: Border.all(color: isActivated ? Colors.black : Colors.grey[200]!, width: 4),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Center(
          child: Text(
            icon,
            style: TextStyle(
              color: isActivated ? Colors.black : Colors.grey[200],
              fontSize: 36,
            ),
          ),
        ),
      );
}

class ClipboardMessage extends StatefulWidget {
  const ClipboardMessage({required this.animationCallback, super.key});

  final void Function() animationCallback;

  @override
  State<ClipboardMessage> createState() => _ClipboardMessageState();
}

class _ClipboardMessageState extends State<ClipboardMessage> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..addStatusListener((AnimationStatus status) {
        if (status case AnimationStatus.completed) {
          widget.animationCallback();
        }
      });
    _opacity = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut) //
        .drive(
      TweenSequence<double>(<TweenSequenceItem<double>>[
        TweenSequenceItem<double>(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 0.10),
        TweenSequenceItem<double>(tween: ConstantTween<double>(1.0), weight: 0.80),
        TweenSequenceItem<double>(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 0.10),
      ]),
    );
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, Widget? child) => Opacity(opacity: _opacity.value, child: child),
        child: const Text("Copied to clipboard!"),
      );
}
