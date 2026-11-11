import 'dart:convert';

import 'card_action_model.dart';

RegisterRequestModel registerRequestModelFromJson(String str) =>
    RegisterRequestModel.fromJson(json.decode(str));

class RegisterRequestModel {
  final List<Item> items;
  final List<CardActionModel> cardActions;

  RegisterRequestModel({required this.items, this.cardActions = const []});

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) =>
      RegisterRequestModel(
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
        cardActions: (json['card_actions'] as List<dynamic>? ?? const [])
            .map((action) => CardActionModel.fromJson(action))
            .toList(growable: false),
      );

  Map<String, dynamic> toJson() => {
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
    'card_actions': cardActions
        .map(
          (action) => {
            'id': action.id,
            'label': action.label,
            'icon': action.icon,
            'action': action.action,
          },
        )
        .toList(growable: false),
  };
}

class Item {
  final String? externalId;
  final String? entityType;
  final String templateName;
  final ItemTemplateProperties templateProperties;

  Item({
    this.externalId,
    this.entityType,
    required this.templateName,
    required this.templateProperties,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    externalId: json["external_id"],
    entityType: json["entity_type"],
    templateName: json["template_name"],
    templateProperties: ItemTemplateProperties.fromJson(
      json["template_properties"],
    ),
  );

  Map<String, dynamic> toJson() => {
    "external_id": externalId,
    "entity_type": entityType,
    "template_name": templateName,
    "template_properties": templateProperties.toJson(),
  };
}

class ItemTemplateProperties {
  final PurpleBody body;
  final List<ChildList> childList;
  final TrackingData? trackingData;
  final CardLiveActivity? cardLiveActivity;

  ItemTemplateProperties({
    required this.body,
    required this.childList,
    this.trackingData,
    this.cardLiveActivity,
  });

  factory ItemTemplateProperties.fromJson(Map<String, dynamic> json) =>
      ItemTemplateProperties(
        body: PurpleBody.fromJson(json["body"]),
        childList: List<ChildList>.from(
          json["child_list"].map((x) => ChildList.fromJson(x)),
        ),
        trackingData: json["tracking_data"] == null
            ? null
            : TrackingData.fromJson(json["tracking_data"]),
        cardLiveActivity: json["card_live_activity"] == null
            ? null
            : CardLiveActivity.fromJson(json["card_live_activity"]),
      );

  Map<String, dynamic> toJson() => {
    "body": body.toJson(),
    "child_list": List<dynamic>.from(childList.map((x) => x.toJson())),
    "tracking_data": trackingData?.toJson(),
    "card_live_activity": cardLiveActivity?.toJson(),
  };
}

class PurpleBody {
  final Cta? cta2;
  final String templateType;
  final Cta? cta1;
  final Cta? cta3;
  final Statement? statement;
  final Unbilled? unbilled;
  final Asset1? asset1;
  final bool? showAlert;
  final bool? isLight;
  final List<FlipperPill>? flipperPill;
  final bool? rupaySupported;
  final String? provider;
  final bool? isCredCard;
  final String? text3;
  final bool? tapAndPaySupported;
  final Asset1? asset3;
  final String? text5;
  final String? text4;
  final Asset1? asset2;
  final String? alertColor;
  final String? instrumentId;
  final Map<String, dynamic>? cardUi;

  PurpleBody({
    this.cta2,
    required this.templateType,
    this.cta1,
    this.cta3,
    this.statement,
    this.unbilled,
    this.asset1,
    this.showAlert,
    this.isLight,
    this.flipperPill,
    this.rupaySupported,
    this.provider,
    this.isCredCard,
    this.text3,
    this.tapAndPaySupported,
    this.asset3,
    this.text5,
    this.text4,
    this.asset2,
    this.alertColor,
    this.instrumentId,
    this.cardUi,
  });

