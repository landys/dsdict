//
//  DetailTableViewCell.h
//  tcidsd
//
//  Created by Jinde Wang on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Word.h"

@interface DetailTableViewCell : UITableViewCell {
    UILabel* mpLblWord;
    UILabel* mpLblMeaning;
    
    Word* mpWord;
}

@property (nonatomic, readonly)Word* mpWord;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)iCellSize;
- (void)applayData:(Word*)ipWord begIndex:(int)iBegIndex;

@end
