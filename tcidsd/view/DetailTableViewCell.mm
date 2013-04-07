//
//  DetailTableViewCell.m
//  dsdict
//
//  Created by Jinde Wang on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailTableViewCell.h"
#import "Global.h"
#import "DictUtil.h"

#define WORD_FONT_SIZE 17
#define MEANING_FONT_SIZE 17

@implementation DetailTableViewCell

@synthesize mpWord;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)iCellSize {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGSize lSize = self.frame.size;
        // the width in self.frame.size is not accurate, and seems always 320.
        lSize.width = iCellSize.width;
        float lWordWidth = [DictUtil isIPad] ? 120.f : 110.f;

        // render duration
        mpLblWord = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, lWordWidth, lSize.height)];
        mpLblWord.font = [Global getCommonBoldFont:WORD_FONT_SIZE];//mpLblWord.font.pointSize];
        mpLblWord.textColor = [Global getDarkTextColor];
        mpLblWord.highlightedTextColor = [Global getLightTextColor];
        [self.contentView addSubview:mpLblWord];
        
        // render title
        mpLblMeaning = [[UILabel alloc] initWithFrame:CGRectMake(lWordWidth, 0, lSize.width - lWordWidth, lSize.height)];
        mpLblMeaning.font = [Global getCommonLightFont:MEANING_FONT_SIZE];//mpLblMeaning.font.pointSize];
        mpLblMeaning.textColor = [Global getDarkTextColor];
        mpLblMeaning.highlightedTextColor = [Global getLightTextColor];
        [self.contentView addSubview:mpLblMeaning];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)applayData:(Word*)ipWord begIndex:(int)iBegIndex {
    if (ipWord) {
        mpWord = ipWord;
        NSString* lpText = [[NSString alloc] initWithFormat:@"%d). %@", iBegIndex + 1, mpWord.mpWord];
        mpLblWord.text = lpText;
//        NSString* lpLanguage = [Global getLanguageSetting];
//        mpLblMeaning.text = (lpLanguage != nil && [lpLanguage compare:LANGUAGE_CHINESE] == NSOrderedSame ? [mpWord displayedCn] : [mpWord displayedEn]);
        mpLblMeaning.text = [mpWord displayedCn];
    }
    else {
        mpWord = nil;
        mpLblWord.text = nil;
        mpLblMeaning.text = nil;
    }
}


@end