  factory PurpleBody.fromJson(Map<String, dynamic> json) => PurpleBody(
    cta2: json["cta_2"] == null ? null : Cta.fromJson(json["cta_2"]),
    templateType: json["template_type"],
    cta1: json["cta_1"] == null ? null : Cta.fromJson(json["cta_1"]),
    cta3: json["cta_3"] == null ? null : Cta.fromJson(json["cta_3"]),
    statement: json["statement"] == null
        ? null
        : Statement.fromJson(json["statement"]),
    unbilled: json["unbilled"] == null
        ? null
        : Unbilled.fromJson(json["unbilled"]),
    asset1: json["asset_1"] == null ? null : Asset1.fromJson(json["asset_1"]),
    showAlert: json["show_alert"],
    isLight: json["is_light"],
    flipperPill: json["flipper_pill"] == null
        ? []
        : List<FlipperPill>.from(
            json["flipper_pill"]!.map((x) => FlipperPill.fromJson(x)),
          ),
    rupaySupported: json["rupay_supported"],
    provider: json["provider"],
    isCredCard: json["is_cred_card"],
    text3: json["text_3"],
    tapAndPaySupported: json["tap_and_pay_supported"],
    asset3: json["asset_3"] == null ? null : Asset1.fromJson(json["asset_3"]),
    text5: json["text_5"],
    text4: json["text_4"],
    asset2: json["asset_2"] == null ? null : Asset1.fromJson(json["asset_2"]),
    alertColor: json["alert_color"],
    instrumentId: json["instrument_id"],
    cardUi: json['card_ui'] == null
        ? null
        : Map<String, dynamic>.from(json['card_ui']),
  );

  Map<String, dynamic> toJson() => {
    "cta_2": cta2?.toJson(),
    "template_type": templateType,
    "cta_1": cta1?.toJson(),
    "cta_3": cta3?.toJson(),
    "statement": statement?.toJson(),
    "unbilled": unbilled?.toJson(),
    "asset_1": asset1?.toJson(),
    "show_alert": showAlert,
    "is_light": isLight,
    "flipper_pill": flipperPill == null
        ? []
        : List<dynamic>.from(flipperPill!.map((x) => x.toJson())),
    "rupay_supported": rupaySupported,
    "provider": provider,
    "is_cred_card": isCredCard,
    "text_3": text3,
    "tap_and_pay_supported": tapAndPaySupported,
    "asset_3": asset3?.toJson(),
    "text_5": text5,
    "text_4": text4,
    "asset_2": asset2?.toJson(),
    "alert_color": alertColor,
    "instrument_id": instrumentId,
    'card_ui': cardUi,
  };
}

class Asset1 {
  final Asset1Type type;
  final String url;

  Asset1({required this.type, required this.url});

  factory Asset1.fromJson(Map<String, dynamic> json) =>
      Asset1(type: asset1TypeValues.map[json["type"]]!, url: json["url"]);

  Map<String, dynamic> toJson() => {
    "type": asset1TypeValues.reverse[type],
    "url": url,
  };
}

enum Asset1Type { IMAGE }

final asset1TypeValues = EnumValues({"image": Asset1Type.IMAGE});

class Cta {
  final Cta1Type type;
  final Asset1? asset;
  final String? title;
  final Deeplink? deeplink;

  Cta({required this.type, this.asset, this.title, this.deeplink});

  factory Cta.fromJson(Map<String, dynamic> json) => Cta(
    type: cta1TypeValues.map[json["type"]]!,
    asset: json["asset"] == null ? null : Asset1.fromJson(json["asset"]),
    title: json["title"],
    deeplink: json["deeplink"] == null
        ? null
        : Deeplink.fromJson(json["deeplink"]),
  );

  Map<String, dynamic> toJson() => {
    "type": cta1TypeValues.reverse[type],
    "asset": asset?.toJson(),
    "title": title,
    "deeplink": deeplink?.toJson(),
  };
}

class Deeplink {
  final String url;

  Deeplink({required this.url});

  factory Deeplink.fromJson(Map<String, dynamic> json) =>
      Deeplink(url: json["url"]);

  Map<String, dynamic> toJson() => {"url": url};
}

enum Cta1Type { DEEPLINK, FLOW }

final cta1TypeValues = EnumValues({
  "deeplink": Cta1Type.DEEPLINK,
  "flow": Cta1Type.FLOW,
});

class FlipperPill {
  final int priority;
  final int duration;
  final Cta cta1;
  final FlipperPillType type;

