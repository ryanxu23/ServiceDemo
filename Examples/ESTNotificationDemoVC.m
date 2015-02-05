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
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSMutableDictionary *dict_reorder;

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
    
    // check button status
    [self issueHTTPRequest:@"http://129.132.42.250/~xu/serviceDemo/notification.php"];
    
    
    //NSLog(@"Enter Notification");
    
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
        [self.btnReorder setTitle:@"Reorder Nespresso coffee capsules" forState:UIControlStateNormal];
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
    NSString *pname = [currentProductName stringByReplacingOccurrencesOfString:@" "
                                                    withString:@"%20"];
    
    NSString *url = [NSString stringWithFormat:@"http://129.132.42.250/~xu/serviceDemo/update.php?pname=%@", pname];
    NSLog(@"=== %@", url);
    
    [self issueHTTPRequest:url];
    
    [self.btnReorder setEnabled:NO];
    self.btnReorder.hidden = YES;
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
    /*
    UILocalNotification *notification = [UILocalNotification new];
    notification.alertBody = @"Enter region notification";
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    */
}

- (void)beaconManager:(ESTBeaconManager *)manager didExitRegion:(ESTBeaconRegion *)region
{
    /*
    UILocalNotification *notification = [UILocalNotification new];
    notification.alertBody = @"Exit region notification";
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    */ 
}

#pragma mark -

- (void)switchValueChanged
{
    [self.beaconManager stopMonitoringForRegion:self.beaconRegion];
    [self.beaconManager startMonitoringForRegion:self.beaconRegion];
}



- (void)issueHTTPRequest: (NSString *)callURL{
    // start with HTTP request
    self.responseData = [[NSMutableData alloc] init];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:callURL]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(!connection){
        NSLog(@"Connection Failed");
    }
    // end with HTTP request
}

// implemented HTTP request methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //NSLog(@"didReceiveResponse");
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
    //NSString *someString = [NSString stringWithFormat:@"%@", data];
    //NSLog(@"== didReceiveData: %@",someString);
    //NSLog(@"didReceiveData of %d bytes",[self.responseData length]);
    //NSLog(@"responseData length: %d bytes",[self.responseData length]);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog([NSString stringWithFormat:@"Connection failed: %@", [error description]]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //NSLog(@"connectionDidFinishLoading");
    //NSLog(@"Succeeded! Received %d bytes of data",[self.responseData length]);
    
    if ([self.responseData length] != 0){
        // convert to JSON
        NSError *myError = nil;
        NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
        
        NSArray *resArr = [res objectForKey:@"basic"];
        
        //NSLog(@"num: %d", [resArr count]);
        // show all values
        self.dict_reorder =[[NSMutableDictionary alloc] init];
        NSString *pName = [[NSString alloc] init];
        
        for(int i=0; i<[resArr count]; i++){
            for(id key in resArr[i]) {
            
                id value = [resArr[i] objectForKey:key];
            
                NSString *keyAsString = (NSString *)key;
                NSString *valueAsString = (NSString *)value;
            
                //NSLog(@"key: %@", keyAsString);
                //NSLog(@"value: %@", valueAsString);
                
                // add the entry into dict_reorder
                if ([keyAsString isEqualToString:@"product_name"]) {
                    pName = valueAsString;
                }else if ([keyAsString isEqualToString:@"reorder"]){
                    if ([self.dict_reorder objectForKey:pName]) {
                        //NSLog(@"key exists already");
                    }else{
                        //NSLog(@"key not exists yet");
                        [self.dict_reorder setObject:valueAsString forKey:pName];
                        pName = @"";
                    }
                }
                
                
            }
        }
    
        //check dict_reorder
        for(id key in self.dict_reorder){
            id value = [self.dict_reorder objectForKey:key];
            NSString *keyAS = (NSString *)key;
            NSString *valueAS = (NSString *)value;
            
            NSLog(@"Status: %@ - %@", keyAS, valueAS);
        }
        
        //set button status
        if ([[self.dict_reorder objectForKey:currentProductName] isEqualToString:@"1"]) {
            //reorder=1, disable button click
            [self.btnReorder setEnabled:NO];
            self.btnReorder.hidden = YES;
            self.lblStatus.text = @"Thanks. The reorder service will be conducted in 24 hours.";
        }else{
            //do nothing
        }
        
        // extract specific value...
        NSArray *results = [res objectForKey:@"results"];
        
        for (NSDictionary *result in results) {
            NSString *icon = [result objectForKey:@"icon"];
            NSLog(@"icon: %@", icon);
        }
        
    }else{
        // do nothing
    }
    
}

@end
