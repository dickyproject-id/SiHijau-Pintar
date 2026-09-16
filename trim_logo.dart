import 'dart:io';
import 'package:image/image.dart';

void main() {
  final file = File('assets/logo.png');
  if (!file.existsSync()) {
    print('Logo file not found');
    return;
  }
  
  final originalImage = decodeImage(file.readAsBytesSync());
  if (originalImage == null) return;
  
  int minX = originalImage.width;
  int minY = originalImage.height;
  int maxX = 0;
  int maxY = 0;
  
  for (int y = 0; y < originalImage.height; y++) {
    for (int x = 0; x < originalImage.width; x++) {
      final pixel = originalImage.getPixel(x, y);
      if (pixel.a > 10) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }
  
  if (minX <= maxX && minY <= maxY) {
    int w = maxX - minX + 1;
    int h = maxY - minY + 1;
    final cropped = copyCrop(originalImage, x: minX, y: minY, width: w, height: h);
    
    int maxDim = (w > h ? w : h);
    int paddedSize = (maxDim * 1.45).round(); // Add 45% padding around the tight crop
    
    final finalImage = Image(width: paddedSize, height: paddedSize);
    // Fill with solid white
    for (var p in finalImage) {
      p.setRgba(255, 255, 255, 255);
    }
    
    int dstX = (paddedSize - w) ~/ 2;
    int dstY = (paddedSize - h) ~/ 2;
    
    compositeImage(finalImage, cropped, dstX: dstX, dstY: dstY);
    
    File('assets/logo_icon.png').writeAsBytesSync(encodePng(finalImage));
    print('Success: assets/logo_icon.png created.');
  }
}
