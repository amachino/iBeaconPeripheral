//
//  AMRootViewController.m
//  iBeaconPeripheral
//
//  Created by Akinori Machino on 2014/02/19.
//  Copyright (c) 2014年 Akinori Machino. All rights reserved.
//

#import "AMRootViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

static NSString * const kUUID = @"CD789C1A-D6E2-40C6-A255-ADD1E3AE8207";
static NSString * const kIdentifier = @"com.akinori-machino.iBeaconSample";

@implementation AMRootViewController
{
    NSUUID *_proximityUUID;
    CBPeripheralManager *_peripheralManager;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _proximityUUID = [[NSUUID alloc] initWithUUIDString:kUUID];
        
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
        if (_peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
            [self startAdvertising];
        }
    }
    return self;
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (error) {
        [self sendLocalNotificationForMessage:[NSString stringWithFormat:@"%@", error]];
    } else {
        [self sendLocalNotificationForMessage:@"Start Advertising"];
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSString *message;
    
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOff:
            message = @"PoweredOff";
            break;
        case CBPeripheralManagerStatePoweredOn:
            message = @"PoweredOn";
            [self startAdvertising];
            break;
        case CBPeripheralManagerStateResetting:
            message = @"Resetting";
            break;
        case CBPeripheralManagerStateUnauthorized:
            message = @"Unauthorized";
            break;
        case CBPeripheralManagerStateUnknown:
            message = @"Unknown";
            break;
        case CBPeripheralManagerStateUnsupported:
            message = @"Unsupported";
            break;
            
        default:
            break;
    }
    
    [self sendLocalNotificationForMessage:[@"PeripheralManager did update state: " stringByAppendingString:message]];
}

#pragma mark - Private methods

- (void)startAdvertising
{
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:_proximityUUID
                                                                           major:0
                                                                           minor:0
                                                                      identifier:kIdentifier];
    NSDictionary *beaconPeripheralData = [beaconRegion peripheralDataWithMeasuredPower:nil];
    [_peripheralManager startAdvertising:beaconPeripheralData];
}

- (void)sendLocalNotificationForMessage:(NSString *)message
{
    NSLog(@"%@", message);
    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.alertBody = message;
    localNotification.fireDate = [NSDate date];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


@end
