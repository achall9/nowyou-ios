//
//  PostViewController.swift
//  NowYou
//
//  Created by Apple on 12/27/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

let backButtonWithArrow = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)

let APP_COLOR = "app_color"
class API {
    static let URL_SCHEME               = "https"
    static let HOST                     = "https://staging-nowyou.herokuapp.com"
    static let SERVER                   = "https://staging-nowyou.herokuapp.com/api"
//    static let HOST                     = "http://nowyou.toplev.com"
//    static let SERVER                   = "http://nowyou.toplev.io/api"

//    static let SERVER_ADDR              = "http://192.168.1.194/bucketapp.com/"
//    static let HOST                     = "foodspecials.us"
//    static let SERVER                   = "http://foodspecials.us/api"

    static let SERVER_ADDR              = "http://192.168.1.194/bucketapp.com/"
    // know if email/phone is duplicate or not
    static let IS_EMAIL_PHONE_DUPLICATE = "/is_email_phone_duplicate"
    // auth
    static let REGISTER                 = "/auth/register"
    static let LOGIN                    = "/auth/login"
    static let PASSWORD_RESET           = "/auth/requestPasswordReset"
    static let ACTIVATE                 = "/auth/activate"
    static let RESET_PWD                = "/auth/resetPassword"
    static let GET_ADDITIONAL_ACCOUNTS  = "/get_additional_accounts"
   static let CREATE_ADDITIONAL_ACCOUNT = "/create_additional_account"
    // profile
    static let CHANGE_PWD               = "/profile/changePassword"
    static let USER_DETAILS             = "/profile/userDetails"
    static let PROFILE_UPDATE           = "/profile/update"
    static let GET_POSTS                = "/profile/posts"
    static let REMOVE_POSTS             = "/profile/removePost"
    
    // user
    static let USER_SEARCH              = "/user/search"
    static let USER_FOLLOW              = "/user/follow"
    static let USER_UNFOLLOW            = "/user/unfollow"
    static let USER_FOLLOWERS           = "/user/followers"
    static let USER_FOLLOWINGS          = "/user/followings"
    static let IS_FOLLOWING             = "/user/is_following"
    static let USER_DETAIL              = "/user/get_user_info"
    static let USER_MYINFO              = "/user/myinfo"
    static let DEVICE_TOKEN             = "/profile/updateToken"
    static let GET_NOTIFICATIONS        = "/user/notifications"
    static let GET_ALL_USER             = "/user/getallusers"
    static let FORGOT_PWD               = "/user/forgot_password"
    // feed
    static let SHARE_POST               = "/feed/share_post"
    
    
    static let POST_MEDIA               = "/feed/feed"
    static let GET_FEED                 = "/feed/popular_feeds"
    
    static let GET_FEED_DATA            = "/feed/feeds"
    static let GET_VIRAL_DATA           = "/feed/popular_feeds"
    static let GET_TAG_DATA             = "/feed/my_tagged_feeds"
    
    static let GET_FILTERED_FEEDS       = "/feed/filtered_feeds"
    static let GET_OTHER_FEEDS          = "/feed/otherFeeds"
    static let LIKE                     = "/feed/like"
    static let UNLIKE                   = "/feed/unlike"
    static let COMMENT                  = "/feed/comment"
    static let GET_COMMENT              = "/feed/get_comment"
    
    static let LOG_FEED_VIEW            = "/feed/logViewFeed"
    
    static let UPLOAD_VIDEO_TO_FEED     = "/feed/upload_video_to_feed"
    static let REPORT_A_POST            = "/feed/report"
    
    // radio
    static let GET_CATEGORIES           = "/category/categories"
    static let CREATE_CATEGORY          = "/category/create_category"
    static let GET_RADIO_BY_CATEGORY    = "/radio/radio_stations_by_category"
    static let CREATE_RADIO             = "/radio/create_radio"
    static let UPLOAD_AUDIO             = "/radio/upload_audio"
    static let LOG_RADIO_VIEW           = "/radio/log_radio_view"
    static let POST_RADIO_COMMENT       = "/radio/post_radio_comment"
    static let GET_RADIO_COMMENT        = "/radio/get_comments_with_radio"
    static let GET_TOP_100              = "/radio/get_top_100_radios"
    static let RADIO_SEARCH             = "/radio/search_radios"
    
