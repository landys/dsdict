//
//  TileTableViewCell.h
//  tcidsd
//
//  Created by Jinde Wang on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TileTableViewCell : UITableViewCell {
    NSMutableArray* mpLblWords;
    
    NSArray* mpWords;
    
    int mNTiles;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier tileNum:(int)iNTiles size:(CGSize)iCellSize;
- (void)applayData:(NSArray*)ipWords begIndex:(int)iBegIndex;

@end