  FlipperPill({
    required this.priority,
    required this.duration,
    required this.cta1,
    required this.type,
  });

  factory FlipperPill.fromJson(Map<String, dynamic> json) => FlipperPill(
    priority: json["priority"],
    duration: json["duration"],
    cta1: Cta.fromJson(json["cta_1"]),
    type: flipperPillTypeValues.map[json["type"]]!,
  );

  Map<String, dynamic> toJson() => {
    "priority": priority,
    "duration": duration,
    "cta_1": cta1.toJson(),
    "type": flipperPillTypeValues.reverse[type],
  };
}

enum FlipperPillType { PENDING_ACTION, VIEW_DETAILS }

final flipperPillTypeValues = EnumValues({
  "pending_action": FlipperPillType.PENDING_ACTION,
  "view_details": FlipperPillType.VIEW_DETAILS,
});

class Statement {
  final int? amount;
  final String? text1;
  final String? text3;
  final int? dueCount;
  final String text2;
  final Cta? cta2;
  final Cta1 cta1;
  final Asset1? asset4;

  Statement({
    this.amount,
    this.text1,
    this.text3,
    this.dueCount,
    required this.text2,
    this.cta2,
    required this.cta1,
    this.asset4,
  });

  factory Statement.fromJson(Map<String, dynamic> json) => Statement(
    amount: json["amount"],
    text1: json["text_1"],
    text3: json["text_3"],
    dueCount: json["due_count"],
    text2: json["text_2"],
    cta2: json["cta_2"] == null ? null : Cta.fromJson(json["cta_2"]),
    cta1: Cta1.fromJson(json["cta_1"]),
    asset4: json["asset_4"] == null ? null : Asset1.fromJson(json["asset_4"]),
  );

  Map<String, dynamic> toJson() => {
    "amount": amount,
    "text_1": text1,
    "text_3": text3,
    "due_count": dueCount,
    "text_2": text2,
    "cta_2": cta2?.toJson(),
    "cta_1": cta1.toJson(),
    "asset_4": asset4?.toJson(),
  };
}

class Cta1 {
  final Cta1Type type;
  final Flow? flow;
  final String? labelColor;
  final String? labelText;
  final Asset1? labelAsset;
  final Deeplink? deeplink;
  final String? ctaType;
  final String? title;

  Cta1({
    required this.type,
    this.flow,
    this.labelColor,
    this.labelText,
    this.labelAsset,
    this.deeplink,
    this.ctaType,
    this.title,
  });

  factory Cta1.fromJson(Map<String, dynamic> json) => Cta1(
    type: cta1TypeValues.map[json["type"]]!,
    flow: json["flow"] == null ? null : Flow.fromJson(json["flow"]),
    labelColor: json["label_color"],
    labelText: json["label_text"],
    labelAsset: json["label_asset"] == null
        ? null
        : Asset1.fromJson(json["label_asset"]),
    deeplink: json["deeplink"] == null
        ? null
        : Deeplink.fromJson(json["deeplink"]),
    ctaType: json["cta_type"],
    title: json["title"],
  );

  Map<String, dynamic> toJson() => {
    "type": cta1TypeValues.reverse[type],
    "flow": flow?.toJson(),
    "label_color": labelColor,
    "label_text": labelText,
    "label_asset": labelAsset?.toJson(),
    "deeplink": deeplink?.toJson(),
    "cta_type": ctaType,
    "title": title,
  };
}

class Flow {
  final String type;

  Flow({required this.type});

  factory Flow.fromJson(Map<String, dynamic> json) => Flow(type: json["type"]);

  Map<String, dynamic> toJson() => {"type": type};
}

class Unbilled {
  final int amount;
  final String text1;
  final String text3;
  final String text2;
  final Cta cta2;

  Unbilled({
    required this.amount,
    required this.text1,
    required this.text3,
    required this.text2,
    required this.cta2,
  });

  factory Unbilled.fromJson(Map<String, dynamic> json) => Unbilled(
    amount: json["amount"],
    text1: json["text_1"],
    text3: json["text_3"],
    text2: json["text_2"],
    cta2: Cta.fromJson(json["cta_2"]),
  );