    // radioStations....
    static let CREATE_NEW_RADIO_STATION = "/radio/create_radio_station"
    static let SERACH_RADIO_STATIONS    = "/radio/search_radio_stations"
    static let GET_RADIOS_BY_CATEGORY_ID = "/radio/radio_stations_by_category"
    static let LOG_RADIO_VIEWS          = "/radio/log_radio_view"
    static let GET_RADIO_VIEWS          = "/radio/get_radio_view"
    static let LOG_RADIO_STATION_VIEWS  = "/radio/log_radio_station_view"
    static let GET_RADIO_STATION_VIEWS  = "/radio/get_radio_station_view"
    static let GET_RADIO_STATION_INFO  = "/radio/radio_station"
    
    static let POPULAR_RADIO_STATION    = "/radio/popular_radio_stations"
    /////////
    static let STARTING_A_RADIO_RECORDIGN   = "/radio/radio_start"
    static let FINISHED_RECORDING           = "/radid/radio_finish"
    static let REQUEST_LISTEN               = "radio/request_listen"
    static let REJECT_LISTEN                = "radio/reject_listen"
    static let UPLOAD_RADIO_FILE            = "/radio/upload_audio"
    
    //-- related to AD: Start
    static let LOG_AD_VIEW                  = "/ad/log_ad_view"
    //-- get cash data
    static let myCashData                   = "/user/myinfo"
    
    //-- get payment email
    static let GET_PAYMENT_EMAIL            = "/user/payment_email"
    static let WITHDRAWED_INFO_FROM_APP     = "/user/withdrawed"
    
//---Stripe Start--//
    static let STRIPE_BASEURL = "https://api.stripe.com/v1"
//    #if DEVELOPMENT
    static let STRIPE_PUBLISH_KEY = "pk_test_Ggw24Zp9LLUXPXg0Aj9NCdVl00luVj0k0w"
    static let STRIPE_SECRET_KEY = "sk_test_5J5Psy2fxVl4KgXoNOUYE0EZ00F4jFHMkO"
//    #else
//    static let STRIPE_PUBLISH_KEY = "pk_test_Ggw24Zp9LLUXPXg0Aj9NCdVl00luVj0k0w"
//    static let STRIPE_SECRET_KEY = "sk_test_5J5Psy2fxVl4KgXoNOUYE0EZ00F4jFHMkO"
//    #endif
    
    //--Create an account and retrieve
    static let STRIPE_CREATE_ACCOUNT   = "/accounts"
    //--Create bank account and card
    static let STRIPE_CREATE_CUSTOMRER = "/customers"
    
    static let UPDATE_USER_PAYMENT_EMAIL = "/user/update_payment_email"
    
//---Block User Start--//
    static let BLOCK_USER = "/user/block"
    static let UNBLOCK_USER = "/user/unblock"
    static let GET_BLOCKER_LIST = "/user/blockers"
    
//---Delete User Start--//
    static let DELETE_USER = "/user/delete"
//--HashTag
    static let FOLLOW_HASHTAG = "/feed/hashtag/follow"
    static let UNFOLLOW_HASHTAG = "/feed/hashtag/unfollow"
    static let GET_FOLLOWING_HASHTAGS = "/feed/hashtag/followings"
    static let GET_ALL_HASHTAGS = "/feed/hashtags"
}

class USER {
    static let ID                       = "id"
    static let MAIN_USER_ID             = "main_user_id"
    static let FIRST_NAME               = "first_name"
    static let LAST_NAME                = "last_name"
    static let EMAIL                    = "email"
    static let PHONE                    = "phone"
    static let USER_NAME                = "user_name"
    static let PHOTO                    = "photo"
    static let BIRTHDAY                 = "birthday"
    static let FULL_NAME                = "full_name"
    static let PRIVATE_ON               = "privateOn"
    static let BIO                      = "bio"
    static let TOKEN                    = "token"
    
    static let TOTAL_AMOUNT             = "total_amount"
    
    static let FOLLOWERS_COUNT          = "followers_count"
    static let FOLLOWINGS_COUNT         = "followings_count"
    static let THIS_WEEK_FOllOWERS      = "this_week_followers"
    static let POSTS                    = "posts"
    static let POSTS_COUNT              = "posts_count"
    static let POSTS_IMAGE_COUNT        = "posts_image_count"
    static let POSTS_VIDEO_COUNT        = "posts_Video_count"
    static let VIEW_COUNT_TOTAL         = "view_count_total"
    static let VIEW_COUNT_DAILY         = "view_count_daily"
    static let VIEW_COUNT_WEEKLY         = "view_count_weekly"
    static let VIEW_COUNT_MONTHLY       = "view_count_monthly"
    static let VIEW_COUNT_YEARLY        = "view_count_yearly"
    static let EARNING_TOTAL            = "cash_total"
    static let EARNING_DAILY            = "cash_daily"
    static let EARNING_MONTHLY          = "cash_monthly"
    static let EARNING_YEARLY           = "cash_yearly"
    static let EARNING_WEEKLY           = "cash_weekly"
    static let WITHDRAWNS_TOTAL         = "withdraws_total"
    static let COLOR                    = "color"
    static let GENDER                   = "gender"
    static let DEVICE_TOKEN             = "device_token"
    static let MONTHLY                  = "monthly_history"
    static let DAILY                    = "daily_history"
    static let TIMELY                   = "timely_history"
}

