//
//  PMStandKeyConstant.h
//  Passim
//
//  Created by Philip Zhao on 1/30/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#define PASSIM_NEWS_TITLE   @"news_title"
#define PASSIM_NEWS_SUMMARY @"news_summary"
#define PASSIM_NEWS_AUTHOR  @"news_uploader_screen_name"
#define PASSIM_USERNAME     @"news_uploader_user_name"
#define PASSIM_NEWS_ID      @"id"
#define PASSIM_LATITIUDE    @"news_geo_lat"
#define PASSIM_LONGTITUDE   @"news_geo_long"
#define PASSIM_CITY         @"news_city"
#define PASSIM_STATE        @"news_state"
#define PASSIM_COUNTRY      @"news_country"
#define PASSIM_DATE_TIME    @"news_date_time"
#define PASSIM_SCREEN_NAME  @"screen_name"
#define PASSIM_ERROR        @"error"
#define PASSIM_COMMENT      @"comment_content"
#define PASSIM_NEWS_ADDRESS @"news_short_address"
#define PASSIM_NEWS_PHOTO_URL   @"photo_url"
#define PASSIM_NEWS_PHOTO_UI @"UIImage_photo"
#define PASSIM_NUM_COMMENT  @"comment_amount"


#define POST_AUTHOR @"author_screen_name"
#define POST_ADDRESS @"address"
#define POST_LOCATION @"location"
#define POST_NEWS_ID @"news_id"
#define POST_PASSIM_PHOTO @"img_url"

#define NOTIFICATION_HIDE_BOTTOM_BAR @"hiden bottom bar"
#define NOTIFICATION_SHOW_BOTTOM_BAR @"show bottom bar"

#define PASSIM_DATE_TIME_FORMAT @"yyyy-MM-dd HH:mm:ss"
/**
 * Other constant across the VC
 */
enum PMComposeViewControllerResult {
  PMComposeViewControllerResultCancelled,
  PMComposeViewControllerResultDone,
  PMComposeViewControllerResultFailure
};
typedef enum PMComposeViewControllerResult PMComposeViewControllerResult;

enum _PMDateTimeAgo {
  PMSecondAgo,
  PMMinuteAgo,
  PMHourAgo,
  PMDayAgo,
  PMAccurateDate
};
typedef enum _PMDateTimeAgo PMDateTimeAgo;
