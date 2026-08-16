import 'comedy_constants.dart';

class EventPointsConstants {
  static const String baseUrl = ComedyConstants.baseUrl;

  // Endpoints
  static const String eventsList = '$baseUrl/events/list';
  static const String eventCheckin = '$baseUrl/events/checkin';
  static const String userPoints = '$baseUrl/user/points';
  static const String rewardsCatalog = '$baseUrl/rewards/catalog';
  static const String redeemReward = '$baseUrl/rewards/redeem';
}
