import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:user_market/service/entity/banner_service.dart';
import 'package:user_market/util/const.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  int _current = 0;
  final CarouselController _controller = CarouselController();

  Future<List<Widget>?> _loadBanners() async {
    final banners = await BannerService.instance.get();

    List<Widget> imgs = [];
    banners?.forEach((element) {
      if (element.actuallyLink != null && element.actuallyLink!.isNotEmpty) {
        imgs.add(ClipRRect(
          borderRadius: BorderRadius.circular(defRadius),
          child: FadeInImage(
            fit: BoxFit.cover,
            placeholder: const AssetImage('assets/img/loading.gif'),
            image: FileImage(File(element.actuallyLink!)),
          ),
        ));
      }
    });

    return imgs.isNotEmpty ? imgs : null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => FutureBuilder(
        future: _loadBanners(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          return Stack(children: [
            SizedBox(
              height: constraints.maxHeight,
              width: constraints.maxWidth,
              child: CarouselSlider(
                items: snapshot.data!,
                carouselController: _controller,
                options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 1.0,
                    aspectRatio: 2.0,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                      });
                    }),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 0,
              left: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: snapshot.data!.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _controller.animateToPage(entry.key),
                    child: Container(
                      width: 12.0,
                      height: 12.0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black)
                              .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ]);
        },
      ),
    );
  }
}
