//
//  ESTBeaconTableVC.m
//  DistanceDemo
//
//  Created by Grzegorz Krukiewicz-Gacek on 17.03.2014.
//  Copyright (c) 2014 Estimote. All rights reserved.
//

#import "ESTBeaconTableVC.h"
#import "ESTBeaconManager.h"
#import "ESTViewController.h"
#import "ESTNotificationDemoVC.h"

@interface ESTBeaconTableVC () <ESTBeaconManagerDelegate>

@property (nonatomic, copy)     void (^completion)(ESTBeacon *);
@property (nonatomic, assign)   ESTScanType scanType;

@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) ESTBeaconManager *beaconManager1;
@property (nonatomic, strong) ESTBeaconManager *beaconManager2;
@property (nonatomic, strong) ESTBeaconManager *beaconManager3;
@property (nonatomic, strong) ESTBeaconRegion* firstBeaconRegion;
@property (nonatomic, strong) ESTBeaconRegion* secondBeaconRegion;
@property (nonatomic, strong) ESTBeaconRegion* thirdBeaconRegion;
@property (nonatomic, strong) ESTBeaconRegion *region;
@property (nonatomic, strong) NSArray *beaconsArray;

@end


@interface ESTTableViewCell : UITableViewCell


@end
@implementation ESTTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
    }
    return self;
}
@end

@implementation ESTBeaconTableVC

- (id)initWithScanType:(ESTScanType)scanType completion:(void (^)(ESTBeacon *))completion
{
    self = [super init];
    if (self)
    {
        self.scanType = scanType;
        self.completion = [completion copy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.title = @"Product Nearby";
    //NSLog(@"Enter Beacons");
    
    [self.tableView registerClass:[ESTTableViewCell class] forCellReuseIdentifier:@"CellIdentifier"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    self.beaconManager.returnAllRangedBeaconsAtOnce = YES;
    
    //self.beaconManager1 = [[ESTBeaconManager alloc] init];
    //self.beaconManager1.delegate = self;
    //self.beaconManager1.returnAllRangedBeaconsAtOnce = YES;
    
    //self.beaconManager2 = [[ESTBeaconManager alloc] init];
    //self.beaconManager2.delegate = self;
    //self.beaconManager2.returnAllRangedBeaconsAtOnce = YES;
    
    //self.beaconManager3 = [[ESTBeaconManager alloc] init];
    //self.beaconManager3.delegate = self;
    //self.beaconManager3.returnAllRangedBeaconsAtOnce = YES;
    
    /*
     * Creates sample region object (you can additionaly pass major / minor values).
     *
     * We specify it using only the ESTIMOTE_PROXIMITY_UUID because we want to discover all
     * hardware beacons with Estimote's proximty UUID.
     */
    
    self.region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                      identifier:@"EstimoteSampleRegion"];
    
    self.firstBeaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                                      major: 11232
                                                                      minor: 40232
                                                                 identifier:@"firstRegionIdentifier"];
    
    self.secondBeaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                                       major: 45858
                                                                       minor: 33559
                                                                  identifier:@"secondRegionIdentifier"];

    self.thirdBeaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                                       major: 39813
                                                                       minor: 29621
                                                                  identifier:@"thirdRegionIdentifier"];
    
    /*
     * Starts looking for Estimote beacons.
     * All callbacks will be delivered to beaconManager delegate.
     */
    if (self.scanType == ESTScanTypeBeacon)
    {
        [self startRangingBeacons];
    }
    else
    {
        [self.beaconManager startEstimoteBeaconsDiscoveryForRegion:self.region];
        //[self.beaconManager1 startEstimoteBeaconsDiscoveryForRegion:self.firstBeaconRegion];
        //[self.beaconManager2 startEstimoteBeaconsDiscoveryForRegion:self.secondBeaconRegion];
    }
    
    /*
     * Persmission to show Local Notification.
     */
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    // start registrating two beacons region
    
    //[self.beaconManager startMonitoringForRegion:self.region];
    [self.beaconManager startMonitoringForRegion:self.firstBeaconRegion];
    [self.beaconManager startMonitoringForRegion:self.secondBeaconRegion];
    //[self.beaconManager1 startMonitoringForRegion:self.firstBeaconRegion];
    //[self.beaconManager1 startMonitoringForRegion:self.secondBeaconRegion];
    //[self.beaconManager2 startMonitoringForRegion:self.secondBeaconRegion];
    //[self.beaconManager3 startMonitoringForRegion:self.thirdBeaconRegion];
    
}

