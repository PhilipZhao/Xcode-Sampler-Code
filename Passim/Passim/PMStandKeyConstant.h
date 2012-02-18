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
#define PASSIM_NEWS_ID      @"id"
#define PASSIM_LATITIUDE    @"news_geo_lat"
#define PASSIM_LONGTITUDE   @"news_geo_long"
#define PASSIM_CITY         @"news_city"
#define PASSIM_STATE        @"news_state"
#define PASSIM_COUNTRY      @"news_country"
#define PASSIM_DATE_TIME    @"news_date_time"
#define PASSIM_USER_NAME    @"screen_name"
#define PASSIM_ERROR        @"error"
#define PASSIM_COMMENT      @"comment_content"

#define POST_AUTHOR @"author_screen_name"
#define POST_ADDRESS @"address"
#define POST_LOCATION @"location"
#define POST_NEWS_ID @"news_id"
/**
 * Other constant across the VC
 */
enum PMComposeViewControllerResult {
  PMComposeViewControllerResultCancelled,
  PMComposeViewControllerResultDone,
  PMComposeViewControllerResultFailure
};
typedef enum PMComposeViewControllerResult PMComposeViewControllerResult;
