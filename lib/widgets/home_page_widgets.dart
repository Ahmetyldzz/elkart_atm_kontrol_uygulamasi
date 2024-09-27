// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:atm_kontrol_sistemi/constants/colors.dart';
import 'package:atm_kontrol_sistemi/constants/project_sizes.dart';

class CustomAllAtmItemSmall extends StatelessWidget {
  const CustomAllAtmItemSmall({
    super.key,
    required this.contentTitle,
    required this.addOrDeleteFav,
    required this.goToLink,
    required this.infoPressed,
    this.contentSubTitleIP1,
    this.contentSubTitleIP2,
    this.iconData,
    this.checkIconWireless,
    this.checkConnectionIconColorWireless,
    this.checkActiveOrPassive,
    this.path,
    this.textColor,
  });

  final String? contentTitle;
  final String? contentSubTitleIP1;
  final String? contentSubTitleIP2;
  final Function() addOrDeleteFav;
  final Function() goToLink;
  final Function() infoPressed;
  final IconData? iconData;
  final IconData? checkIconWireless;
  final Color? checkConnectionIconColorWireless;
  final bool? checkActiveOrPassive;
  final String? path;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.14,
      child: Stack(
        children: [
          CustomSmallCard(
            textColor: textColor,
            checkActiveOrPassive: checkActiveOrPassive,
            contentTitle: contentTitle,
            addOrDeleteFavButtonPressed: addOrDeleteFav,
            favButtonIcon: iconData,
            contentSubTitle1: contentSubTitleIP1,
            contentSubTitle2: contentSubTitleIP2,
            checkConnectionIconColorWireless: checkConnectionIconColorWireless,
            checkIconWireless: checkIconWireless,
            path: path,
          ),
          Padding(
            padding: EdgeInsets.only(
              left: MediaQuery.sizeOf(context).width * 0.02,
              right: MediaQuery.sizeOf(context).width * 0.07,
              top: MediaQuery.sizeOf(context).height * 0.02,
              bottom: MediaQuery.sizeOf(context).height * 0.02,
            ),
            child: InkWell(
              onTap: goToLink,
              child: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomSmallCard extends StatelessWidget {
  const CustomSmallCard({
    super.key,
    required this.contentTitle,
    required this.addOrDeleteFavButtonPressed,
    required this.favButtonIcon,
    required this.contentSubTitle1,
    required this.contentSubTitle2,
    this.checkIconWireless,
    this.checkConnectionIconColorWireless,
    this.checkActiveOrPassive,
    this.path,
    this.textColor,
  });

  final String? contentTitle;
  final Function() addOrDeleteFavButtonPressed;
  final IconData? favButtonIcon;
  final String? contentSubTitle1;
  final String? contentSubTitle2;
  final String? path;
  final IconData? checkIconWireless;
  final Color? checkConnectionIconColorWireless;
  final bool? checkActiveOrPassive;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: ProjectColors.primaryColor,
      elevation: 15,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BorderRadiusSizes.highRadius)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 35,
                  child: Container(
                    decoration: BoxDecoration(
                      color: ProjectColors.secondaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.sizeOf(context).width * 0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: CustomSmallCardTitleText(
                                contentTitle: contentTitle),
                          ),
                          Spacer(
                            flex: 1,
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Visibility(
                                      visible: checkActiveOrPassive ?? false,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color:
                                                ProjectColors.secondaryColor),
                                        child: Transform.scale(
                                            scale: 1.2,
                                            child: Image.asset(
                                                "assets/images/canlı_icon_gif.gif")),
                                      ),
                                    )),
                                Expanded(
                                  child: FavStarButton(
                                      addOrDeleteFav:
                                          addOrDeleteFavButtonPressed,
                                      iconData: favButtonIcon),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Spacer(
                  flex: 20,
                ),
                Expanded(
                  flex: 35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomSmallCardTextCable(
                                  subTitle: contentSubTitle1,
                                  title: "Kablolu: ",
                                  path: "$path",
                                  textColor: textColor),
                            ),
                            Expanded(
                              child: CustomSmallCardText(
                                subTitle: contentSubTitle2,
                                title: "Kablosuz: ",
                                iconColor: checkConnectionIconColorWireless,
                                iconData: checkIconWireless,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(
                  flex: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomSmallCardTitleText extends StatelessWidget {
  const CustomSmallCardTitleText({
    super.key,
    required this.contentTitle,
  });

  final String? contentTitle;

  @override
  Widget build(BuildContext context) {
    return Text(
      overflow: TextOverflow.ellipsis,
      textScaler: TextScaler.linear(0.7),
      maxLines: 1,
      softWrap: false,
      contentTitle ?? "Bilinmeyen ATM",
      style: Theme.of(context)
          .textTheme
          .headlineSmall
          ?.copyWith(color: ProjectColors.textTheme),
    );
  }
}

class FavStarButton extends StatelessWidget {
  const FavStarButton({
    super.key,
    required this.addOrDeleteFav,
    required this.iconData,
  });

  final Function() addOrDeleteFav;
  final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: addOrDeleteFav,
      child: SizedBox(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              iconData,
              color: Colors.amber,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomSmallCardText extends StatelessWidget {
  const CustomSmallCardText({
    super.key,
    required this.subTitle,
    this.title,
    this.iconData,
    this.iconColor,
  });

  final String? subTitle;
  final String? title;
  final IconData? iconData;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            overflow: TextOverflow.ellipsis,
            textScaler: TextScaler.linear(0.80),
            maxLines: 2,
            softWrap: false,
            "$title $subTitle",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Spacer(
          flex: 2,
        ),
        Expanded(
          flex: 4,
          child: Icon(
            iconData,
            color: iconColor,
            weight: 900,
            size: MediaQuery.sizeOf(context).height * 0.028,
          ),
        )
      ],
    );
  }
}

class CustomSmallCardTextCable extends StatelessWidget {
  const CustomSmallCardTextCable({
    super.key,
    required this.subTitle,
    this.title,
    this.path,
    this.textColor,
  });

  final String? subTitle;
  final String? title;
  final String? path;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: Text.rich(
            overflow: TextOverflow.ellipsis,
            textScaler: TextScaler.linear(0.80),
            maxLines: 2,
            softWrap: false,
            TextSpan(
              text: "$title",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
              children: [
                TextSpan(
                  text: "$subTitle",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                )
              ],
            ),
          ),
        ),
        Spacer(
          flex: 2,
        ),
        Expanded(
          flex: 4,
          child: Transform.scale(
              scale: 1.4, child: Image.asset("assets/images/$path")),
        )
      ],
    );
  }
}

class CustomAllAtmItemMid extends StatelessWidget {
  const CustomAllAtmItemMid({
    super.key,
    required this.contentTitle,
    required this.addOrDeleteFav,
    required this.goToLink,
    required this.infoPressed,
    this.contentSubTitleIp1,
    this.contentSubTitleIp2,
    this.iconData,
    this.checkIconCable,
    this.checkConnectionIconColorCable,
    this.checkIconWireless,
    this.checkConnectionIconColorWireless,
    this.checkActiveOrPassive,
    this.path,
    this.textColor,
  });

  final String? contentTitle;
  final String? contentSubTitleIp1;
  final String? contentSubTitleIp2;
  final Function() addOrDeleteFav;
  final Function() goToLink;
  final Function() infoPressed;
  final IconData? iconData;
  final IconData? checkIconCable;
  final Color? checkConnectionIconColorCable;
  final IconData? checkIconWireless;
  final Color? checkConnectionIconColorWireless;
  final bool? checkActiveOrPassive;
  final String? path;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.3,
      height: MediaQuery.sizeOf(context).height * 0.25,
      child: Stack(
        children: [
          CustomMidCard(
            path: path,
            checkActiveOrPassive: checkActiveOrPassive,
            checkConnectionIconColorCable: checkConnectionIconColorCable,
            checkIconCable: checkIconCable,
            checkConnectionIconColorWireless: checkConnectionIconColorWireless,
            checkIconWireless: checkIconWireless,
            contentTitle: contentTitle,
            addOrDeleteFav: addOrDeleteFav,
            iconData: iconData,
            contentSubTitleIp1: contentSubTitleIp1,
            contentSubTitleIp2: contentSubTitleIp2,
            textColor: textColor,
          ),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.sizeOf(context).height * 0.03,
              bottom: MediaQuery.sizeOf(context).height * 0.03,
              left: MediaQuery.sizeOf(context).width * 0.02,
              right: MediaQuery.sizeOf(context).width * 0.05,
            ),
            child: InkWell(
              onTap: goToLink,
              child: SizedBox(
                width: double.maxFinite,
                height: double.maxFinite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomMidCard extends StatelessWidget {
  const CustomMidCard({
    super.key,
    required this.contentTitle,
    required this.addOrDeleteFav,
    required this.iconData,
    required this.contentSubTitleIp1,
    required this.contentSubTitleIp2,
    this.checkIconCable,
    this.checkConnectionIconColorCable,
    this.checkIconWireless,
    this.checkConnectionIconColorWireless,
    this.checkActiveOrPassive,
    this.path,
    this.textColor,
  });

  final String? contentTitle;
  final Function() addOrDeleteFav;
  final IconData? iconData;
  final String? contentSubTitleIp1;
  final String? contentSubTitleIp2;
  final IconData? checkIconCable;
  final Color? checkConnectionIconColorCable;
  final IconData? checkIconWireless;
  final Color? checkConnectionIconColorWireless;
  final bool? checkActiveOrPassive;
  final String? path;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(0),
      color: ProjectColors.primaryColor,
      elevation: 15,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BorderRadiusSizes.highRadius)),
      child: Padding(
        padding: EdgeInsets.symmetric(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 35,
              child: Container(
                decoration: BoxDecoration(
                    color: ProjectColors.secondaryColor,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        topLeft: Radius.circular(12))),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.sizeOf(context).width * 0.01,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 65,
                        child:
                            CustomMidCardTitleText(contentTitle: contentTitle),
                      ),
                      Spacer(
                        flex: 5,
                      ),
                      Expanded(
                          flex: 30,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 35,
                                child: Visibility(
                                  visible: checkActiveOrPassive ?? false,
                                  child: Transform.scale(
                                      scale: 2,
                                      child: Image.asset(
                                          "assets/images/canlı_icon_gif.gif")),
                                ),
                              ),
                              Expanded(
                                flex: 65,
                                child: CustomMidCardFavButton(
                                    addOrDeleteFav: addOrDeleteFav,
                                    iconData: iconData),
                              ),
                            ],
                          ))
                    ],
                  ),
                ),
              ),
            ),
            Spacer(
              flex: 15,
            ),
            Expanded(
              flex: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Spacer(
                    flex: 15,
                  ),
                  Expanded(
                    flex: 30,
                    child: Column(
                      children: [
                        Expanded(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomMidCardSubText(
                              text: "Kablolu: ",
                              textColor: textColor,
                            ),
                          ],
                        )),
                        Spacer(),
                        Expanded(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomMidCardSubText(
                              text: "Kablosuz: ",
                              textColor: checkConnectionIconColorWireless,
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 55,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomMidCardSubTextWithImageCable(
                            text: contentSubTitleIp1,
                            path: "$path",
                            textColor: textColor,
                          ),
                        ),
                        Spacer(),
                        Expanded(
                          child: CustomMidCardSubTextWithIcon(
                            text: contentSubTitleIp2,
                            iconData: checkIconWireless,
                            iconColor: checkConnectionIconColorWireless,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(
                    flex: 10,
                  ),
                ],
              ),
            ),
            Spacer(
              flex: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomMidCardTitleText extends StatelessWidget {
  const CustomMidCardTitleText({
    super.key,
    required this.contentTitle,
  });

  final String? contentTitle;

  @override
  Widget build(BuildContext context) {
    return Text(
      overflow: TextOverflow.ellipsis,
      textScaler: TextScaler.linear(0.8),
      maxLines: 2,
      softWrap: false,
      contentTitle ?? "Boş ATM",
      style: Theme.of(context)
          .textTheme
          .headlineSmall
          ?.copyWith(color: ProjectColors.textTheme),
    );
  }
}

class CustomMidCardFavButton extends StatelessWidget {
  const CustomMidCardFavButton({
    super.key,
    required this.addOrDeleteFav,
    required this.iconData,
  });

  final Function() addOrDeleteFav;
  final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: addOrDeleteFav,
      child: SizedBox(
        // width: double.maxFinite,
        //height: double.maxFinite,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              iconData,
              color: Colors.amber,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomMidCardSubTextWithIcon extends StatelessWidget {
  const CustomMidCardSubTextWithIcon({
    super.key,
    required this.text,
    this.iconData,
    this.iconColor,
  });

  final String? text;
  final IconData? iconData;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 8,
          child: Text(
            textScaler: TextScaler.linear(0.65),
            maxLines: 2,
            softWrap: false,
            "$text",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Icon(
            iconData,
            color: iconColor,
            weight: 900,
          ),
        )
      ],
    );
  }
}

class CustomMidCardSubTextWithImageCable extends StatelessWidget {
  const CustomMidCardSubTextWithImageCable({
    super.key,
    required this.text,
    this.path,
    this.textColor,
  });

  final String? text;
  final String? path;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 8,
          child: Text(
            textScaler: TextScaler.linear(0.65),
            maxLines: 2,
            softWrap: false,
            "$text",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Transform.scale(
              origin: Offset(0, 0),
              scale: 1.3,
              child: Image.asset("assets/images/$path")),
        )
      ],
    );
  }
}

