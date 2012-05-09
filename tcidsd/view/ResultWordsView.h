//
//  ResultWordsView.h
//  tcidsd
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
	id<ResultWordsViewDelegate> mDelegate;
	CGSize mVisibleSize;
	UILabel* mpLblNoResult;
    
    int mNTiles;
}

@property (nonatomic, assign) id<ResultWordsViewDelegate> mDelegate;
@property (nonatomic, assign) CGSize mVisibleSize;

- (void)refreshData:(NSDictionary*)ipData dataKeys:(NSArray*)ipDataKeys;
- (void)reDisplayNoResultsIfNeeded;

@end
