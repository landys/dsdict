//
//  Word.h
//  tcidsd
//
//  Created by Jinde Wang on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Word : NSObject {
    // the word itself.
    NSString* mpWord;
    // english meaning, currently not supported.
    NSString* mpEn;
    // chinese meaning.
    NSString* mpCn;
    // 0~3, higher priority for bigger number.
    int mPriority;
    // the word source. currently not supported.
    //int mSource;
}

@property(nonatomic, retain)NSString* mpWord;
@property(nonatomic, retain)NSString* mpEn;
@property(nonatomic, retain)NSString* mpCn;
@property(nonatomic, assign)int mPriority;
//@property(nonatomic, assign)int mSource;

- (id)initWithWordContent:(NSString*)lpWord priority:(int)iPriority;
- (id)initWithWordContent:(NSString*)lpWord en:(NSString*)lpEn cn:(NSString*)lpCn priority:(int)iPrioritys;
- (Boolean)isValid:(int[])iChars;
- (NSString*)displayedCn;
- (NSString*)displayedEn;

@end
