//
//  User.m
//  TimeTracker
//
//  Created by Tim Studt on 29/04/15.
//  Copyright (c) 2015 Tim Studt. All rights reserved.
//

#import "User.h"

static NSString *const kUserLastUsedProjectKey = @"keyLastUsedProject";
@implementation User

+ (void)setLastUsedProject:(NSString *)lastUsedProject{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    // saving an NSString
    [prefs setObject:lastUsedProject forKey:kUserLastUsedProjectKey];
    [prefs synchronize];
    
}

+ (NSString *)lastUsedProject{
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    // getting an NSString
    return [prefs stringForKey:kUserLastUsedProjectKey];
    
}

@end
