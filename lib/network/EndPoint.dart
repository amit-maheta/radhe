class EndPoint {
  static String LOGIN = 'Account';
  static String FCM_REG = 'MasterSettingValues/PostNotificationToken?';
  static String GET_SOCIETY = 'MasterSettingValues/GetSocietyCityWise?';
  static String GET_CITY = 'GoMandiMobileAPI/GetCityList';
  static String GET_REGISTER_TYPE = 'GoMandiMobileAPI/CheckEmployeeCode?';
  static String SIGN_UP = 'Auth/Register?';
  static String VERIFY_OTP = 'Auth/OTPWithForgotPassword?';
  static String SEND_OTP = 'Auth/SendOTP?';
  static String RESET_PASSWORD = 'Auth/ForgotPassword?';
  static String GET_ECASH = 'GoMandiMobileAPI/GetEcashUserByBalance?';
  static String CHECK_UPDATE = 'MasterSettingValues/GetMasterSettingList';
  static String GET_PRODUCTS = 'Product/GetProductList?';
  static String CHECK_REFERRAL = 'GoMandiMobileAPI/CheckRefeeralCode?';
  static String GET_BANNER = 'GoMandiMobileAPI/GetHomeBannerImageList';
  static String GET_CATEGORIES = 'Category/GetCategoryList';
  static String GET_CATEGORIES_PRODUCT = 'GoMandiMobileAPI/GetProductList?';
  // static String GET_PRODUCT_DETAIL = 'GoMandiMobileAPI/GetProductById?';
  static String GET_PRODUCT_DETAIL = 'GoMandiMobileAPI/GetProductByWithUserId?';
  static String ADD_TO_CART = 'GoMandiMobileAPI/AddToCart?';
  static String ADD_TO_CART_OFFER = 'GoMandiMobileAPI/AddToCartOffer?';
  static String ADD_TO_CART_SUBSCRIPTION =
      'GoMandiMobileAPI/AddToSubscribeCart?';
  static String ADD_TO_CART_SUBSCRIPTION_UPDATE =
      'GoMandiMobileAPI/SubscriptionOrderQtyChange?';
  static String MY_CART_LISTING = 'GoMandiMobileAPI/GetCartItemsList?';
  static String MY_CART_LISTING_SUBSCRIPTION =
      'GoMandiMobileAPI/GetSubscribeCartItemsList?';
  static String MY_CART_LISTING_SUBSCRIPTION_UPDATE =
      'GoMandiMobileAPI/GetSubscribeUserOrderById?';
  static String DELETE_ITEM_FROM_CART = 'GoMandiMobileAPI/RemoveFromCart?';
  static String DELETE_ITEM_FROM_CART_SUBSCRIPTION =
      'GoMandiMobileAPI/RemoveFromSubscribeCart?';
  static String ADDRESS_LISTING = 'GoMandiMobileAPI/CustomerAddressList?';
  static String DELETE_ADDRESS = 'GoMandiMobileAPI/DeleteCustomerAddress?';
  static String USER_DEFAULT_ADDRESS =
      'GoMandiMobileAPI/IsDefualtCustomerAddress?';
  static String ADD_ADDRESS = 'GoMandiMobileAPI/InsertCustomerAddress';
  static String InsertFeedBack = 'GoMandiMobileAPI/InsertFeedBack';
  static String APPLY_ORDER = 'GoMandiMobileAPI/InsertOrder?';
  static String DELETE_SHOPING_CART_ITEM = 'GoMandiMobileAPI/CartDelete?';
  static String MY_ORDER_DETAIL_DATA = 'GoMandiMobileAPI/GetOrderList?';
  static String CANCEL_ORDER = 'GoMandiMobileAPI/CancelOrder?';
  static String ONLINE_PAYMENT = 'GoMandiMobileAPI/GetPaymentRazorPayOnline?';
  static String E_CASH_HISTORY = 'GoMandiMobileAPI/GetEcashUserList?';
  static String E_WALLET_HISTORY = 'GoMandiMobileAPI/GetEwalletUserList?';
  static String GET_QTY_COUNT = 'GoMandiMobileAPI/GetCartSumOfQty?';
  static String GET_PRODUCT_UNIT = 'Product/GetChildProductList?';
  static String RECHARGE_PLAN = 'GoMandiMobileAPI/GetRechargePlanList';
  static String RECHARGE_FOR_PAYMENT =
      'GoMandiMobileAPI/GetUserRechargeWithPaymentGateway?';
  static String REFFARAL_HISTORY = 'GoMandiMobileAPI/GetChildMemberList?';
  static String SMART_RETAILER = 'GoMandiMobileAPI/GetReferralOrderList?';
  static String SUBMIT_ORDER_STATUS = 'GoMandiMobileAPI/OrderUpdateStatus?';
  static String RECHARGE_AMOUNT =
      'MasterSettingValues/GetMasterSettingListWithSettingKey?SettingKey=EwalletAmountStatic';
  static String FEEBACK_QUERY_LIST =
      'MasterSettingValues/GetMasterSettingListWithSettingKey?SettingKey=FeedBack';
  static String RECHARGE_WITH_AMOUNT =
      'GoMandiMobileAPI/GetUserRechargeWithPaymentGatewayRecharge?';
  static String NOTIFICATION_LIST = 'GoMandiMobileAPI/GetAllNotificationList';
  static String CHANGE_PASSWORD = 'Auth/ChangePassword?';
  static String EDIT_PROFILE_PIC = 'GoMandiMobileAPI/UserPofileUpdate?';
  static String GET_USER_PIC = 'GoMandiMobileAPI/GetUserProfilePic?';
  static String GET_USER_DATA = 'Auth/UserDetailsById?';
  static String USER_UPDATE_DATA = 'Auth/UpdateUser?';
  static String GO_MANDI_LIST_MAP = 'GoMandiMobileAPI/GetAllMandiList';
  static String ADD_WISHLIST = 'GoMandiMobileAPI/AddToWishList?';
  static String GET_WISH_LIST_PRODUCTS = 'GoMandiMobileAPI/GetWishListByUser?';
  static String GET_SUBSCRIPTION_BANNER =
      'GoMandiMobileAPI/GetSubscribeBannerImageList';
  static String GET_SCRIPTION_PRODUCT_LIST =
      'GoMandiMobileAPI/GetSubscribePlanWiseProductList?';
  static String SUBSCRIBE = 'GoMandiMobileAPI/PostSubscribeProductUserMapping?';
  static String GET_SCRIPTION_PRODUCT_LIST_PAY =
      'GoMandiMobileAPI/GetSubscribeWithPaymentGateway?';
  static String GET_MY_SUBSCRIPTION =
      'GoMandiMobileAPI/GetSubscribePlanUserBuyList?';
  static String UPDATE_SUBSCRIPTON_ADDRESS_UPDATE =
      'GoMandiMobileAPI/UpdateShippingAddress?';
  static String CHIPS_DATA = 'GoMandiMobileAPI/GetPickScheduleList';
  static String SUBSCRIBE_PRODUCT = 'GoMandiMobileAPI/PostSubscribeOrder?a=a';
  static String SUBSCRIBE_PRODUCT_UPDATE =
      'GoMandiMobileAPI/ModifySubscribeOrder?b=b';
  static String GET_FF_SUBSCRIPTION =
      'GoMandiMobileAPI/GetSubscribeUserOrderList?';
  static String GET_FF_SUBSCRIPTION_DELETE =
      'GoMandiMobileAPI/SubscriptionOrderDelete?';
  static String GET_FF_SUBSCRIPTION_PAUSE =
      'GoMandiMobileAPI/SubscriptionOrderPause?';
  static String GET_OFFER_LIST = 'GoMandiMobileAPI/GetOfferProductList';
  static String GET_DELIVERY_TIME_SLOT =
      'GoMandiMobileAPI/GetOrderTimeSlotList';
  static String GET_ITEM_DELETE_FROM_ORDER =
      'GoMandiMobileAPI/DeleteItemWiseOrder?';
  static String GET_TICKET_LIST = 'GoMandiMobileAPI/TicketList?';
  static String CHAT_LIST = 'GoMandiMobileAPI/GetChatDetailList?';
  static String INSER_MESSAGE = 'GoMandiMobileAPI/PostTicketReply?';
  // static String = '';
  // static String = '';
  // static String = '';
  // static String = '';
  // static String = '';
  // static String = '';
  // static String = '';
}
