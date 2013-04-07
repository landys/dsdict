//
//  TileTableViewCell.m
//  dsdict
//
//  Created by Jinde Wang on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TileTableViewCell.h"
#import "Global.h"
#import "Word.h"

#define TILE_WORD_FOND_SIZE 17

@implementation TileTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier tileNum:(int)iNTiles size:(CGSize)iCellSize {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        mNTiles = iNTiles;
        
        mpLblWords = [[NSMutableArray alloc] initWithCapacity:0];
        
        CGSize lSize = self.frame.size;
        // the width is not accurate, and seems always 320.
        lSize.width = iCellSize.width;
        
        CGFloat lWordWidth = (int)(lSize.width / mNTiles);
        
        for (int i=0; i<mNTiles; ++i) {
            UILabel* lpLblWord = [[UILabel alloc] initWithFrame:CGRectMake(lWordWidth * i, 0, lWordWidth, lSize.height)];
            lpLblWord.font = [Global getCommonBoldFont:TILE_WORD_FOND_SIZE];//lpLblWord.font.pointSize];
            lpLblWord.textColor = [Global getDarkTextColor];
            lpLblWord.highlightedTextColor = [Global getLightTextColor];
            lpLblWord.hidden = YES;
            [mpLblWords addObject:lpLblWord];
            [self.contentView addSubview:lpLblWord];
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)applayData:(NSArray*)ipWords begIndex:(int)iBegIndex {
    mpWords = ipWords;
    
    for (int i=0; i<mpLblWords.count; ++i) {
        UILabel* lpLblWord = (UILabel*)[mpLblWords objectAtIndex:i];
        if (i < mpWords.count) {
            NSString* lpText = [[NSString alloc] initWithFormat:@"%d). %@", iBegIndex + i + 1, ((Word*)[mpWords objectAtIndex:i]).mpWord];
            lpLblWord.text = lpText;
            lpLblWord.hidden = NO;
        }
        else {
            lpLblWord.hidden = YES;
        }
    }
}


@end