class CustomMidCardSubText extends StatelessWidget {
  const CustomMidCardSubText({
    super.key,
    required this.text,
    this.textColor,
  });

  final String? text;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          textScaler: TextScaler.linear(0.65),
          maxLines: 2,
          softWrap: false,
          "$text",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class CustomCommonUsedButton extends StatelessWidget {
  const CustomCommonUsedButton({
    super.key,
    required this.contentTitle,
    required this.onTap,
    this.contentSubTitleIp1,
    this.contentSubTitleIp2,
    this.checkIconCable,
    this.checkConnectionIconColorCable,
    this.checkIconWireless,
    this.checkConnectionIconColorWireless,
    this.checkActiveOrPassive,
    this.path,
    this.textColor,
    this.iconData,
    this.deleteFav,
  });

  final String? contentTitle;
  final String? contentSubTitleIp1;
  final String? contentSubTitleIp2;
  final String? path;
  final IconData? checkIconCable;
  final Color? checkConnectionIconColorCable;
  final IconData? checkIconWireless;
  final Color? checkConnectionIconColorWireless;
  final bool? checkActiveOrPassive;
  final Function()? onTap;
  final Color? textColor;
  final IconData? iconData;
  final void Function()? deleteFav;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: CustomFavCard(
          deleteFav: deleteFav,
          iconData: iconData,
          path: path,
          checkActiveOrPassive: checkActiveOrPassive,
          contentTitle: contentTitle,
          contentSubTitle1: contentSubTitleIp1,
          contentSubTitle2: contentSubTitleIp2,
          checkConnectionIconColorCable: checkConnectionIconColorCable,
          checkConnectionIconColorWireless: checkConnectionIconColorWireless,
          checkIconCable: checkIconCable,
          checkIconWireless: checkIconWireless,
          textColor: textColor),
    );
  }
}

