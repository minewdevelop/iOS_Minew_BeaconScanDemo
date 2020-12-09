//
//  Manager.h
//  MinewBeaconDemo
//
//  Created by SACRELEE on 19/09/2016.
//  Copyright © 2016 Yunliwuli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MinewBeaconScan/MinewBeaconScan.h>


@interface Manager : NSObject<MinewBeaconManagerDelegate>

+(Manager *)sharedInstance;

- (void)scan;

@end
