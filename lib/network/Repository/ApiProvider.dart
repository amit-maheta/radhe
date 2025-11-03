import 'dart:io';

import 'package:radhe/network/Repository/service.dart';

class ApiRepo {
  Future<Map<String, dynamic>> postLogin(mobileNumber, password) async {
    final Service service = Service();
    dynamic getResult = await service.post(
      'auth/'
      'login?phone=$mobileNumber&password=$password',
      true,
      {},
    );
    return getResult;
  }

  Future<Map<String, dynamic>> callRegistration(data) async {
    final Service service = Service();
    dynamic getResult = await service.post(
      'auth/register'
      '',
      false,
      data,
    );
    return getResult;
  }

  // Future<Map<String, dynamic>> customerCreate(data) async {
  //   final Service service = Service();
  //   dynamic getResult = await service.post(
  //     'customers'
  //     '',
  //     true,
  //     data,
  //   );
  //   return getResult;
  // }

  Future<Map<String, dynamic>> customerUpdate(
    String customerID,
    Map<String, dynamic> data,
    List<File> imageFile,
  ) async {
    final Service service = Service();
    dynamic getResult = await service.postWithImages(
      'customers/$customerID',
      data,
      'estimate_image',
      imageFile,
    );
    return getResult;
  }

  Future<Map<String, dynamic>> customerCreate(
    Map<String, dynamic> data,
    List<File> imageFile,
  ) async {
    final Service service = Service();
    dynamic getResult = await service.postWithImages(
      'customers',
      data,
      'estimate_image',
      imageFile,
    );
    return getResult;
  }

  Future<Map<String, dynamic>> getBranches() async {
    final Service service = Service();
    dynamic getResult = await service.get(
      'branches'
      '',
      false,
    );
    return getResult;
  }

  Future<Map<String, dynamic>> getCustomers(startDate, endDate) async {
    final Service service = Service();
    dynamic getResult = await service.get(
      'customers?per_page=1000&page=1&search&from_date=$startDate&to_date=$endDate'
      '',
      true,
    );
    return getResult;
  }

  Future<Map<String, dynamic>> getCustomersStatus(
    String? startDate,
    String? endDate,
  ) async {
    // Ensure the parameters are not null
    if (startDate == null || endDate == null) {
      throw ArgumentError("startDate and endDate cannot be null");
    }

    // Parse the input dates
    DateTime start = DateTime.parse(startDate);
    DateTime end = DateTime.parse(endDate);

    // Adjust dates
    DateTime adjustedStart = start.subtract(const Duration(days: 1));
    DateTime adjustedEnd = end.add(const Duration(days: 1));

    // Format as YYYY-MM-DD
    String formatDate(DateTime d) =>
        "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

    String formattedStart = formatDate(adjustedStart);
    String formattedEnd = formatDate(adjustedEnd);

    // Build the URL
    String url =
        "customers?per_page=1000&page=1&search"
        "&from_last_follow_up_date=$formattedStart&to_last_follow_up_date=$formattedEnd";

    final Service service = Service();
    dynamic getResult;
    if (startDate == endDate) {
      String equalUrl =
          "customers?per_page=1000&page=1&search"
          "&from_last_follow_up_date=$startDate&to_last_follow_up_date=$endDate";
      getResult = await service.get(equalUrl, true);
    } else {
      getResult = await service.get(url, true);
    }

    return getResult;
  }

  // Future<dynamic> regFCM(_user_id, deviceId) async {
  //   final getPlatform = Platform.isAndroid ? 'android' : 'ios';
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.FCM_REG +
  //         "TokenKey=" +
  //         AppConstants.fcmKey +
  //         "&DeviceId=" +
  //         deviceId +
  //         "&DeviceType=" +
  //         getPlatform +
  //         "&UserId=" +
  //         _user_id,
  //     false,
  //   );
  //   return getResult['reposnoObj'];
  // }

  // Future<List<dynamic>> getCountry(getCityName) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.GET_SOCIETY + "CityName=" + getCityName,
  //     false,
  //   );
  //   return getResult['response']['data'];
  // }

  // Future<List<dynamic>> getCity() async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(EndPoint.GET_CITY, false);
  //   return getResult['response']['data'];
  // }

