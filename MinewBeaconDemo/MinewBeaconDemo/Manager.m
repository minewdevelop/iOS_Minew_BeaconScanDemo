//
//  Manager.m
//  MinewBeaconDemo
//
//  Created by SACRELEE on 19/09/2016.
//  Copyright © 2016 Yunliwuli. All rights reserved.
//

#import "Manager.h"

#define uuid1 @"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"
#define uuid2 @"AB8190D5-D11E-4941-ACC4-42F30510B408"

@implementation Manager
{
    MinewBeaconManager *_manager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _manager = [MinewBeaconManager sharedInstance];
        _manager.delegate = self;
    }
    return self;
}

+(Manager *)sharedInstance
{
    static Manager *m = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        m = [[Manager alloc]init];
    });
    
    return m;
}

- (void)scan
{
    [_manager startScan:@[uuid1, uuid2] backgroundSupport:NO];
}


- (void)minewBeaconManager:(MinewBeaconManager *)manager didRangeBeacons:(NSArray<MinewBeacon *> *)beacons
{
    NSLog(@"=======%lu devices", (unsigned long)beacons.count);
}





@end
