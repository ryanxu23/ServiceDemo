//
//  ESTNotificationDemoVC.h
//  Examples
//
//  Created by Grzegorz Krukiewicz-Gacek on 18.03.2014.
//  Copyright (c) 2014 Estimote. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESTBeacon.h"

extern NSString *currentProductName;
extern NSMutableArray * arrayName;

@interface ESTNotificationDemoVC : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *imgProduct;
@property (strong, nonatomic) IBOutlet UIButton *btnReorder;
@property (strong, nonatomic) IBOutlet UILabel *lblStatus;

- (id)initWithBeacon:(ESTBeacon *)beacon;

@end
