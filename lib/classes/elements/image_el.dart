import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:sketchspace/classes/element.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:ui' as ui;

class ImageElement extends SketchElement {
  late ui.Image image;
  final String path;
  Offset position;
  double? width;
  double? height;
  bool isLoaded = false;
  @override
  Rect get boundary {
    return Rect.fromLTWH(
      position.dx,
      position.dy,
      image.width.toDouble(),
      image.height.toDouble(),
    );
  }

  /// Constructor: Use this WITH an image provided
  /// Otherwise use the async factory methods below
  ImageElement({
    required this.image, // Must provide an already loaded image
    required this.path,
    required this.position,
    double? width, // Optional: specify width, defaults to image width
    double? height, // Optional: specify height, defaults to image height
    required String layerId,
    String? id,
  }) : // Directly initialize final fields via initializer list
       isLoaded = true,
       width = width ?? image.width.toDouble(),
       height = height ?? image.height.toDouble(),
       super(id: id, layerId: layerId);

  // Private constructor: Use the async factories below to create instances
  ImageElement._internal({
    required this.path,
    required this.position,
    required this.width,
    required this.height,
    required super.layerId,
    super.id, // Handle ID generation if needed in factories
  });
  // static Future<ImageElement> load({
  //   required String path,
  //   required Offset position,
  //   double? targetWidth, // Optional desired width
  //   double? targetHeight, // Optional desired height
  //   required String layerId,
  //   String? id, // Consider generating ID here if null: id ?? Uuid().v4()
  // }) async {
  //   try {
  //     final ui.Image loadedImage = await loadImage(path);
  //     // Use target dimensions if provided, otherwise use image's natural size
  //     final double finalWidth = targetWidth ?? loadedImage.width.toDouble();
  //     final double finalHeight = targetHeight ?? loadedImage.height.toDouble();

  //     return ImageElement(
  //       image: loadedImage,
  //       path: path,
  //       position: position,
  //       width: finalWidth,
  //       height: finalHeight,
  //       layerId: layerId,
  //       id: id, // Or generate: id ?? Uuid().v4()
  //     );
  //   } catch (e) {
  //     // Rethrow or handle more gracefully (e.g., return a placeholder element)
  //     print('Error loading image element from path: $e');
  //     rethrow;
  //   }
  // }

  // Async factory for creating from JSON
  factory ImageElement.fromJson(Map<String, dynamic> json) {
    final path = json['path'] as String;
    final position = Offset(
      (json['position']['x'] as num).toDouble(),
      (json['position']['y'] as num).toDouble(),
    );
    // Important: Load width/height from JSON *before* loading image
    // These represent the dimensions the image *should* be drawn at.
    final double? jsonWidth = (json['width'] as num?)?.toDouble();
    final double? jsonHeight = (json['height'] as num?)?.toDouble();
    final layerId = json['layerId'] as String;
    final id = json['id'] as String?; // Allow null if ID is optional

    try {
      return ImageElement._internal(
        path: path,
        position: position,
        width: jsonWidth, // Use the determined width
        height: jsonHeight, // Use the determined height
        layerId: layerId,
        id: id,
      );
    } catch (e) {
      // Rethrow or handle more gracefully
      print('Error loading image element from JSON: $e');
      rethrow;
    }
  }

  void load() async {
    ui.instantiateImageCodec(File(path).readAsBytesSync()).then((v) {
      v.getNextFrame().then((frame) {
        print("Found image");
        image = frame.image;
        isLoaded = true;
      });
    });
  }

  @override
  draw(Canvas c) {
    if (isLoaded)
      c.drawImage(image, position, Paint());
    else {
      print("Image not loaded!");
    }
  }

  @override
  bool hitTest(Offset point) {
    return boundary.contains(point);
  }

  @override
  Map<String, dynamic> toJson() {
    print("Savinmg img");
    return <String, dynamic>{
      'type': 'image',
      'id': id,
      'layerId': layerId,
      'path': path,
      'position': {'x': position.dx, 'y': position.dy},
      'width': image.width,
      'height': image.height,
    };
  }
  @override
  endScaling() {
    // No-op for ImageElement
  }
  @override 
  startScaling(HandlePosition handle) {
    // No-op for ImageElement
  }
  @override
  scale(Vector2 delta, Offset pivot) async {
    throw UnimplementedError('ImageElement does not support scaling.');
  }

  @override
  transform(Matrix4 transform) {
    // Transform the Width and Height based on the transformation matrix
    // Assuming the transformation matrix is a 4x4 matrix, we can apply it to the width and height

    // Create a vector to store the original dimensions
    Vector3 dimensions = Vector3(
      width ?? image.width.toDouble(),
      height ?? image.height.toDouble(),
      0,
    );

    // Apply the transformation matrix to the dimensions vector
    dimensions = transform.perspectiveTransform(dimensions);

    // Update the width and he    // Update width and height with the transformed values
    // Take absolute values to handle negative scaling
  }

  @override
  translate(Offset offset) {
    position += offset;
  }
}

// loadImage remains largely the same, but ensure it handles errors
Future<ui.Image> loadImage(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    throw Exception('Image file not found at path: $path');
  }

  final bytes = await file.readAsBytes();
  // Add check for empty bytes as instantiateImageCodec can fail
  if (bytes.isEmpty) {
    throw Exception('Image file is empty: $path');
  }

  try {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  } catch (e) {
    // Catch specific exceptions if needed (FileSystemException, etc.)
    print('Failed to load image from $path: $e');
    // Rethrow to be caught by the calling factory constructor
    rethrow;
  }
}
