//
//  SettingManager.h
//  tcidsd
//
//  Created by Jinde Wang on 15/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingManager : NSObject {
    NSString* mpPListPath;
    
    NSMutableDictionary* mpSettings;
}

- (id)initWithPListFile:(NSString*)ipPListFileName;
- (void)setSetting:(NSString*)mpValue forKey:(NSString*)mpKey;
- (NSString*)getSetting:(NSString*)mpKey;

@end
