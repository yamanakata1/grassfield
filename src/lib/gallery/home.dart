// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:developer';
import 'dart:js' as js;

import 'package:flutter_web/material.dart';

import 'backdrop.dart';
import 'demos.dart';

const Color _kFlutterBlue = Color(0xFF003D75);
const double _kDemoItemHeight = 64.0;
const Duration _kFrontLayerSwitchDuration = Duration(milliseconds: 300);

class _FlutterLogo extends StatelessWidget {
  const _FlutterLogo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 34.0,
        height: 34.0,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'logos/flutter_white/logo.png',
              //package: _kGalleryAssetsPackage,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    Key key,
    this.category,
    this.onTap,
  }) : super(key: key);

  final GalleryDemoCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    // This repaint boundary prevents the entire _CategoriesPage from being
    // repainted when the button's ink splash animates.
    return RepaintBoundary(
      child: RawMaterialButton(
        padding: EdgeInsets.zero,
        splashColor: theme.primaryColor.withOpacity(0.12),
        highlightColor: Colors.transparent,
        onPressed: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Icon(
                category.icon,
                size: 60.0,
                color: isDark ? Colors.white : _kFlutterBlue,
              ),
            ),
            const SizedBox(height: 10.0),
            Container(
              height: 48.0,
              alignment: Alignment.center,
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                style: theme.textTheme.subhead.copyWith(
                  fontFamily: 'GoogleSans',
                  color: isDark ? Colors.white : _kFlutterBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesPage extends StatelessWidget {
  const _CategoriesPage({
    Key key,
    this.categories,
    this.onCategoryTap,
  }) : super(key: key);

  final Iterable<GalleryDemoCategory> categories;
  final ValueChanged<GalleryDemoCategory> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    const double aspectRatio = 160.0 / 180.0;
    final List<GalleryDemoCategory> categoriesList = categories.toList();
    final int columnCount =
        (MediaQuery.of(context).orientation == Orientation.portrait) ? 2 : 3;

    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      label: 'categories',
      explicitChildNodes: true,
      child: SingleChildScrollView(
        key: const PageStorageKey<String>('categories'),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double columnWidth =
                constraints.biggest.width / columnCount.toDouble();
            final double rowHeight = math.min(225.0, columnWidth * aspectRatio);
            final int rowCount =
                (categories.length + columnCount - 1) ~/ columnCount;

            Size size = MediaQuery.of(context).size;

            // This repaint boundary prevents the inner contents of the front layer
            // from repainting when the backdrop toggle triggers a repaint on the
            // LayoutBuilder.
            return RepaintBoundary(
              child: Stack(
                children: <Widget>[
                  Image.asset("bg/grassfield.jpg",
                      width: size.width, height: size.height, fit: BoxFit.fill),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: List<Widget>.generate(rowCount, (int rowIndex) {
                      final int columnCountForRow = rowIndex == rowCount - 1
                          ? categories.length -
                              columnCount * math.max(0, rowCount - 1)
                          : columnCount;
                      return Row(
                        children: List<Widget>.generate(columnCountForRow,
                            (int columnIndex) {
                          final int index =
                              rowIndex * columnCount + columnIndex;
                          final GalleryDemoCategory category =
                              categoriesList[index];

                          return SizedBox(
                            width: columnWidth,
                            height: rowHeight,
                            child: _CategoryItem(
                              category: category,
                              onTap: () {
                                onCategoryTap(category);
                              },
                            ),
                          );
                        }),
                      );
                    }),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DemoItem extends StatelessWidget {
  const _DemoItem({Key key, this.demo}) : super(key: key);

  final GalleryDemo demo;

  void _launchDemo(BuildContext context) {
    if (demo.routeName != null) {
      Timeline.instantSync('Start Transition', arguments: <String, String>{
        'from': '/',
        'to': demo.routeName,
      });
      Navigator.pushNamed(context, demo.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final double textScaleFactor = MediaQuery.textScaleFactorOf(context);

    final List<Widget> titleChildren = <Widget>[
      Text(
        demo.title,
        style: theme.textTheme.subhead.copyWith(
          color: isDark ? Colors.white : const Color(0xFF202124),
        ),
      ),
    ];
    if (demo.subtitle != null) {
      titleChildren.add(
        Text(
          demo.subtitle,
          style: theme.textTheme.body1
              .copyWith(color: isDark ? Colors.white : const Color(0xFF60646B)),
        ),
      );
    }

    return RawMaterialButton(
      padding: EdgeInsets.zero,
      splashColor: theme.primaryColor.withOpacity(0.12),
      highlightColor: Colors.transparent,
      onPressed: () {
        _launchDemo(context);
      },
      child: Container(
        constraints:
            BoxConstraints(minHeight: _kDemoItemHeight * textScaleFactor),
        child: Row(
          children: <Widget>[
            Container(
              width: 56.0,
              height: 56.0,
              alignment: Alignment.center,
              child: Icon(
                demo.icon,
                size: 24.0,
                color: isDark ? Colors.white : _kFlutterBlue,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: titleChildren,
              ),
            ),
            const SizedBox(width: 44.0),
          ],
        ),
      ),
    );
  }
}

class _DemosPage extends StatelessWidget {
  const _DemosPage(this.category);

  final GalleryDemoCategory category;

  @override
  Widget build(BuildContext context) {
    // When overriding ListView.padding, it is necessary to manually handle
    // safe areas.
    final double windowBottomPadding = MediaQuery.of(context).padding.bottom;
    return KeyedSubtree(
      key: const ValueKey<String>(
          'GalleryDemoList'), // So the tests can find this ListView
      child: Semantics(
        scopesRoute: true,
        namesRoute: true,
        label: category.name,
        explicitChildNodes: true,
        child: ListView(
          key: PageStorageKey<String>(category.name),
          padding: EdgeInsets.only(top: 8.0, bottom: windowBottomPadding),
          children:
              kGalleryCategoryToDemos[category].map<Widget>((GalleryDemo demo) {
            return _DemoItem(demo: demo);
          }).toList(),
        ),
      ),
    );
  }
}

class GalleryHome extends StatefulWidget {
  const GalleryHome({
    Key key,
    this.testMode = false,
    this.optionsPage,
  }) : super(key: key);

  final Widget optionsPage;
  final bool testMode;

  // In checked mode our MaterialApp will show the default "debug" banner.
  // Otherwise show the "preview" banner.
  static bool showPreviewBanner = true;

  @override
  _GalleryHomeState createState() => _GalleryHomeState();
}

class _GalleryHomeState extends State<GalleryHome>
    with SingleTickerProviderStateMixin {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  AnimationController _controller;
  GalleryDemoCategory _category;
  TextEditingController _inputController;

  static Widget _topHomeLayout(
      Widget currentChild, List<Widget> previousChildren) {
    List<Widget> children = previousChildren;
    if (currentChild != null) children = children.toList()..add(currentChild);
    return Stack(
      children: children,
      alignment: Alignment.topCenter,
    );
  }

  static const AnimatedSwitcherLayoutBuilder _centerHomeLayout =
      AnimatedSwitcher.defaultLayoutBuilder;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      debugLabel: 'preview banner',
      vsync: this,
    )..forward();
    _inputController = TextEditingController();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final MediaQueryData media = MediaQuery.of(context);
    final bool centerHome =
        media.orientation == Orientation.portrait && media.size.height < 800.0;

    const Curve switchOutCurve =
        Interval(0.4, 1.0, curve: Curves.fastOutSlowIn);
    const Curve switchInCurve = Interval(0.4, 1.0, curve: Curves.fastOutSlowIn);

    Widget home = Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? _kFlutterBlue : theme.primaryColor,
      body: SafeArea(
        bottom: false,
        child: WillPopScope(
          onWillPop: () {
            // Pop the category page if Android back button is pressed.
            if (_category != null) {
              setState(() => _category = null);
              return Future<bool>.value(false);
            }
            return Future<bool>.value(true);
          },
          child: Backdrop(
            backTitle: const Text('Options'),
            backLayer: widget.optionsPage,
            frontAction: AnimatedSwitcher(
              duration: _kFrontLayerSwitchDuration,
              switchOutCurve: switchOutCurve,
              switchInCurve: switchInCurve,
              child: _category == null
                  ? const _FlutterLogo()
                  : IconButton(
                      icon: const BackButtonIcon(),
                      tooltip: 'Back',
                      onPressed: () => setState(() => _category = null),
                    ),
            ),
            frontTitle: AnimatedSwitcher(
              duration: _kFrontLayerSwitchDuration,
              child: _category == null
                  ? const Text('Grass Field')
                  : Text(_category.name),
            ),
            frontHeading: widget.testMode ? null : Container(height: 24.0),
            frontLayer: AnimatedSwitcher(
                duration: _kFrontLayerSwitchDuration,
                switchOutCurve: switchOutCurve,
                switchInCurve: switchInCurve,
                layoutBuilder: centerHome ? _centerHomeLayout : _topHomeLayout,
                child: _category != null
                    ? _DemosPage(_category)
                    : Stack(
                        children: <Widget>[
                          _CategoriesPage(
                            categories: kAllGalleryDemoCategories,
                            onCategoryTap: (GalleryDemoCategory category) {
                              setState(() => _category = category);
                            },
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                    padding: EdgeInsets.all(20.0),
                                    child: TextField(
                                      controller: _inputController,
                                      enabled: true,
                                      maxLength: 50,
                                      decoration: const InputDecoration(
                                        labelText: 'Google Search',
                                      ),
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (String value) {
                                        js.context.callMethod(
                                            "open", ['https://www.google.com/search?q=flutter&oq=flutter']);
                                      },
                                    ),
                                ),
                                FlatButton(
                                  color: Colors.blue,
                                  textColor: Colors.white,
                                  disabledColor: Colors.grey,
                                  disabledTextColor: Colors.black,
                                  padding: EdgeInsets.all(8.0),
                                  splashColor: Colors.blueAccent,
                                  onPressed: () {
                                    js.context["console"].callMethod(
                                        "log", ['Button Pressed', '\n', 'Jump to Google']);
                                    js.context.callMethod(
                                        "open", ['https://www.google.com/search?q=flutter&oq=flutter']);
                                  },
                                  child: Text(
                                    "Google Search",
                                    style: TextStyle(fontSize: 20.0),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      )),
          ),
        ),
      ),
    );

    assert(() {
      GalleryHome.showPreviewBanner = false;
      return true;
    }());

    if (GalleryHome.showPreviewBanner) {
      home = Stack(fit: StackFit.expand, children: <Widget>[
        home,
        FadeTransition(
            opacity:
                CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            child: const Banner(
              message: 'PREVIEW',
              location: BannerLocation.topEnd,
            )),
      ]);
    }
    home = AnnotatedRegion<SystemUiOverlayStyle>(
        child: home, value: SystemUiOverlayStyle.light);

    return home;
  }
}