class CustomFavCard extends StatelessWidget {
  const CustomFavCard({
    super.key,
    required this.contentTitle,
    required this.contentSubTitle1,
    required this.contentSubTitle2,
    this.checkIconCable,
    this.checkConnectionIconColorCable,
    this.checkIconWireless,
    this.checkConnectionIconColorWireless,
    this.checkActiveOrPassive,
    this.path,
    this.textColor,
    this.iconData,
    this.deleteFav,
  });

  final String? contentTitle;
  final String? contentSubTitle1;
  final String? contentSubTitle2;
  final String? path;
  final IconData? checkIconCable;
  final Color? checkConnectionIconColorCable;
  final IconData? checkIconWireless;
  final Color? checkConnectionIconColorWireless;
  final bool? checkActiveOrPassive;
  final Color? textColor;
  final IconData? iconData;
  final void Function()? deleteFav;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: ProjectColors.primaryColor,
      elevation: 15,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BorderRadiusSizes.highRadius)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 15,
            child: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12)),
                    color: ProjectColors.secondaryColor),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.sizeOf(context).width * 0.01),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 50,
                          child: CustomFavCardTitleText(
                              contentTitle: contentTitle)),
                      Spacer(
                        flex: 10,
                      ),
                      Expanded(
                          flex: 15,
                          child: Visibility(
                            visible: checkActiveOrPassive ?? false,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: ProjectColors.secondaryColor),
                              child: Transform.scale(
                                  scale: 2,
                                  child: Image.asset(
                                      "assets/images/canlı_icon_gif.gif")),
                            ),
                          )),
                      Spacer(
                        flex: 5,
                      ),
                      Expanded(
                        flex: 20,
                        child: CustomFavCardFavButton(
                            addOrDeleteFav: deleteFav ?? () {},
                            iconData: iconData),
                      ),
                    ],
                  ),
                )),
          ),
          Spacer(
            flex: 5,
          ),
          Expanded(
            flex: 25,
            child: Row(
              children: [
                Expanded(
                  flex: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Spacer(),
                      Expanded(
                          child: CustomFavCardSubText(
                        text: "Kablolu: ",
                        textColor: textColor,
                      )),
                      Spacer(),
                      Expanded(
                          child: CustomFavCardSubText(
                        text: "Kablosuz: ",
                        textColor: checkConnectionIconColorWireless,
                      )),
                      Spacer(),
                    ],
                  ),
                ),
                Expanded(
                  flex: 50,
                  child: Column(
                    children: [
                      Spacer(),
                      Expanded(
                          child: CustomFavCardSubTextWithImageCable(
                        text: contentSubTitle1,
                        iconColor: checkConnectionIconColorCable,
                        iconData: checkIconCable,
                        path: "$path",
                        textColor: textColor,
                      )),
                      Spacer(),
                      Expanded(
                          child: CustomFavCardSubTextWithIconWireless(
                        text: contentSubTitle2,
                        iconColor: checkConnectionIconColorWireless,
                        iconData: checkIconWireless,
                      )),
                      Spacer(),
                    ],
                  ),
                ),
                Spacer(
                  flex: 5,
                ),
              ],
            ),
          ),
          Spacer(
            flex: 5,
          ),
        ],
      ),
    );
  }
}