  // Future<dynamic> getValidRegisterType(getCode) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.GET_REGISTER_TYPE + "Code=" + getCode,
  //     false,
  //   );
  //   return getResult['response'];
  // }

  // Future<dynamic> getEcash(_user_id) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.GET_ECASH + "UserID=" + _user_id,
  //     false,
  //   );
  //   return getResult['response']['data'];
  // }

  // Future<dynamic> checkUpdate() async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(EndPoint.CHECK_UPDATE, false);
  //   return getResult['response']['data'];
  // }

  // Future<dynamic> getProducts(user_id) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.GET_PRODUCTS + 'UserId=' + user_id,
  //     false,
  //   );
  //   return getResult['response']['data'];
  // }

  // Future<dynamic> checkReferralCode(refCode) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.CHECK_REFERRAL + "ReferralCode=" + refCode,
  //     false,
  //   );
  //   return getResult['response'];
  // }

  // Future<dynamic> getBanner() async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(EndPoint.GET_BANNER, false);
  //   return getResult['response']["data"];
  // }

  // Future<dynamic> getCategories() async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(EndPoint.GET_CATEGORIES, false);
  //   return getResult['response']["data"];
  // }

  // Future<dynamic> getCategoriesProducts(
  //   user_id,
  //   categoriesID,
  //   Searchtext,
  //   filter,
  // ) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.GET_CATEGORIES_PRODUCT +
  //         "CategoryId=" +
  //         categoriesID.toString() +
  //         "&Searchtext=" +
  //         Searchtext +
  //         "&filter=" +
  //         filter +
  //         '&UserId=' +
  //         user_id,
  //     false,
  //   );
  //   return getResult['response']["data"];
  // }

  // Future<dynamic> getProductDetail(productID, _user_id) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.GET_PRODUCT_DETAIL +
  //         "ProductId=" +
  //         productID.toString() +
  //         '&UserId=' +
  //         _user_id,
  //     false,
  //   );
  //   return getResult['response']["data"];
  // }

  // Future<dynamic> addToCartSubscription(userid, productID, quantity) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.ADD_TO_CART_SUBSCRIPTION +
  //         "userid=" +
  //         userid +
  //         "&ProductId=" +
  //         productID.toString() +
  //         "&quantity=" +
  //         quantity.toString() +
  //         "&sign=plus",
  //     false,
  //   );
  //   return getResult['response'];
  // }

  // Future<dynamic> addToCartSubscriptionUpdate(
  //   PRODUCT_ID,
  //   _user_id,
  //   qty,
  //   addOrMinus,
  // ) async {
  //   final Service _service = Service();
  //   //  GoMandiMobileAPI/SubscriptionOrderQtyChange?Id=33&userid=41&Qty=7&sign=Plus
  //   dynamic getResult = await _service.get(
  //     EndPoint.ADD_TO_CART_SUBSCRIPTION_UPDATE +
  //         "Id=" +
  //         PRODUCT_ID +
  //         "&userid=" +
  //         _user_id +
  //         "&Qty=" +
  //         qty.toString() +
  //         "&sign=" +
  //         addOrMinus,
  //     false,
  //   );
  //   return getResult['response'];
  // }

  // Future<dynamic> removeItemToCartSubscription(
  //   userid,
  //   productID,
  //   quantity,
  // ) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.ADD_TO_CART_SUBSCRIPTION +
  //         "userid=" +
  //         userid +
  //         "&ProductId=" +
  //         productID.toString() +
  //         "&quantity=" +
  //         quantity.toString() +
  //         "&sign=minus",
  //     false,
  //   );
  //   return getResult['response'];
  // }

  // Future<dynamic> addToCart(userid, productID, quantity) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.ADD_TO_CART +
  //         "userid=" +
  //         userid +
  //         "&ProductId=" +
  //         productID.toString() +
  //         "&quantity=" +
  //         quantity.toString() +
  //         "&sign=plus",
  //     false,
  //   );
  //   return getResult['response'];
  // }

  // Future<dynamic> addToCartOffers(userid, productID, quantity) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.ADD_TO_CART_OFFER +
  //         "userid=" +
  //         userid +
  //         "&ProductId=" +
  //         productID.toString() +
  //         "&quantity=" +
  //         quantity.toString() +
  //         "&sign=plus",
  //     false,
  //   );
  //   return getResult['response'];
  // }

