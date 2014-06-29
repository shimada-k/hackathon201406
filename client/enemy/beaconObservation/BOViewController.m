//
//  BOViewController.m
//  beaconObservation
//
//  Created by 島田克弥 on 2014/06/28.
//  Copyright (c) 2014年 shimada-k. All rights reserved.
//

#import "BOViewController.h"
#import "BeaconCentralUtil.h"

@interface BOViewController ()<BeaconCentralUtilDelegate>{
    BeaconCentralUtil* beaconCentralUtil;
}
@property (weak, nonatomic) IBOutlet UILabel *minorno;
@property (weak, nonatomic) IBOutlet UILabel *majorno;
@end

@implementation BOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *proximityUUID = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";
    NSString *identifier = @"msurvivor";
    //NSNumber *major = nil;
    //NSNumber *minor = nil;
    NSNumber *major = [NSNumber numberWithInt:0x0002];
    NSNumber *minor = [NSNumber numberWithInt:0x0008];
    
    beaconCentralUtil = [[BeaconCentralUtil alloc] initialize:self proximityUUID:proximityUUID identifier:identifier major:major minor:minor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BeaconCentralUtilDelegate

// 検知エリアに入った時に呼び出される
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    NSLog(@"%@", @"enter");
    NSLog(@"didStartMonitoringForRegion:%@", region.identifier);
    
    self.title = region.identifier;
}

// 検知エリアから出たときに呼び出される
-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    NSLog(@"%@", @"exit");
}

// 検知エリアにいる場合に呼び出されるイベント
-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
    if(beacons.count == 0) return;
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    NSLog(@"%d", [region.major intValue]);
    NSLog(@"%d", [region.minor intValue]);
    
    NSString *majorno_str = [NSString stringWithFormat:@"%d",[region.major intValue]];
    NSString *minorno_str = [NSString stringWithFormat:@"%d",[region.minor intValue]];
    
    self.majorno.text = majorno_str;
    self.minorno.text = minorno_str;
    
    CLBeacon *beacon = beacons.firstObject;
    
    NSLog(@"%@", [BeaconCentralUtil proximityToString:beacon.proximity]);
    
    NSString *url_str = [NSString stringWithFormat:@"http://tkoal.dip.jp:3000/encount?proximity=%@",[BeaconCentralUtil proximityToString:beacon.proximity]];
    
    NSLog(@"url:%@", url_str);
    
    // 送信したいURLを作成し、Requestを作成
    NSURL *url = [NSURL URLWithString:url_str];
    NSURLRequest  *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLConnection *aConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    // 作成に失敗する場合には、リクエストが送信されないのでチェックする
    if (!aConnection) {
        NSLog(@"connection error.");
    }
}

@end
