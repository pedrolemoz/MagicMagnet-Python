import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:unicons/unicons.dart';

import '../../../../core/utils/app_config/app_config.dart';
import '../../../../core/utils/user_interface/admob.dart';
import '../../../../core/utils/user_interface/no_splash.dart';
import '../../../home/presentation/widgets/circular_button.dart';
import '../../../home/presentation/widgets/loading_indicator.dart';
import '../../../home/presentation/widgets/result_card.dart';
import '../../../home/presentation/widgets/rounded_button.dart';
import '../controllers/search_controller.dart';
import '../controllers/search_states.dart';

class ResultPage extends StatefulWidget {
  final String content;

  const ResultPage({@required this.content});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final searchController = Modular.get<SearchController>();

  @override
  void initState() {
    super.initState();
    searchController.performSearch(widget.content);
  }

  BannerAd resultsBanner;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (AppConfig.of(context).isFree) {
      resultsBanner = BannerAd(
        adUnitId: AdmobCodes.resultsBannerID,
        size: AdSize.smartBanner,
        targetingInfo: MobileAdTargetingInfo(),
        listener: (MobileAdEvent event) {
          debugPrint("BannerAd event is $event");
        },
      );
    }
  }

  void _showInteresticialAd() {
    InterstitialAd resultsInteresticial = InterstitialAd(
      adUnitId: AdmobCodes.resultsInteresticialID,
      targetingInfo: MobileAdTargetingInfo(),
      listener: (MobileAdEvent event) {
        debugPrint("InterstitialAd event is $event");
      },
    );

    resultsInteresticial
      ..load()
      ..show();
  }

  Future<bool> _willPop() async {
    if (AppConfig.of(context).isFree) {
      _showInteresticialAd();
    }

    if (AppConfig.of(context).isFree) {
      resultsBanner..dispose();
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPop,
      child: Observer(
        builder: (context) {
          if (searchController.state is SuccessState) {
            if (AppConfig.of(context).isFree) {
              resultsBanner
                ..load()
                ..show(anchorType: AnchorType.top);
            }

            return Scaffold(
              floatingActionButtonAnimator: _NoScalingAnimation(),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: searchController.state
                      is FinishedSearchState
                  ? null
                  : Container(
                      height: 55,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: RoundedButton(
                        color: Colors.redAccent[700],
                        padding: EdgeInsets.all(16),
                        onTap: () =>
                            searchController.cancelSearch(widget.content),
                        child: Center(
                          child: Text(
                            'Cancel search',
                            style:
                                Theme.of(context).textTheme.subtitle2.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                          ),
                        ),
                      ),
                    ),
              appBar: AppBar(
                centerTitle: true,
                elevation: 0,
                brightness: Theme.of(context).brightness,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                leading: CircularButton(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  onTap: () async {
                    await Modular.navigator.maybePop();
                    await _willPop();
                  },
                  child: Icon(
                    UniconsLine.arrow_left,
                    size: 30,
                    color: Theme.of(context).textTheme.headline6.color,
                  ),
                ),
                title: Text(
                  'Results for ${widget.content}',
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              body: NoSplash(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            searchController.state.message,
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${searchController.magnetLinks.length} results have been found',
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                          SizedBox(height: 16),
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            addRepaintBoundaries: true,
                            cacheExtent: MediaQuery.of(context).size.height * 5,
                            itemCount: searchController.magnetLinks.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: ResultCard(
                                  magnetLink: searchController.magnetLinks
                                      .elementAt(index),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (searchController.state is ErrorState) {
            Future.delayed(Duration(seconds: 5), () async {
              await Modular.navigator.maybePop();
              await _willPop();
            });

            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                elevation: 0,
                brightness: Theme.of(context).brightness,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                leading: CircularButton(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  onTap: () async {
                    await Modular.navigator.maybePop();
                    await _willPop();
                  },
                  child: Icon(
                    UniconsLine.arrow_left,
                    size: 30,
                    color: Theme.of(context).textTheme.headline6.color,
                  ),
                ),
                title: Text(
                  'Results for ${widget.content}',
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              body: NoSplash(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      searchController.state.message,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            );
          }

          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    searchController.state.message,
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 32),
                  LoadingIndicator(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NoScalingAnimation extends FloatingActionButtonAnimator {
  double _x;
  double _y;
  @override
  Offset getOffset({Offset begin, Offset end, double progress}) {
    _x = begin.dx + (end.dx - begin.dx) * progress;
    _y = begin.dy + (end.dy - begin.dy) * progress;
    return Offset(_x, _y);
  }

  @override
  Animation<double> getRotationAnimation({Animation<double> parent}) {
    return Tween<double>(begin: 1.0, end: 1.0).animate(parent);
  }

  @override
  Animation<double> getScaleAnimation({Animation<double> parent}) {
    return Tween<double>(begin: 1.0, end: 1.0).animate(parent);
  }
}