  // Future<dynamic> removeItemToCart(userid, productID, quantity) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.ADD_TO_CART +
  //         "userid=" +
  //         userid +
  //         "&ProductId=" +
  //         productID.toString() +
  //         "&quantity=" +
  //         quantity.toString() +
  //         "&sign=minus",
  //     false,
  //   );
  //   return getResult['response'];
  // }

  // Future<dynamic> deleteItemFromCart(userid, productID) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.DELETE_ITEM_FROM_CART +
  //         "userid=" +
  //         userid +
  //         "&ProductId=" +
  //         productID.toString(),
  //     false,
  //   );
  //   return getResult['response'];
  // }

  // Future<dynamic> deleteItemFromCartSubscription(userid, productID) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.DELETE_ITEM_FROM_CART_SUBSCRIPTION +
  //         "userid=" +
  //         userid +
  //         "&ProductId=" +
  //         productID.toString(),
  //     false,
  //   );
  //   return getResult['response'];
  // }

  // Future<dynamic> cartList(userid) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.MY_CART_LISTING +
  //         "userid=" +
  //         userid +
  //         "&pickupid=0&ShippingAddressId=0&EcashCheck=false&EwalletAmount=0",
  //     false,
  //   );
  //   return getResult['response']['data'];
  // }

  // Future<dynamic> offersList(userid) async {
  //   final Service _service = Service();
  //   dynamic getResult =
  //       // await _service.get(EndPoint.GET_OFFER_LIST + "userid=" + userid, false);
  //       await _service.get(EndPoint.GET_OFFER_LIST, false);
  //   return getResult['response'];
  // }

  // Future<dynamic> cartListSubscription(userid, _UPDATE, _PRODUCT_ID) async {
  //   final Service _service = Service();

  //   // dynamic getResult = '';

  //   // if (_UPDATE == 'YES') {
  //   dynamic getResult = await _service.get(
  //     _UPDATE == 'YES'
  //         ? EndPoint.MY_CART_LISTING_SUBSCRIPTION_UPDATE +
  //               "Id=" +
  //               _PRODUCT_ID +
  //               "&UserId=" +
  //               userid
  //         : EndPoint.MY_CART_LISTING_SUBSCRIPTION +
  //               "userid=" +
  //               userid +
  //               "&ShippingAddressId=0",
  //     false,
  //   );

  //   return getResult['response']['data'];
  // }

  // Future<dynamic> checkOut(userid, addressD, ecash, eWallet) async {
  //   final Service _service = Service();
  //   String getIsEcash = ecash == true ? "true" : "false";
  //   String getIsWallet = eWallet == true ? "true" : "false";
  //   dynamic getResult = await _service.get(
  //     EndPoint.MY_CART_LISTING +
  //         "userid=" +
  //         userid +
  //         "&pickupid=0&ShippingAddressId=" +
  //         addressD +
  //         "&EcashCheck=" +
  //         getIsEcash +
  //         "&EwalletAmount=0" +
  //         "&EwalletCheck=" +
  //         getIsWallet,
  //     false,
  //   );
  //   return getResult['response']['data'];
  // }

  // Future<dynamic> addressList(userid) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.ADDRESS_LISTING + "UserId=" + userid,
  //     false,
  //   );
  //   return getResult['response'];
  // }

  // Future<dynamic> deleteCartAfterFinishShoping(userid) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.DELETE_SHOPING_CART_ITEM + "&userid=" + userid,
  //     false,
  //   );
  //   return getResult['response'];
  // }

  // Future<dynamic> myOrderList(userid) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.MY_ORDER_DETAIL_DATA + "&userId=" + userid,
  //     false,
  //   );
  //   return getResult['response'];
  // }

  // Future<dynamic> myOrderListForSmartRetailer(userid) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.SMART_RETAILER + "&userId=" + userid,
  //     false,
  //   );
  //   return getResult['response'];
  // }

  // // userid=41& ---
  // // pickupid=0& --
  // // ShippingAddressId=21& ---
  // // EwalletAmount=0&
  // // EcashCheck=false&
  // // PaymentMode=Online&
  // // TotalAmount=1

