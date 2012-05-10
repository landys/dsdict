//
//  DictCore.m
//  tcidsd
//
//  Created by Jinde Wang on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DictCore.h"
#import "Word.h"

//#define WORDS_FILE @"words.txt"
//#define DICT_CN_FILE @"dict_cn.txt"
//#define DICT_EN_FILE @"dict_en.txt"
//#define DICT_FILE @"dict.txt"
#define DICT_FILE @"background_e"

//#define WORDS_NUM_LEVEL 160000

//#define LANG_EN 0
//#define LANG_CN 1

@interface DictCore (Private)

- (NSArray*)countChars:(NSString*)ipChars;
- (void)readDictFile;
//- (void)readWordsFile;
//- (void)readDictCnFile;
//- (void)readDictEnFile;
//- (void)readDictFile:(NSString*)ipDictFile language:(int)iLanguage;

@end

@implementation DictCore

- (id)init {
    self = [super init];
    if (self) {
        mDictLength = 9;
        mpDict = [[NSMutableArray alloc] initWithCapacity:mDictLength];
        for (int i=0; i<=mDictLength; ++i) { // it's right with "<=" here.
            NSMutableArray* lpWords = [[NSMutableArray alloc] initWithCapacity:0];
            [mpDict addObject:lpWords];
            [lpWords release];
        }
        //mpWordMap = [[NSMutableDictionary alloc] initWithCapacity:WORDS_NUM_LEVEL];
    }
    return self;
}

- (void)initDicts {
    [self readDictFile];
    //[self readWordsFile];
    //[self readDictCnFile];
    //[self readDictEnFile];
}

//- (void)readWordsFile {
//    NSString* lpFinalPath = [[NSBundle mainBundle] pathForResource:WORDS_FILE ofType:@""];
//    FILE* lpFHandle = fopen([lpFinalPath UTF8String], "r");
//    if (lpFHandle == nil) {
//        return;
//    }
//    
//    const int lBufSize = 300;
//    char lWordBuf[lBufSize];
//    int lPriority;
//    int lSource;
//    while (fscanf(lpFHandle, "%s %d %d", lWordBuf, &lPriority, &lSource) != EOF) {
//        NSString* lpWordText = [[NSString alloc] initWithUTF8String:lWordBuf];
//        Word* lpWord = [[Word alloc] initWithWordContent:lpWordText priority:lPriority source:lSource];
//        
//        // add to dict
//        int lIDict = (lpWordText.length > mDictLength ? mDictLength : lpWordText.length);
//        NSMutableArray* lpWords = [mpDict objectAtIndex:lIDict];
//        [lpWords addObject:lpWord];
//        
//        // add to word map
//        [mpWordMap setObject:lpWord forKey:lpWordText];
//        
//        [lpWordText release];
//        [lpWord release];
//    }
//    
//    fclose(lpFHandle);
//}
//
//- (void)readDictCnFile {
//    [self readDictFile:DICT_CN_FILE language:LANG_CN];
//}
//
//- (void)readDictEnFile {
//    [self readDictFile:DICT_EN_FILE language:LANG_EN];
//}
//
//- (void)readDictFile:(NSString*)ipDictFile language:(int)iLanguage {
//    if (!ipDictFile || ipDictFile.length == 0) return;
//    
//    NSString* lpFinalPath = [[NSBundle mainBundle] pathForResource:ipDictFile ofType:@""];
//    FILE* lpFHandle = fopen([lpFinalPath UTF8String], "r");
//    if (lpFHandle == nil) {
//        return;
//    }
//    
//    const int lBufSize = 10240;
//    char lWordBuf[lBufSize];
//    char* lpBuf = nil;
//    while (fgets(lWordBuf, lBufSize, lpFHandle) != nil) {
//        NSString* lpWordText = nil;
//        NSString* lpMeaning = nil;
//        
//        lpBuf = lWordBuf;
//        int i = 0;
//        for (; lpBuf[i]!='\0'; ++i) {
//            if (lpBuf[i] == '|') {
//                lpBuf[i] = '\0';
//                lpWordText = [[NSString alloc] initWithUTF8String:lpBuf];
//                lpBuf += (i + 1); // to the position of the word meaing.
//                break;
//            }
//        }
//        
//        if (*lpBuf != '\0' && *lpBuf != '\n') {
//            for (i=0; lpBuf[i]!='\0'; ++i); // end of for here, will reach the end of the read line.
//            
//            // i should be > 0 here, because of the if check out of for loop.
//            if (lpBuf[i-1] == '\n') {
//                lpBuf[i-1] = '\0';
//            }
//            lpMeaning = [[NSString alloc] initWithUTF8String:lpBuf];
//        }
//        
//        Word* lpWord = [mpWordMap objectForKey:lpWordText];
//        if (lpWord) {
//            if (iLanguage == LANG_CN) {
//                lpWord.mpCn = lpMeaning;
//            }
//            else if (iLanguage == LANG_EN) {
//                lpWord.mpEn = lpMeaning;
//            }
//        }
//        
//        [lpWordText release];
//        [lpMeaning release];
//    }
//    
//    fclose(lpFHandle);
//}

