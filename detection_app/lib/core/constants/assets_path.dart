class AssetsPath {
  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';

  // Images
  static const String logo = '$_images/logo.png'; // เตรียมไฟล์นี้ไว้ในโฟลเดอร์
  static const String placeholder = '$_images/placeholder.png';

  // Icons (ถ้าใช้ SVG ให้ใช้ flutter_svg แต่ที่นี่ใช้ IconData เป็นหลัก หรือ PNG icons)
  static const String microscope = '$_icons/microscope.png';
  static const String flask = '$_icons/flask.png';
}