  // Future<dynamic> onlinePayment(
  //   userid,
  //   addressD,
  //   ecash,
  //   grandTotal,
  //   eWallet,
  //   sloatValue,
  // ) async {
  //   final Service _service = Service();
  //   String getIsEcash = ecash == true ? "true" : "false";
  //   String getIsEWallet = eWallet == true ? "true" : "false";
  //   dynamic getResult = await _service.get(
  //     EndPoint.ONLINE_PAYMENT +
  //         "userid=" +
  //         userid +
  //         "&pickupid=0&ShippingAddressId=" +
  //         addressD +
  //         "&EwalletAmount=0" +
  //         "&EcashCheck=" +
  //         getIsEcash +
  //         "&PaymentMode=Online&" +
  //         "TotalAmount=" +
  //         grandTotal +
  //         "&EwalletCheck=" +
  //         getIsEWallet +
  //         "&TimeSlot=" +
  //         sloatValue,
  //     false,
  //   );
  //   return getResult['response']['data'];
  // }

  // Future<dynamic> getEcashHistory(_user_id) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.E_CASH_HISTORY + "UserID=" + _user_id,
  //     false,
  //   );
  //   return getResult['response']['data'];
  // }

  // Future<dynamic> getEWalletHistory(_user_id) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.E_WALLET_HISTORY + "UserID=" + _user_id,
  //     false,
  //   );
  //   return getResult['response']['data'];
  // }

  // Future<dynamic> getReffaralHistory(_user_id) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.REFFARAL_HISTORY + "UserID=" + _user_id,
  //     false,
  //   );
  //   return getResult['response']['data'];
  // }

  // Future<dynamic> getQtyCount(_user_id) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.GET_QTY_COUNT + "UserID=" + _user_id,
  //     false,
  //   );
  //   return getResult['response']['data'];
  // }

  // Future<dynamic> getProductUnits(product_id) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.GET_PRODUCT_UNIT + "ProductId=" + product_id,
  //     false,
  //   );
  //   return getResult['response'];
  // }

  // Future<dynamic> getWalletImage() async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(EndPoint.RECHARGE_PLAN, false);
  //   return getResult['response']['data'];
  // }

  // Future<dynamic> getRechargeAmountCall(userid) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(EndPoint.RECHARGE_AMOUNT, false);
  //   return getResult['response']['data'];
  // }

  // Future<dynamic> getRechargePaymentGateway(_user_id, rechargeID) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.RECHARGE_FOR_PAYMENT +
  //         "userid=" +
  //         _user_id +
  //         "&Rechargeplanid=" +
  //         rechargeID,
  //     false,
  //   );
  //   return getResult['response']['data'];
  // }

  // Future<dynamic> getRechargeWithAmount(_user_id, rechargeAmount) async {
  //   final Service _service = Service();
  //   // GoMandiMobileAPI/GetUserRechargeWithPaymentGatewayRecharge?userid=41&Rechargeplanid=4&RechargeAmount=1
  //   dynamic getResult = await _service.get(
  //     EndPoint.RECHARGE_WITH_AMOUNT +
  //         "userid=" +
  //         _user_id +
  //         '&Rechargeplanid=4&RechargeAmount=' +
  //         rechargeAmount,
  //     false,
  //   );
  //   return getResult['response']['data'];
  // }

  // Future<dynamic> getNotificationList() async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(EndPoint.NOTIFICATION_LIST, false);
  //   return getResult['response']['data'];
  // }

  // Future<dynamic> changePassword(user_id, newPassword) async {
  //   print(user_id);
  //   print(newPassword);
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.CHANGE_PASSWORD +
  //         "UserId=" +
  //         AppConstants.userID +
  //         "&NewPassword=" +
  //         newPassword.toString(),
  //     false,
  //   );
  //   return getResult['response'];
  // }

  // Future<dynamic> getUserPicture(user_id) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.GET_USER_PIC + 'UserId=' + user_id,
  //     false,
  //   );
  //   return getResult['response'];
  // }

  // Future<dynamic> getMandiList() async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(EndPoint.GO_MANDI_LIST_MAP, false);
  //   return getResult['response'];
  // }

