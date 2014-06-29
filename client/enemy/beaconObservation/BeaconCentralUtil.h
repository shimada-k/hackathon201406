//
//  BeaconCentralUtil.h
//  BeaconLettuce
//
//  Created by 古川 信行 on 2014/06/01.
//  Copyright (c) 2014年 古川 信行. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

//デリゲート
@protocol BeaconCentralUtilDelegate
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region;
-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region;
-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region;
@end

@interface BeaconCentralUtil : NSObject

//初期化
-(id)initialize:(id<BeaconCentralUtilDelegate>)delegate proximityUUID:(NSString*)proximityUUID identifier:(NSString*)identifier;

//初期化
-(id)initialize:(id<BeaconCentralUtilDelegate>)delegate proximityUUID:(NSString*)proximityUUID identifier:(NSString*)identifier major:(NSNumber*)major minor:(NSNumber*)minor;

//停止
-(void) stop;

//相対距離の情報文字列に変換
+(NSString*) proximityToString:(CLProximity)proximity;

//制度情報を文字列に変換
+(NSString*) accuracyToString:(CLLocationAccuracy)accuracy;

+(NSDictionary*) beaconToNSDictionary:(CLBeacon*)beacon;
+(NSDictionary*) regionToNSDictionary:(CLBeaconRegion *)region;


@end
