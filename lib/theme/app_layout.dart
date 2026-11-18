/// Layout numbers shared by several widgets, so they always agree.
class AppLayout {
  AppLayout._(); // stops anyone from creating an AppLayout object

  /// The widest the screen content may be. On a wide browser window the
  /// content stays centered at this width, like a phone screen.
  static const double maxContentWidth = 430;

  /// Corner radius of the white input fields (amount, date, note).
  static const double fieldRadius = 16;
}