  // Future<dynamic> getAddToWishList(user_id, product_id, flag) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.ADD_WISHLIST +
  //         'userid=' +
  //         user_id +
  //         '&productid=' +
  //         product_id +
  //         '&Flag=' +
  //         flag,
  //     false,
  //   );
  //   return getResult['response']["data"];
  // }

  // Future<dynamic> getWishListProducts(user_id) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.GET_WISH_LIST_PRODUCTS + 'userid=' + user_id,
  //     false,
  //   );
  //   return getResult['response']['data'];
  // }

  // Future<dynamic> getScriptionBanner() async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.GET_SUBSCRIPTION_BANNER,
  //     false,
  //   );
  //   return getResult['response']["data"];
  // }

  // Future<dynamic> getMyScriptionBanner(_user_id) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.GET_MY_SUBSCRIPTION + 'PlanId=0&UserId=' + _user_id,
  //     false,
  //   );
  //   return getResult['response']["data"];
  // }

  // Future<dynamic> getScriptionProductList(_id, _user_id) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.GET_SCRIPTION_PRODUCT_LIST +
  //         'PlanId=' +
  //         _id +
  //         '&userid=' +
  //         _user_id,
  //     false,
  //   );
  //   return getResult['response']["data"];
  // }

  // Future<dynamic> getScriptionProductListPay(
  //   _user_id,
  //   _master_id,
  //   _amount,
  //   ADDRESSID,
  // ) async {
  //   final Service _service = Service();
  //   // userid=41&SubscribePlanMasterId=1&TotalAmount=1800
  //   dynamic getResult = await _service.get(
  //     EndPoint.GET_SCRIPTION_PRODUCT_LIST_PAY +
  //         'userid=' +
  //         _user_id +
  //         '&SubscribePlanMasterId=' +
  //         _master_id +
  //         '&TotalAmount=' +
  //         _amount +
  //         '&ShippingId=' +
  //         ADDRESSID,
  //     false,
  //   );
  //   return getResult['response']["data"];
  // }

  // Future<dynamic> getUpdateSubscriptionAddress(
  //   OrderNumber,
  //   _user_id,
  //   ShippingId,
  // ) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.UPDATE_SUBSCRIPTON_ADDRESS_UPDATE +
  //         'OrderNumber=' +
  //         OrderNumber +
  //         '&UserId=' +
  //         _user_id +
  //         '&ShippingId=' +
  //         ShippingId,
  //     false,
  //   );
  //   return getResult['response'];
  // }

  // Future<dynamic> chipsData() async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(EndPoint.CHIPS_DATA, false);
  //   return getResult['response'];
  // }

  // Future<dynamic> getFFSubscription(_user_id) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.GET_FF_SUBSCRIPTION + 'UserId=' + _user_id,
  //     false,
  //   );
  //   return getResult['response'];
  // }

  // Future<dynamic> getFFSubscriptionDelete(id, _user_id) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.GET_FF_SUBSCRIPTION_DELETE + 'Id=' + id + '&userid=' + _user_id,
  //     false,
  //   );
  //   return getResult['response'];
  // }

  // Future<dynamic> getFFSubscriptionPause(id, _user_id, isPause) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.GET_FF_SUBSCRIPTION_PAUSE +
  //         'Id=' +
  //         id +
  //         '&userid=' +
  //         _user_id +
  //         '&IsPause=' +
  //         isPause,
  //     false,
  //   );
  //   return getResult['response'];
  // }

  // Future<dynamic> getFeedBackQueryListCall(userid) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(EndPoint.FEEBACK_QUERY_LIST, false);
  //   return getResult['response']['data'];
  // }

  // Future<dynamic> getTimeSlotListCall() async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.GET_DELIVERY_TIME_SLOT,
  //     false,
  //   );
  //   return getResult['response']['data'];
  // }

  // Future<dynamic> getTicketList(getUSerID) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.GET_TICKET_LIST + "UserId=" + getUSerID,
  //     false,
  //   );
  //   return getResult['response']['data'];
  // }

  // Future<dynamic> getChatList(getTicketID) async {
  //   final Service _service = Service();
  //   dynamic getResult = await _service.get(
  //     EndPoint.CHAT_LIST + "Id=" + getTicketID,
  //     false,
  //   );
  //   return getResult['response']['data'];
  // }
}