// can read dict.txt, every item in the dict is as "word|1|0|chinese/english mean".
- (void)readDictFile {
    NSString* lpFinalPath = [[NSBundle mainBundle] pathForResource:DICT_FILE ofType:@""];
    FILE* lpFHandle = fopen([lpFinalPath UTF8String], "r");
    const int lBufSize = 10240;
    char lWordBuf[lBufSize];
    if (lpFHandle != nil) {
        char* lpBuf = nil;
        while (fgets(lWordBuf, lBufSize, lpFHandle) != nil) {
            NSString* lpWordText = nil;
            NSString* lpCn = nil;
            int lPriority = 0;
            
//            lpBuf = lWordBuf;
//            int i = 0;
//            int j = 0;
//            for (; lpBuf[i]!='\0'; ++i) {
//                if (lpBuf[i] == '|') {
//                    lpBuf[i] = '\0';
//                    // decript                    
//                    for (j=0; j<i; ++j) {
//                        lpBuf[j] = lpBuf[j] + i;
//                    }
//                    lpWordText = [[NSString alloc] initWithUTF8String:lpBuf];
//                    lPriority = lpBuf[i+1] - '0';
//                    lpBuf += (i + 3); // to the position of the word source.
//                    break;
//                }
//            }
            
            // for decription
            int lMinusV = lWordBuf[0] - 'A';
            lpBuf = lWordBuf + 1;
            int i = -1;
            while (lpBuf[++i] != '|') {
                // decript
                lpBuf[i] = lpBuf[i] + (lMinusV + i);
            }
            
            // construct string
            lpBuf[i] = '\0';
            lpWordText = [[NSString alloc] initWithUTF8String:lpBuf];
            
            // get priority value, it should be one digit.
            lPriority = lpBuf[i+1] - '0';
            
            // to the position of the word explanation.
            lpBuf += (i + 3);
            
            //while (*(lpBuf++) != '|'); // end of while here, will reach the beginning of the cn meaning.
            if (*lpBuf != '\0' && *lpBuf != '\n') {
                //for (i=0; lpBuf[i]!='\0'; ++i); // end of for here, will reach the end of the read line.
                
                // i should be > 0 here, because of the if check out of for loop.
                //if (lpBuf[i-1] == '\n') {
                //    lpBuf[i-1] = '\0';
                //}
                lpBuf[strlen(lpBuf) - 1] = '\0';
                lpCn = [[NSString alloc] initWithUTF8String:lpBuf];
            }
            
            int lIDict = (lpWordText.length > mDictLength ? mDictLength : lpWordText.length);
            NSMutableArray* lpWords = [mpDict objectAtIndex:lIDict];
            
            Word* lpWord = [[Word alloc] initWithWordContent:lpWordText en:nil cn:lpCn priority:lPriority];
            [lpWords addObject:lpWord];
            [lpWord release];
            
            [lpWordText release];
            [lpCn release];
        }
        
        fclose(lpFHandle);
    }
}

//- (void)clearDict {
//    [mpDict removeAllObjects];
//}

- (NSArray*)lookupWords:(NSString*)ipChars length:(int)iWordLength {
    NSMutableArray* lpResults = [NSMutableArray arrayWithCapacity:0];
    if (!ipChars || ipChars.length == 0 || iWordLength <= 0) return lpResults;
    
    NSString* lpChars = [ipChars lowercaseString];
    // count chars in ipChars.
    int lChars[26] = {0};
    for (int i=0; i<lpChars.length; ++i) {
        int lCharInt = [lpChars characterAtIndex:i] - 'a';
        if (lCharInt >= 0 && lCharInt < 26) {
            ++lChars[lCharInt];
        }
    }
    
    // find valid words.
    int lIDict = (iWordLength > mDictLength) ? mDictLength : iWordLength;
    NSArray* lpWords = [mpDict objectAtIndex:lIDict];
    for (int i=0; i<lpWords.count; ++i) {
        Word* lpWord = [lpWords objectAtIndex:i];
        if ([lpWord isValid:lChars]) {
            [lpResults addObject:lpWord];
        }
    }
    
    return lpResults;
}

-(void) dealloc {
    [mpDict release];
    //[mpWordMap release];
    [super dealloc];
}

@end
