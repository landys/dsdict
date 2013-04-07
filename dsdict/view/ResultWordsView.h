//
//  ResultWordsView.h
//  dsdict
//
//  Created by Jinde Wang on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Word.h"

@protocol ResultWordsViewDelegate

@optional
- (void)didSelectItem:(Word*)ipWord cellFrame:(CGRect)iCellFrame;

@end


@interface ResultWordsView : UITableView <UITableViewDelegate, UITableViewDataSource> {
	// key - date string, value - NSArray of CalendarItemData.
	NSDictionary* mpData;
    NSArray* mpDataKeys;
	id<ResultWordsViewDelegate> __unsafe_unretained mDelegate;
	CGSize mVisibleSize;
	UILabel* mpLblNoResult;
    
    int mNTiles;
}

@property (nonatomic, unsafe_unretained) id<ResultWordsViewDelegate> mDelegate;
@property (nonatomic, assign) CGSize mVisibleSize;

- (void)refreshData:(NSDictionary*)ipData dataKeys:(NSArray*)ipDataKeys;
- (void)reDisplayNoResultsIfNeeded;
- (void)deselectAll;

@end
