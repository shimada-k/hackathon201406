//
//  BeaconCentralUtil.m
//  BeaconLettuce
//
//  Created by 古川 信行 on 2014/06/01.
//  Copyright (c) 2014年 古川 信行. All rights reserved.
//

#import "BeaconCentralUtil.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface BeaconCentralUtil()<CLLocationManagerDelegate>{
    id<BeaconCentralUtilDelegate> _delegate;
    CLBeaconRegion *beaconRegion;
    CLLocationManager *locationManager;
    
    NSMutableDictionary* rangeBeacons;
}
@end

@implementation BeaconCentralUtil

//初期化
-(id)initialize:(id<BeaconCentralUtilDelegate>)delegate proximityUUID:(NSString*)proximityUUID identifier:(NSString*)identifier{
    return [self initialize:delegate proximityUUID:proximityUUID identifier:identifier major:nil minor:nil];
}

//初期化
-(id)initialize:(id<BeaconCentralUtilDelegate>)delegate proximityUUID:(NSString*)proximityUUID identifier:(NSString*)identifier major:(NSNumber*)major minor:(NSNumber*)minor{
    
    rangeBeacons = [NSMutableDictionary dictionary];
    
    //デリゲート設定
    _delegate = delegate;
    
    //Beacon検索
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:proximityUUID];
    if(major == nil){
        //major,minor 未指定
        beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:identifier];
    }
    else{
        //major,minor 指定
        beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                major:(CLBeaconMajorValue)[major unsignedShortValue]
                                                                minor:(CLBeaconMajorValue)[minor unsignedShortValue]
                                                           identifier:identifier];
    }
        
    beaconRegion.notifyOnEntry = YES;
    beaconRegion.notifyOnExit = YES;
    beaconRegion.notifyEntryStateOnDisplay = NO;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    //リージョン監視
    [locationManager startMonitoringForRegion:beaconRegion];
    
    return self;
}

//停止
-(void) stop{
    [locationManager stopRangingBeaconsInRegion:beaconRegion];
    [locationManager stopMonitoringForRegion:beaconRegion];
    locationManager.delegate = nil;
    locationManager = nil;
    beaconRegion = nil;
    rangeBeacons = nil;
}


//相対距離の情報文字列に変換
+(NSString*) proximityToString:(CLProximity)proximity{
    NSString* result = nil;
    
    switch (proximity) {
        case CLProximityUnknown:
            //不明 (Unknown)
            result = @"CLProximityUnknown";
            break;
        case CLProximityImmediate:
            //すぐ近く (Immediate)
            result = @"CLProximityImmediate";
            break;
        case CLProximityNear:
            //近く (Near)
            result = @"CLProximityNear";
            break;
        case CLProximityFar:
            //遠い (Far)
            result = @"CLProximityFar";
            break;
        default:
            break;
    }
    
    return result;
}

//制度情報を文字列に変換
+(NSString*) accuracyToString:(CLLocationAccuracy)accuracy{
    NSString* result = nil;
    
    if (accuracy == kCLLocationAccuracyBestForNavigation) {
        result = @"kCLLocationAccuracyBestForNavigation";
    }
    else if (accuracy == kCLLocationAccuracyBest) {
        result = @"kCLLocationAccuracyBest";
    }
    else if (accuracy == kCLLocationAccuracyNearestTenMeters) {
        result = @"kCLLocationAccuracyNearestTenMeters";
    }
    else if (accuracy == kCLLocationAccuracyHundredMeters) {
        result = @"kCLLocationAccuracyHundredMeters";
    }
    else if (accuracy == kCLLocationAccuracyKilometer) {
        result = @"kCLLocationAccuracyKilometer";
    }
    else if (accuracy == kCLLocationAccuracyThreeKilometers) {
        result = @"kCLLocationAccuracyThreeKilometers";
    }
    return result;
}

+(NSDictionary*) beaconToNSDictionary:(CLBeacon*) beacon {
    NSString *proximity = [BeaconCentralUtil proximityToString:beacon.proximity];
    NSString *accuracy  = [BeaconCentralUtil accuracyToString:beacon.accuracy];
    NSString *rssi = [NSString stringWithFormat:@"%ld",(long)beacon.rssi];
    
    return @{@"proximity":(proximity==nil)?@"":proximity,
             @"rssi":(rssi==nil)?@"":rssi,
             @"accuracy":(accuracy==nil)?@"":accuracy,
             @"proximityUUID":(beacon.proximityUUID.UUIDString == nil)?@"":beacon.proximityUUID.UUIDString,
             @"major":(beacon.major==nil)?@"":beacon.major,
             @"minor":(beacon.minor==nil)?@"":beacon.minor};
}

+(NSDictionary*) regionToNSDictionary:(CLBeaconRegion *)region{
    return @{@"proximityUUID":(region.proximityUUID.UUIDString==nil)?@"":region.proximityUUID.UUIDString,
             @"major":(region.major==nil)?@"":region.major,
             @"minor":(region.minor==nil)?@"":region.minor};
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region{
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    [locationManager requestStateForRegion:beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    switch (state) {
        case CLRegionStateInside:
            //リージョン内に居た場合
            if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
                //レンジング
                [locationManager startRangingBeaconsInRegion:beaconRegion];
            }
            break;
        case CLRegionStateOutside:
        case CLRegionStateUnknown:
        default:
            break;
    }
}

//リージョン監視 リージョンに入ってきた時
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    //デリゲートが設定されていたら転送
    if(_delegate != nil){
        [_delegate locationManager:manager didEnterRegion:region];
    }
    
    if([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

//リージョン監視 リージョンから出た時
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    //ビーコン一覧から削除
    NSString *key = [self createBeaconKey:(CLBeaconRegion *)region];
    [rangeBeacons removeObjectForKey:key];
    
    //デリゲートが設定されていたら転送
    if(_delegate != nil){
        [_delegate locationManager:manager didExitRegion:region];
    }
}

//ビーコン検出
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    //NSLog(@"[beacons count] %lu", (unsigned long)[beacons count]);
    
    //ビーコンを検出しなかった場合何も処理しない
    if([beacons count] == 0) return;

    //デリゲートが設定されていたら転送
    if(_delegate != nil){
        [_delegate locationManager:manager didRangeBeacons:beacons inRegion:region];
        return;
    }
    
    //デリゲートが設定されていたら以下は実行されない
    CLProximity proximity = CLProximityUnknown;
    CLLocationAccuracy locationAccuracy = 0.0;
    NSInteger rssi = 0;
    
    for(CLBeacon *b in beacons){
        proximity = b.proximity;
        locationAccuracy = b.accuracy;
        rssi = b.rssi;
    }

    NSLog(@"[proximity] %@",[BeaconCentralUtil proximityToString:proximity]);
    NSLog(@"[locationAccuracy] %f", locationAccuracy);
    NSLog(@"[rssi] %ld", (long)rssi);
}

//ビーコンを判断する為のキー値を生成
-(NSString*) createBeaconKey:(CLBeaconRegion*) region{
    return [NSString stringWithFormat:@"%@_%d_%d",region.proximityUUID.UUIDString,[region.major intValue],[region.minor intValue]];
}

@end