class CustomFavCardTitleText extends StatelessWidget {
  const CustomFavCardTitleText({
    super.key,
    required this.contentTitle,
  });

  final String? contentTitle;

  @override
  Widget build(BuildContext context) {
    return Text(
      overflow: TextOverflow.ellipsis,
      textScaler: TextScaler.linear(0.8),
      maxLines: 2,
      softWrap: true,
      contentTitle ?? "Boş ATM",
      style: Theme.of(context)
          .textTheme
          .headlineSmall
          ?.copyWith(color: ProjectColors.textTheme),
    );
  }
}

class CustomFavCardFavButton extends StatelessWidget {
  const CustomFavCardFavButton({
    super.key,
    required this.addOrDeleteFav,
    required this.iconData,
  });

  final Function() addOrDeleteFav;
  final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: addOrDeleteFav,
      child: SizedBox(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              iconData,
              color: Colors.amber,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomFavCardSubText extends StatelessWidget {
  const CustomFavCardSubText({
    super.key,
    required this.text,
    this.textColor,
  });

  final String? text;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      textScaler: TextScaler.linear(0.62),
      maxLines: 2,
      softWrap: false,
      "$text",
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class CustomFavCardSubTextWithIconWireless extends StatelessWidget {
  const CustomFavCardSubTextWithIconWireless({
    super.key,
    required this.text,
    this.iconData,
    this.iconColor,
  });

  final String? text;
  final IconData? iconData;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 8,
          child: Text(
            textScaler: TextScaler.linear(0.62),
            maxLines: 2,
            softWrap: false,
            "$text",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.w400,
                ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Icon(
            iconData,
            color: iconColor,
            size: MediaQuery.sizeOf(context).width * 0.015,
          ),
        ),
      ],
    );
  }
}

class CustomFavCardSubTextWithImageCable extends StatelessWidget {
  const CustomFavCardSubTextWithImageCable({
    super.key,
    required this.text,
    this.iconData,
    this.iconColor,
    this.path,
    this.textColor,
  });

  final String? text;
  final IconData? iconData;
  final Color? iconColor;
  final String? path;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 8,
          child: Text(
            textScaler: TextScaler.linear(0.62),
            maxLines: 2,
            softWrap: false,
            "$text",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w400,
                ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Transform.scale(
              scale: 1.3, child: Image.asset("assets/images/$path")),
        ),
      ],
    );
  }
}

class AlertDialogueButton extends StatelessWidget {
  const AlertDialogueButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  final void Function() onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(color: ProjectColors.secondaryColor),
      ),
    );
  }
}