  Map<String, dynamic> toJson() => {
    "amount": amount,
    "text_1": text1,
    "text_3": text3,
    "text_2": text2,
    "cta_2": cta2.toJson(),
  };
}

class CardLiveActivity {
  final bool shouldScale;

  CardLiveActivity({required this.shouldScale});

  factory CardLiveActivity.fromJson(Map<String, dynamic> json) =>
      CardLiveActivity(shouldScale: json["should_scale"]);

  Map<String, dynamic> toJson() => {"should_scale": shouldScale};
}

class ChildList {
  final String externalId;
  final String entityType;
  final String templateName;
  final ChildListTemplateProperties templateProperties;

  ChildList({
    required this.externalId,
    required this.entityType,
    required this.templateName,
    required this.templateProperties,
  });

  factory ChildList.fromJson(Map<String, dynamic> json) => ChildList(
    externalId: json["external_id"],
    entityType: json["entity_type"],
    templateName: json["template_name"],
    templateProperties: ChildListTemplateProperties.fromJson(
      json["template_properties"],
    ),
  );

  Map<String, dynamic> toJson() => {
    "external_id": externalId,
    "entity_type": entityType,
    "template_name": templateName,
    "template_properties": templateProperties.toJson(),
  };
}

class ChildListTemplateProperties {
  final FluffyBody body;

  ChildListTemplateProperties({required this.body});

  factory ChildListTemplateProperties.fromJson(Map<String, dynamic> json) =>
      ChildListTemplateProperties(body: FluffyBody.fromJson(json["body"]));

  Map<String, dynamic> toJson() => {"body": body.toJson()};
}

class FluffyBody {
  final Asset1 asset;
  final String templateType;
  final List<FlipperConfig> flipperConfig;

  FluffyBody({
    required this.asset,
    required this.templateType,
    required this.flipperConfig,
  });

  factory FluffyBody.fromJson(Map<String, dynamic> json) => FluffyBody(
    asset: Asset1.fromJson(json["asset"]),
    templateType: json["template_type"],
    flipperConfig: List<FlipperConfig>.from(
      json["flipper_config"].map((x) => FlipperConfig.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "asset": asset.toJson(),
    "template_type": templateType,
    "flipper_config": List<dynamic>.from(flipperConfig.map((x) => x.toJson())),
  };
}

class FlipperConfig {
  final CtaClass cta;
  final bool shouldShowTimer;
  final String text1;

  FlipperConfig({
    required this.cta,
    required this.shouldShowTimer,
    required this.text1,
  });

  factory FlipperConfig.fromJson(Map<String, dynamic> json) => FlipperConfig(
    cta: CtaClass.fromJson(json["cta"]),
    shouldShowTimer: json["should_show_timer"],
    text1: json["text_1"],
  );

  Map<String, dynamic> toJson() => {
    "cta": cta.toJson(),
    "should_show_timer": shouldShowTimer,
    "text_1": text1,
  };
}

class CtaClass {
  final Deeplink deeplink;
  final Cta1Type type;

  CtaClass({required this.deeplink, required this.type});

  factory CtaClass.fromJson(Map<String, dynamic> json) => CtaClass(
    deeplink: Deeplink.fromJson(json["deeplink"]),
    type: cta1TypeValues.map[json["type"]]!,
  );

  Map<String, dynamic> toJson() => {
    "deeplink": deeplink.toJson(),
    "type": cta1TypeValues.reverse[type],
  };
}

class TrackingData {
  final bool userActionTrackingEnabled;
  final bool tagClick;
  final bool tagLoad;

  TrackingData({
    required this.userActionTrackingEnabled,
    required this.tagClick,
    required this.tagLoad,
  });

  factory TrackingData.fromJson(Map<String, dynamic> json) => TrackingData(
    userActionTrackingEnabled: json["user_action_tracking_enabled"],
    tagClick: json["tag_click"],
    tagLoad: json["tag_load"],
  );

  Map<String, dynamic> toJson() => {
    "user_action_tracking_enabled": userActionTrackingEnabled,
    "tag_click": tagClick,
    "tag_load": tagLoad,
  };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
