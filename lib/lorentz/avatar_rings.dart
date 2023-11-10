import 'package:art/lorentz/animated_rings.dart';
import 'package:flutter/material.dart';

/// Paint the rings by appending a series of different waves into one per ring,
/// and then drawing each ring following a circle shape.
class AvatarRings extends StatelessWidget {
  /// The constructor for the [AvatarRings] class
  ///
  /// Accepts a [child] widget, the amount of [rings], the [radius] of
  /// the entire rings painter, a [spaceBetweenRings] space between each ring,
  /// a [fromPeriod] for the start period value, a [toPeriod] for the end
  /// period value, a [ringsColor] for the color of the rings, a
  /// [ringsColorOpacity] for the opacity for the rings, and the [shadowColor]
  /// and [shadowColorOpacity] for color and opacity of the shadow.
  ///
  /// - The [radius] must be bigger than the [rings] multiplied with the
  /// [spaceBetweenRings].
  ///
  /// - The [rings] must less/equal to 16 to keep performance
  ///
  /// - The [fromPeriod] and [toPeriod] values must be between 10 and 400
  ///
  /// - The [toPeriod] must be bigger or equal to [fromPeriod]
  ///
  const AvatarRings({
    required this.child,
    this.showRings = true,
    this.rings = 4,
    this.radius = 80,
    this.spaceBetweenRings = 1,
    this.fromPeriod = 150,
    this.toPeriod = 200,
    this.ringsColor = Colors.lightBlue,
    this.ringsColorOpacity = .4,
    this.shadowColor = Colors.lightBlue,
    this.shadowColorOpacity = .4,
    this.showStatusPoint = false,
    this.statusPointColor = Colors.green,
    this.padding,
    this.badgeText,
    this.badgeColor,
    this.border,
    super.key,
  })  : assert(
          radius > rings * spaceBetweenRings,
          'The radius must the bigger than the rings multiplied by the space between rings',
        ),
        assert(
          rings <= 10,
          'The rings must less/equal to 16 to keep performance',
        ),
        assert(
          fromPeriod > 10 ||
              toPeriod > 10 ||
              fromPeriod <= 400 ||
              toPeriod <= 400,
          'The fromPeriod and toPeriod values must be between 10 and 400',
        ),
        assert(
          fromPeriod <= toPeriod,
          'The toPeriod must be bigger or equal to fromPeriod',
        );

  /// The child widget for the rings avatar.
  final Widget child;

  /// The badge text widget to show as a notification.
  final Widget? badgeText;

  /// The badge color.
  final Color? badgeColor;

  /// Hide or show the rings. Defaults to true.
  final bool showRings;

  /// The number of rings. Defaults to 1.
  final int rings;

  /// Show the status point at the bottom right corner. Defaults to false.
  final bool showStatusPoint;

  /// The status point color. Defaults to [Colors.green].
  final Color? statusPointColor;

  /// The radius of the entire rings painter. Defaults to 80.
  final double radius;

  /// The border for the child.
  final Border? border;

  /// The padding for the child widget. Defaults to a calculation based on the amount of rings.
  final double? padding;

  /// The start period value. Used to generate a random value starting from [fromPeriod]. Defaults to 150.
  final double fromPeriod;

  /// The end period value. Used to generate a random value ending in [toPeriod]. Defaults to 200.
  final double toPeriod;

  /// The color of the rings. Defaults to [Colors.lightBlue].
  final Color ringsColor;

  /// The opacity of the rings color. Defaults to 0.4.
  final double ringsColorOpacity;

  /// The color of the shadow. Defaults to [Colors.lightBlue].
  final Color shadowColor;

  /// The opacity of the shadow color. Defaults to 0.4.
  final double shadowColorOpacity;

  /// The space between each ring. Defaults to 1.
  final double spaceBetweenRings;

  @override
  Widget build(BuildContext context) {
    final childPadding = padding ?? radius / 10;
    return SizedBox(
      key: const Key('avatar_rings_sizedbox'),
      height: radius * 2,
      width: radius * 2,
      child: Stack(
        key: const Key('avatar_rings_stack'),
        children: [
          Center(
            key: const Key('avatar_rings_shadow'),
            child: Container(
              margin: EdgeInsets.all(rings.toDouble()),
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withOpacity(shadowColorOpacity),
                    spreadRadius: padding != null
                        ? padding!
                        : (showRings ? rings.toDouble() * 2 : 10),
                    blurRadius: padding != null
                        ? padding! * 2
                        : (showRings ? rings.toDouble() * 2 : 10),
                    offset: const Offset(
                      0,
                      1,
                    ), // changes position of shadow
                  ),
                ],
              ),
            ),
          ),
          if (showRings)
            const Center(
              key: Key('avatar_rings_rings'),
              child: AnimatedRings(),
            ),
          Center(
            key: const Key('avatar_rings_child'),
            child: Padding(
              padding: EdgeInsets.all(showRings ? childPadding : 0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: border,
                ),
                child: Padding(
                  padding: EdgeInsets.all(showRings ? 5 : 0),
                  child: Stack(
                    children: [
                      ClipOval(
                        child: child,
                      ),
                      if (radius / 2.5 > 10 && showStatusPoint)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: DecoratedBox(
                            decoration: ShapeDecoration(
                              color: statusPointColor,
                              shape: const StadiumBorder(),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(radius / 8),
                            ),
                          ),
                        ),
                      if (badgeText != null)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: DecoratedBox(
                            decoration: ShapeDecoration(
                              color: badgeColor ?? Colors.red,
                              shape: const StadiumBorder(),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: radius > 30 ? badgeText : null,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
