import 'package:flutter/material.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/dto/news_item.dart';

final news = {
  NewsItem(
    icon: Icons.pin_drop,
    iconColor: AppColor.red,
    localizedHeading: {'de': 'Lorem ipsum', 'en': 'Lorem ipsum'},
    localizedText: {
      'de': 'Lorem ipsum dolor sit amet, _consetetur_ sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut.',
      'en': 'Lorem ipsum dolor sit amet, _consetetur_ sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut.',
    },
  ),
  NewsItem(
    icon: Icons.exposure_rounded,
    iconColor: AppColor.green,
    localizedHeading: {'de': 'Lorem ipsum', 'en': 'Lorem ipsum'},
    localizedText: {
      'de': 'labore et **dolore** magna aliquyam erat, sed diam **voluptua**. At vero eos et accusam et justo duo dolores et ea rebum. ',
      'en': 'labore et **dolore** magna aliquyam erat, sed diam **voluptua**. At vero eos et accusam et justo duo dolores et ea rebum. ',
    },
  ),
  NewsItem(
    icon: Icons.dark_mode_rounded,
    iconColor: AppColor.blue,
    localizedHeading: {'de': 'Lorem ipsum', 'en': 'Lorem ipsum'},
    localizedText: {
      'de': 'Stet clita kasd _gubergren_, no sea takimata sanctus est **Lorem* ipsum dolor sit amet.',
      'en': 'Stet clita kasd _gubergren_, no sea takimata sanctus est **Lorem* ipsum dolor sit amet.',
    },
  ),
};