- (void)beaconManager:(ESTBeaconManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (self.scanType == ESTScanTypeBeacon)
    {
        [self startRangingBeacons];
    }
}

-(void)startRangingBeacons
{
    if ([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
            /*
             * No need to explicitly request permission in iOS < 8, will happen automatically when starting ranging.
             */
            [self.beaconManager startRangingBeaconsInRegion:self.region];
            //[self.beaconManager1 startRangingBeaconsInRegion:self.firstBeaconRegion];
            //[self.beaconManager2 startRangingBeaconsInRegion:self.secondBeaconRegion];
            
        } else {
            /*
             * Request permission to use Location Services. (new in iOS 8)
             * We ask for "always" authorization so that the Notification Demo can benefit as well.
             * Also requires NSLocationAlwaysUsageDescription in Info.plist file.
             *
             * For more details about the new Location Services authorization model refer to:
             * https://community.estimote.com/hc/en-us/articles/203393036-Estimote-SDK-and-iOS-8-Location-Services
             */
            [self.beaconManager requestAlwaysAuthorization];
            //[self.beaconManager1 requestAlwaysAuthorization];
            //[self.beaconManager2 requestAlwaysAuthorization];
        }
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
    {
        [self.beaconManager startRangingBeaconsInRegion:self.region];
        //[self.beaconManager1 startRangingBeaconsInRegion:self.firstBeaconRegion];
        //[self.beaconManager2 startRangingBeaconsInRegion:self.secondBeaconRegion];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Access Denied"
                                                        message:@"You have denied access to location services. Change this in app settings."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        
        [alert show];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Not Available"
                                                        message:@"You have no access to location services."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        
        [alert show];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    /*
     *Stops ranging after exiting the view.
     */
    
    [self.beaconManager stopRangingBeaconsInRegion:self.region];
    [self.beaconManager stopEstimoteBeaconDiscovery];
    
    /*
    [self.beaconManager1 stopRangingBeaconsInRegion:self.firstBeaconRegion];
    [self.beaconManager1 stopEstimoteBeaconDiscovery];
    [self.beaconManager2 stopRangingBeaconsInRegion:self.secondBeaconRegion];
    [self.beaconManager2 stopEstimoteBeaconDiscovery];
     */
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ESTBeaconManager delegate

- (void)beaconManager:(ESTBeaconManager *)manager rangingBeaconsDidFailForRegion:(ESTBeaconRegion *)region withError:(NSError *)error
{
    UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:@"Ranging error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [errorView show];
}

- (void)beaconManager:(ESTBeaconManager *)manager monitoringDidFailForRegion:(ESTBeaconRegion *)region withError:(NSError *)error
{
    UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:@"Monitoring error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [errorView show];
}

- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    self.beaconsArray = beacons;
    [self.tableView reloadData];
}

- (void)beaconManager:(ESTBeaconManager *)manager didDiscoverBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    self.beaconsArray = beacons;
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.beaconsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ESTTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    /*
     * Fill the table with beacon data.
     */
    ESTBeacon *beacon = [self.beaconsArray objectAtIndex:indexPath.row];
    
    if (self.scanType == ESTScanTypeBeacon)
    {
        
        NSString *beaconName = @"Not identified product";
        
        beaconName = [self getBeaconName:beacon];
        
        
        //cell.textLabel.text = [NSString stringWithFormat:@"Major: %@, Minor: %@", beacon.major, beacon.minor];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", beaconName];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance: %.2f", [beacon.distance floatValue]];
        NSLog(@"-- major %@, minor %@, name %@", beacon.major, beacon.minor, beaconName);
    }
    else
    {
        cell.textLabel.text = [NSString stringWithFormat:@"Mac Address: %@", beacon.macAddress];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"RSSI: %d", beacon.rssi];
    }
    
    cell.imageView.image = beacon.isSecured ? [UIImage imageNamed:@"beacon_secure"] : [UIImage imageNamed:@"beacon"];
    
    // registrate notification service for each beacon
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 80;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ESTBeacon *selectedBeacon = [self.beaconsArray objectAtIndex:indexPath.row];
    //NSLog(@"Hello !");
    self.completion(selectedBeacon);
    
    ESTNotificationDemoVC *notificationDemoVC = [[ESTNotificationDemoVC alloc] initWithBeacon:selectedBeacon];
    [self.navigationController pushViewController:notificationDemoVC animated:YES];
    
}

