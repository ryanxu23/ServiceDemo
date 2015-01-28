//
//  ESTNotificationDemoVC.m
//  Examples
//
//  Created by Grzegorz Krukiewicz-Gacek on 18.03.2014.
//  Copyright (c) 2014 Estimote. All rights reserved.
//

#import "ESTNotificationDemoVC.h"
#import "ESTBeaconManager.h"
#import "ESTBeaconTableVC.h"

@interface ESTNotificationDemoVC () <ESTBeaconManagerDelegate>


@property (nonatomic, strong) ESTBeacon         *beacon;
@property (nonatomic, strong) ESTBeaconManager  *beaconManager;
@property (nonatomic, strong) ESTBeaconRegion   *beaconRegion;
@property (nonatomic, strong) IBOutlet UIView            *mainView;

@end

@implementation ESTNotificationDemoVC

- (id)initWithBeacon:(ESTBeacon *)beacon
{
    self = [super init];
    if (self)
    {
        self.beacon = beacon;
    }
    
    NSString *beaconName = @"Not identified product";
    
    ESTBeaconTableVC *sClass = [[ESTBeaconTableVC alloc]init];
    beaconName = [sClass getBeaconName:self.beacon];
    currentProductName = beaconName;
    
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"Enter Notification");
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect frame = self.mainView.frame;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height;
    self.mainView.frame = frame;
    self.title = currentProductName;
    
    if ([currentProductName isEqualToString:[arrayName objectAtIndex:0]]){
        [self.imgProduct setImage:[UIImage imageNamed:@"canon_printer"]];
        [self.btnReorder setTitle:@"Reorder a Canon ink cartridge" forState:UIControlStateNormal];
    }else if([currentProductName isEqualToString:[arrayName objectAtIndex:1]]){
        [self.imgProduct setImage:[UIImage imageNamed:@"hp_printer"]];
        [self.btnReorder setTitle:@"Reorder a HP ink cartridge" forState:UIControlStateNormal];
    }else if([currentProductName isEqualToString:[arrayName objectAtIndex:2]]){
        [self.imgProduct setImage:[UIImage imageNamed:@"coffee_machine"]];
        [self.btnReorder setTitle:@"Reorder Espresso coffee capsules" forState:UIControlStateNormal];
    }else{
        
    }
    
    
    /*
     * Persmission to show Local Notification.
     */
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }

    /*
     * BeaconManager setup.
     */
    
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    self.beaconManager.avoidUnknownStateBeacons = YES;
    
    self.beaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:self.beacon.proximityUUID
                                                                 major:[self.beacon.major unsignedIntValue]
                                                                 minor:[self.beacon.minor unsignedIntValue]
                                                            identifier:@"RegionIdentifier"
                                                               secured:self.beacon.isSecured];
    
    [self.beaconManager startMonitoringForRegion:self.beaconRegion];
}

- (IBAction)buttonClick:(id)sender {
    self.lblStatus.text = @"Thanks. The reorder service will be conducted in 24 hours.";
}

#pragma mark - ESTBeaconManager delegate
// implemented alreayd in ESTBeaconTable VC.m
- (void)beaconManager:(ESTBeaconManager *)manager monitoringDidFailForRegion:(ESTBeaconRegion *)region withError:(NSError *)error
{
    UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:@"Monitoring error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [errorView show];
}

- (void)beaconManager:(ESTBeaconManager *)manager didEnterRegion:(ESTBeaconRegion *)region
{
    UILocalNotification *notification = [UILocalNotification new];
    notification.alertBody = @"Enter region notification";
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void)beaconManager:(ESTBeaconManager *)manager didExitRegion:(ESTBeaconRegion *)region
{
    UILocalNotification *notification = [UILocalNotification new];
    notification.alertBody = @"Exit region notification";
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

#pragma mark -

- (void)switchValueChanged
{
    [self.beaconManager stopMonitoringForRegion:self.beaconRegion];
    [self.beaconManager startMonitoringForRegion:self.beaconRegion];
}

@end
