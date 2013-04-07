//
//  Word.m
//  dsdict
//
//  Created by Jinde Wang on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Word.h"

@implementation Word

@synthesize mpWord, mpEn, mpCn, mPriority;

- (id)initWithWordContent:(NSString*)lpWord priority:(int)iPriority {
    self = [super init];
    if (self) {
        mpWord = lpWord;
        mPriority = iPriority;
    }
    
    return self;
}

- (id)initWithWordContent:(NSString*)lpWord en:(NSString*)lpEn cn:(NSString*)lpCn priority:(int)iPriority {
    self = [super init];
    if (self) {
        mpWord = lpWord;
        mpEn = lpEn;
        mpCn = lpCn;
        mPriority = iPriority;
    }
    
    return self;
}

- (Boolean)isValid:(int[])iChars {
    Boolean valid = true;
    int lChars[26] = {0};
    for (int i=0; i<26; ++i) {
        lChars[i] = iChars[i];
    }
    
    for (int i=0; i<mpWord.length; ++i) {
        int lIChar = [mpWord characterAtIndex:i] - 'a';
        if (lIChar >=0 && lIChar < 26) {
            if (lChars[lIChar] <= 0) {
                valid = false;
                break;
            }
            --lChars[lIChar];
        }
    }
    
    return valid;
}

- (NSString*)displayedCn {
    return [mpCn stringByReplacingOccurrencesOfString:@"#" withString:@"。"];
}

- (NSString*)displayedEn {
    return [mpCn stringByReplacingOccurrencesOfString:@"#" withString:@". "];
}


- (NSString*)description {
    return [NSString stringWithFormat:@"%@|%d|%@|%@", mpWord, mPriority, mpEn, mpCn];
}

@end