// map a beacon's major and minor to its predefined product name
- (NSString*)getBeaconName: (ESTBeacon*)bc
{
    NSString *beaconName;
    //NSMutableArray * arrayName = [[NSMutableArray alloc] initWithObjects: @"Canon Printer", @"HP Printer", @"Nespresso Coffee Machine",nil];
    if(([bc.major isEqualToNumber:(NSNumber*)[NSNumber numberWithInt:29813]]) && ([bc.minor isEqualToNumber:(NSNumber*)[NSNumber numberWithInt:39621]])){
        beaconName = [arrayName objectAtIndex:0];
    }else if (([bc.major isEqualToNumber:(NSNumber*)[NSNumber numberWithInt:45858]]) && ([bc.minor isEqualToNumber:(NSNumber*)[NSNumber numberWithInt:33559]])){
        beaconName = [arrayName objectAtIndex:1];
    }else if (([bc.major isEqualToNumber:(NSNumber*)[NSNumber numberWithInt:11232]]) && ([bc.minor isEqualToNumber:(NSNumber*)[NSNumber numberWithInt:40232]])){
        beaconName = [arrayName objectAtIndex:2];
    }else{
        // do nothing now
    }
    return beaconName;
}

- (void)beaconManager:(ESTBeaconManager *)manager didEnterRegion:(ESTBeaconRegion *)region
{
    if ([region.identifier isEqualToString:@"firstRegionIdentifier"]) {
        UILocalNotification *notification = [UILocalNotification new];
        notification.alertBody = @"Reorder Espresso coffee capsules";
        notification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }else if ([region.identifier isEqualToString:@"secondRegionIdentifier"]) {
        UILocalNotification *notification = [UILocalNotification new];
        notification.alertBody = @"Reorder a HP ink cartridge";
        notification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }else if ([region.identifier isEqualToString:@"thirdRegionIdentifier"]) {
        UILocalNotification *notification = [UILocalNotification new];
        notification.alertBody = @"Reorder a Canon ink cartridge";
        notification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }else if ([region.identifier isEqualToString:@"EstimoteSampleRegion"]) {
        UILocalNotification *notification = [UILocalNotification new];
        notification.alertBody = @"In EstimoteSampleRegion";
        notification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }else{
        /*
        UILocalNotification *notification = [UILocalNotification new];
        notification.alertBody = region.identifier; //@"In Undefined Status";
        notification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
         */
    }
}

- (void)beaconManager:(ESTBeaconManager *)manager didExitRegion:(ESTBeaconRegion *)region
{
    if ([region.identifier isEqualToString:@"firstRegionIdentifier"]) {
        UILocalNotification *notification = [UILocalNotification new];
        notification.alertBody = @"Leave Espresso machine";
        notification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }else if ([region.identifier isEqualToString:@"secondRegionIdentifier"]) {
        UILocalNotification *notification = [UILocalNotification new];
        notification.alertBody = @"Leave HP printer";
        notification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }else if ([region.identifier isEqualToString:@"thirdRegionIdentifier"]) {
        UILocalNotification *notification = [UILocalNotification new];
        notification.alertBody = @"Leave Canon printer";
        notification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }else if ([region.identifier isEqualToString:@"EstimoteSampleRegion"]) {
        UILocalNotification *notification = [UILocalNotification new];
        notification.alertBody = @"Out EstimoteSampleRegion";
        notification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }else{
        /*
        UILocalNotification *notification = [UILocalNotification new];
        notification.alertBody = region.identifier; //@"Out Undefined Status";
        notification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
         */
    }
}

@end