class MEDIA {
    static let ID                       = "id"
    static let SHARED_PARENT_ID         = "shared_parent_id"
    static let ORIGINAL_USER_ID         = "original_user_id"
    static let USER_ID                  = "user_id"
    static let TYPE                     = "type"
    static let PATH                     = "path"
    static let HASH_TAG                 = "hash_tag"
    static let DESCRIPTION              = "description"
    static let FOREVER                  = "forever"
    static let VIEWS                    = "views"
    static let CREATED_AT               = "created_at"
    static let THUMBNAIL                = "thumbnail"
    static let LIKED                    = "liked"
    static let LINK                     = "link"
    
    static let LINK_X                   = "x"
    static let LINK_Y                   = "y"
    static let LINK_W                   = "width"
    static let LINK_H                   = "height"
    
    static let LINK_ANGLE               = "angle"
    
    static let LINK_SCREEN_W            = "screen_w"
    static let LINK_SCREEN_H            = "screen_h"
}

class COMMENT {
    static let ID                       = "id"
    static let FEED_ID                  = "feed_id"
    static let USER_ID                  = "user_id"
    static let USER                     = "user"
    static let COMMENT                  = "message"
    static let CREATED_AT               = "created_at"
}
class NOTIFICATION {
    static let NEW_MEDIA_POSTED         = "new_media_posted"
    static let SEARCH_PEOPLE_RESULT_UPDATED     = "search_people_updated"
    static let SEARCH_TAG_RESULT_UPDATED        = "search_tag_updated"
    static let USER_INFO_UPDATED        = "user_info_updated"
    static let USER_PHOTO_UPDATED        = "user_photo_updated"
    static let USER_POSTS_LOADED        = "user_posts_loaded"
    static let USER_STORY_VIEWED_UPDATED        = "user_story_viewed_updated"
    static let USER_FOLLOWING_COUNT_UPDATED        = "user_following_count_updated"
    
    static let RADIO_SEARCH_UPDATE        = "radio_search_update"
    
    static let APP_COLOR_UPDATED        = "app_color_updated"
    
    static let PLAY_SCREEN_OPENED       = "play_screen_opened"
}

class FBADS {
    static let NATIVE_PLACEMENT_ID = "310323296837472_310327110170424"
    static let BANNER_PLACEMENT_ID = "310323296837472_322663118936823"
}

let WRONG_PHONE_NUMBER       = "Please enter valid phone number."
let WRONG_BIRTH              = "Please choose your birthday."
let WRONG_EMAIL              = "Please provide a valid email."
let WRONG_INFO               = "Please provide a valid username or email."
let WRONG_USERNAME           = "Please provide a valid username."
let NO_PASSWORD              = "Please enter your password."
let NO_FIRSTNAME             = "Please enter your first name."
let NO_LASTNAME              = "Please enter your last name."
let WRONG_PHONE_VERIFY_CODE  = "Please enter valide phone verification code"
let USER_INFO                = "user_info"
let CASH_INFO                = "cash_info"

let PLACEHOLDER_IMG          = UIImage(named: "NY_default_avatar")
let PLACEHOLDER_VIDEO        = UIImage(named: "placeholder")
let PLACEHOLDER_PHOTO        = UIImage(named: "placeholder")

let PLAY_IMG                = UIImage(named: "NY_post_send")
let PAUSE_IMG               = UIImage(named: "NY_stream_pause")
let STOP_IMG                = UIImage(named: "NY_stop_stream")

let MICRO_ON                = UIImage(named: "microphone_on")
let MICRO_OFF               = UIImage(named: "microphone_off")

let CONTACT_SCREEN_SHOWN    = "contact_screen"
// notifications
let NEW_CATEGORY_ADDED      = "new_category_added_notification"
let NEW_CATEGORY_ADDED2     = "new_category_added_notification2"
let NEW_RADIO_STATION_ADDED = "new_radio_station_added_notification"
let NEW_AUDIO_ADDED         = "new_audio_added_notification"
