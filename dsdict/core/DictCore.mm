//
//  DictCore.m
//  dsdict
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
#define DICT_FILE @"de"
#define WORDS_FILE @"we"
#define WORDS_N9_FILE @"w9"
#define DICT_N9_FILE @"d9"

//#define WORDS_NUM_LEVEL 160000

//#define LANG_EN 0
//#define LANG_CN 1

#define MAX_WORD_LENGTH 9

@interface DictCore (Private)

- (NSArray*)countChars:(NSString*)ipChars;
- (void)readDictFile:(NSString*)ipFileName onlyWords:(BOOL)iOnlyWords plain:(BOOL)iPlain;
- (void)cleanDicts;

//- (void)readWordsFile;
//- (void)readDictCnFile;
//- (void)readDictEnFile;
//- (void)readDictFile:(NSString*)ipDictFile language:(int)iLanguage;

@end

@implementation DictCore

- (id)init {
    self = [super init];
    if (self) {
        mCnDictLoaded = NO;
        
        [self cleanDicts];
        //mpWordMap = [[NSMutableDictionary alloc] initWithCapacity:WORDS_NUM_LEVEL];
    }
    return self;
}

- (void)cleanDicts {
    
    mpDict = [[NSMutableArray alloc] initWithCapacity:MAX_WORD_LENGTH];
    for (int i=0; i<=MAX_WORD_LENGTH; ++i) { // it's right with "<=" here.
        NSMutableArray* lpWords = [[NSMutableArray alloc] initWithCapacity:0];
        [mpDict addObject:lpWords];
    }
}

- (void)reInitDicts:(BOOL)iOnlyWords {
    [self cleanDicts];
    
    NSString* lFileName = (iOnlyWords ? WORDS_FILE : DICT_FILE);
    [self readDictFile:lFileName onlyWords:iOnlyWords plain:NO];
    
    // read aditional plain words with length 9, which is added later.
    //[self readPlainWordFile:WORDS_N9_FILE];
    NSString* lN9FileName = (iOnlyWords ? WORDS_N9_FILE : DICT_N9_FILE);
    [self readDictFile:lN9FileName onlyWords:iOnlyWords plain:YES];
    

    if (!iOnlyWords) {
        mCnDictLoaded = YES;
    }
    
    //[self readWordsFile];
    //[self readDictCnFile];
    //[self readDictEnFile];
}

- (BOOL)isCnDictLoaded {
    return mCnDictLoaded;
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
//        int lIDict = (lpWordText.length > MAX_WORD_LENGTH ? MAX_WORD_LENGTH : lpWordText.length);
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


// read encrypted dict file, every item in the dict is as "word|1|chinese/english mean".
// for onlyWords, the item is like "word|1".
- (void)readDictFile:(NSString*)ipFileName onlyWords:(BOOL)iOnlyWords plain:(BOOL)iPlain {
    if (ipFileName == nil) return;
    
    NSString* lpFinalPath = [[NSBundle mainBundle] pathForResource:ipFileName ofType:@""];
    FILE* lpFHandle = fopen([lpFinalPath UTF8String], "r");
    const int lBufSize = 10240;
    char lWordBuf[lBufSize];
    if (lpFHandle != nil) {
        char* lpBuf = nil;
        while (fgets(lWordBuf, lBufSize, lpFHandle) != nil) {
            NSString* lpWordText = nil;
            NSString* lpCn = nil;
            int lPriority = 0;
            
            int i = -1;
            if (iPlain) {
                lpBuf = lWordBuf;
                while (lpBuf[++i] != '|'); // correct ;.
            }
            else {
                // for decription
                lpBuf = lWordBuf + 1;
                int lMinusV = lWordBuf[0] - 'A';
                while (lpBuf[++i] != '|') {
                    // decript
                    lpBuf[i] = lpBuf[i] + (lMinusV + i);
                }
            }
            
            // construct string
            lpBuf[i] = '\0';
            lpWordText = [[NSString alloc] initWithUTF8String:lpBuf];
            
            // get priority value, it should be one digit.
            lPriority = lpBuf[i+1] - '0';
            
            if (!iOnlyWords) {
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
            }
            
            int lIDict = (lpWordText.length > MAX_WORD_LENGTH ? MAX_WORD_LENGTH : lpWordText.length);
            NSMutableArray* lpWords = [mpDict objectAtIndex:lIDict];
            
            Word* lpWord = [[Word alloc] initWithWordContent:lpWordText en:nil cn:lpCn priority:lPriority];
            [lpWords addObject:lpWord];
            
        }
        
        fclose(lpFHandle);
    }
}

// read the plain words, each line has a word, such as "word".
//- (void)readPlainWordFile:(NSString*)ipFileName {
//    if (ipFileName == nil) return;
//    
//    NSString* lpFinalPath = [[NSBundle mainBundle] pathForResource:ipFileName ofType:@""];
//    FILE* lpFHandle = fopen([lpFinalPath UTF8String], "r");
//    const int lBufSize = 100;
//    char lWordBuf[lBufSize];
//    if (lpFHandle != nil) {
//        while (fscanf(lpFHandle, "%s", lWordBuf) != EOF) {
//            NSString* lpWordText = nil;
//            NSString* lpCn = nil;
//            int lPriority = 1;
//
//            lpWordText = [[NSString alloc] initWithUTF8String:lWordBuf];
//            
//            int lIDict = (lpWordText.length > MAX_WORD_LENGTH ? MAX_WORD_LENGTH : lpWordText.length);
//            NSMutableArray* lpWords = [mpDict objectAtIndex:lIDict];
//            
//            Word* lpWord = [[Word alloc] initWithWordContent:lpWordText en:nil cn:lpCn priority:lPriority];
//            [lpWords addObject:lpWord];
//            
//        }
//        
//        fclose(lpFHandle);
//    }
//}

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
    int lIDict = (iWordLength > MAX_WORD_LENGTH) ? MAX_WORD_LENGTH : iWordLength;
    NSArray* lpWords = [mpDict objectAtIndex:lIDict];
    for (int i=0; i<lpWords.count; ++i) {
        Word* lpWord = [lpWords objectAtIndex:i];
        if ([lpWord isValid:lChars]) {
            [lpResults addObject:lpWord];
        }
    }
    
    return lpResults;
}


@end
