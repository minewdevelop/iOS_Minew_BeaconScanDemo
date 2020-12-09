//
//  TableViewController.m
//  YlwlBeaconDemo
//
//  Created by SACRELEE on 16/8/25.
//  Copyright © 2016年 com.YLWL. All rights reserved.
//

#import "TableViewController.h"
#import <MinewBeaconScan/MinewBeaconScan.h>


#define uuid1 @"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"
#define uuid2 @"AB8190D5-D11E-4941-ACC4-42F30510B408"
#define uuid3 @"00000000-0000-0000-0000-000000000000"

@interface TableViewController () <MinewBeaconManagerDelegate>

@end

@implementation TableViewController
{
    NSArray *_scannedDevice;
    MinewBeaconManager *_dm;
}

- (void)viewDidLoad
{
//     Manager *m = [Manager sharedInstance];
//    
//     [m scan];
}

- (void)viewDidAppear:(BOOL)animated
{
   
    [super viewDidAppear:animated];
    
    _dm = [MinewBeaconManager sharedInstance];
    _dm.delegate = self;
    [_dm startScan:@[ uuid1, uuid2, uuid3] backgroundSupport:NO];

    
    BluetoothState bs = [_dm checkBluetoothState];
    
    if ( bs == BluetoothStatePowerOn)
    {
        NSLog(@"The bluetooth state is power on, start scan now.");
        [_dm startScan:@[ uuid1, uuid2, uuid3] backgroundSupport:NO];
    }
    else
        NSLog(@"The bluetooth state isn't power on, we can't start scan.");

}

-(void)viewWillAppear:(BOOL)animated
{
    
}

- (IBAction)startScan:(id)sender
{
    _dm.delegate = self;
    
    // open backgroundSupport will reduce the battery life.
    [_dm startScan:@[uuid3] backgroundSupport:NO];
}

- (IBAction)stopScan:(id)sender
{
    [[MinewBeaconManager sharedInstance] stopScan];
    _scannedDevice = nil;
    [self.tableView reloadData];
}

#pragma mark *****************************TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _scannedDevice.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifer = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifer];
    }
    
#pragma mark **********************************Device's detail
    
    MinewBeacon *device = _scannedDevice[indexPath.row];
    cell.textLabel.text = [device getBeaconValue:BeaconValueIndex_Name].stringValue? [device getBeaconValue:BeaconValueIndex_Name].stringValue: @"N/A";
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"UUID:%@\nMajor:%ld, Minor:%ld RSSI:%ld Battery:%ld \nTemp:%.2f, Humi:%.2f, Mac:%@, \nTxpower:%ld, inRage:%@, \nConnectable:%@",[device getBeaconValue:BeaconValueIndex_UUID].stringValue, (long)[device getBeaconValue:BeaconValueIndex_Major].intValue, (long)[device getBeaconValue:BeaconValueIndex_Minor].intValue, (long)[device getBeaconValue:BeaconValueIndex_RSSI].intValue, (long)[device getBeaconValue:BeaconValueIndex_BatteryLevel].intValue,  [device getBeaconValue:BeaconValueIndex_Temperature].floatValue, [device getBeaconValue:BeaconValueIndex_Humidity].floatValue, [device getBeaconValue:BeaconValueIndex_Mac].stringValue, [device getBeaconValue:BeaconValueIndex_TxPower].intValue, [device getBeaconValue:BeaconValueIndex_InRage].boolValue? @"YES":@"NO", [device getBeaconValue:BeaconValueIndex_Connectable].boolValue? @"YES": @"NO"];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.f;
}

#pragma mark **********************************Device Manager Delegate
- (void)minewBeaconManager:(MinewBeaconManager *)manager didRangeBeacons:(NSArray<MinewBeacon *> *)beacons
{
    
    @synchronized (self)
    {
        _scannedDevice = [beacons copy];
        
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
        {
            [self pushNotification:[NSString stringWithFormat:@"Devices:%lu",(unsigned long)_scannedDevice.count]];
        }
        else
        {
            dispatch_async( dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }
}

- (void)minewBeaconManager:(MinewBeaconManager *)manager appearBeacons:(NSArray<MinewBeacon *> *)beacons
{
    NSLog(@"===appear beacons:%@", beacons);
}

- (void)minewBeaconManager:(MinewBeaconManager *)manager disappearBeacons:(NSArray<MinewBeacon *> *)beacons
{
    NSLog(@"---disappear beacons:%@", beacons);
}


- (void)minewBeaconManager:(MinewBeaconManager *)manager didUpdateState:(BluetoothState)state
{
    NSLog(@"++++Bluetooth state:%ld", (long)state);
    
    if ( state != BluetoothStatePowerOn)
        [self showAlert:state == BluetoothStatePowerOff? 1: 0];
}


- (void)pushNotification:(NSString *)notString
{
    
    UILocalNotification *unf = [[UILocalNotification alloc]init];
    unf.alertBody = notString;
    [[UIApplication sharedApplication] presentLocalNotificationNow:unf];
}

- (void)showAlert:(NSInteger)type
{

    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Error" message:type? @"Bluetooth is power off": @"Bluetooth status Error！" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    
    [ac addAction:aa];
    [self presentViewController:ac animated:YES completion:nil];

}


@end
