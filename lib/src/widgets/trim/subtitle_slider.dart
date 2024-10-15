
import 'package:flutter/material.dart';
import 'package:subtitle/subtitle.dart';
import 'package:video_editor/src/controller.dart';
import 'package:video_editor/src/utils/helpers.dart';
import 'package:video_editor/src/utils/thumbnails.dart';

class SubtitleSlider extends StatefulWidget {
  const SubtitleSlider({
    super.key,
    required this.controller,
    this.height = 60,
  });

  /// The [height] param specifies the height of the generated thumbnails
  final double height;

  final VideoEditorController controller;

  @override
  State<SubtitleSlider> createState() => _SubtitleSliderState();
}

class _SubtitleSliderState extends State<SubtitleSlider> {
  final ValueNotifier<Rect> _rect = ValueNotifier<Rect>(Rect.zero);
  /// The max width of [SubtitleSlider]
  double _sliderWidth = 1.0;

  Size _layout = Size.zero;
  late Size _maxLayout = _calculateMaxLayout();


  late Stream<List<Subtitle>> _stream = (() => _generateSubtitles())();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_scaleRect);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_scaleRect);
    _rect.dispose();
    super.dispose();
  }

  void _scaleRect() {
    _rect.value = calculateCroppedRect(widget.controller, _layout);
    _maxLayout = _calculateMaxLayout();

  }

  Stream<List<Subtitle>> _generateSubtitles() => generateSubtitles(
        widget.controller
      );

  /// Returns the max size the layout should take with the rect value
  Size _calculateMaxLayout() {
    final ratio = _rect.value == Rect.zero
        ? widget.controller.video.value.aspectRatio
        : _rect.value.size.aspectRatio;

    // check if the ratio is almost 1
    if (isNumberAlmost(ratio, 1)) return Size.square(widget.height);

    final size = Size(widget.height * ratio, widget.height);

    if (widget.controller.isRotated) {
      return Size(widget.height / ratio, widget.height);
    }
    return size;
  }
  double computeWidth(Subtitle subtitle){
    final start = subtitle.start.inMilliseconds;
    final end = subtitle.end.inMilliseconds;
    final duration = widget.controller.videoDuration.inMilliseconds;
    final width = (_sliderWidth * (end - start)) / duration;
    return width;
  }
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, box) {
      _sliderWidth = box.maxWidth;
     print("subtile sliderWidth: $_sliderWidth");
      return StreamBuilder<List<Subtitle>>(
        stream: _stream,
        builder: (_, snapshot) {
          final data = snapshot.data;
          if(data==null) return const SizedBox();
          return snapshot.hasData
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.length,
                  itemBuilder: (_, i){
                    double width = computeWidth(data[i]);
                    print("subtile width: $width");
                      return Stack(
                        children: [
                          SizedBox(
                            width: width,
                            height: 100,
                            child:Padding(
                              padding: const EdgeInsets.all(8.0),
                              child:
                              Text(data[i].data,
                                style: TextStyle(
                                    background: Paint()..color = Colors.green,
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                ),),
                            ),
                          )

                        ],
                      );
                    },
                )
              : const SizedBox();
        },
      );
    });
  }
}
