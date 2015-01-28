//
//  main.m
//  Examples
//
//  Created by Grzegorz Krukiewicz-Gacek on 17.03.2014.
//  Copyright (c) 2014 Estimote. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ESTAppDelegate.h"

// global variable definition
NSString *currentProductName;
NSMutableArray * arrayName;

int main(int argc, char * argv[])
{
    arrayName = [[NSMutableArray alloc] initWithObjects: @"Canon Printer", @"HP Printer", @"Nespresso Coffee Machine",nil];

    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([ESTAppDelegate class]));
    }
}
