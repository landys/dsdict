//
//  DictCore.h
//  tcidsd
//
//  Created by Jinde Wang on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DictCore : NSObject {
    // mpDict is a two-dimensions array. Each element is the array contains the words whose length
    // is exacly the same as the index of the element. For the words whose length is equal or bigger
    // than 12, they will be put into mpDict[12].
    NSMutableArray* mpDict;
    
    // map from "word" to Word object. key - NSString, value - Word.
    //NSMutableDictionary* mpWordMap;
    
    int mDictLength;
}

- (void)initDicts;
//- (void)addDict:(NSString*) ipDictFile;
//- (void)clearDict;
- (NSArray*)lookupWords:(NSString*)ipChars length:(int)iWordLength;
@end
