//
//  SettingManager.m
//  dsdict
//
//  Created by Jinde Wang on 15/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingManager.h"

@implementation SettingManager 

- (id)initWithPListFile:(NSString*)ipPListFileName {
    self = [super init];
    if (self) {
        if (ipPListFileName != nil) {
            @autoreleasepool {
                NSArray* lpPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString* lpDocumentDirectory = [lpPaths objectAtIndex:0];
                NSString* lpFinalPath = [lpDocumentDirectory stringByAppendingPathComponent:ipPListFileName];

                mpPListPath = lpFinalPath;
                mpSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:lpFinalPath];
                if (mpSettings == nil) {
                    mpSettings = [[NSMutableDictionary alloc] initWithCapacity:0];
                }
            }
            
        }
    }
    
    return self;
}

- (void)setSetting:(NSString*)mpValue forKey:(NSString*)mpKey {
    if (mpSettings != nil && mpPListPath != nil && mpValue != nil && mpKey != nil) {
        [mpSettings setObject:mpValue forKey:mpKey];
        [mpSettings writeToFile:mpPListPath atomically:YES];
    }
}

- (NSString*)getSetting:(NSString*)mpKey {
    if (mpSettings != nil && mpKey != nil) {
        return [mpSettings objectForKey:mpKey];
    }
    return nil;
}


@end
