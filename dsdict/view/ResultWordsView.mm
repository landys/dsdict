//
//  ResultWordsView.m
//  dsdict
//
//  Created by Jinde Wang on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ResultWordsView.h"
#import "SectionHeaderViewer.h"
#import "DetailTableViewCell.h"
#import "TileTableViewCell.h"
#import "Word.h"
#import "Global.h"
#import "DictUtil.h"
//#import "ItemCircle.h"

//#define MIN_TILE_WIDTH 150
#define TILE_NUM_PER_ROW 2
#define TILE_NUM_PER_ROW_IPAD 5

@implementation ResultWordsView

@synthesize mDelegate, mVisibleSize;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
	self = [super initWithFrame:frame style:style];
    if (self) {
//        mNTiles = (int)(frame.size.width / MIN_TILE_WIDTH);
//        if (mNTiles <= 1) {
//            mNTiles = 1;
//        }
        mNTiles = ([DictUtil isIPad] ? TILE_NUM_PER_ROW_IPAD : TILE_NUM_PER_ROW);
        
        self.delegate = self;
        self.dataSource = self;
        mVisibleSize = self.frame.size;
        
		mpLblNoResult = [[UILabel alloc] initWithFrame:CGRectMake(100, 5, 175, 30)];
		mpLblNoResult.font = [UIFont boldSystemFontOfSize:18];
		mpLblNoResult.highlightedTextColor = [UIColor whiteColor];
		mpLblNoResult.textColor = [UIColor darkGrayColor];
		mpLblNoResult.text = @"No Results";
        
        self.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.9];
	}
	
	return self;
}

- (void)refreshData:(NSDictionary*)ipData dataKeys:(NSArray*)ipDataKeys {
	mpData = ipData;
    mpDataKeys = ipDataKeys;
    
	[self reloadData];
    
    [self setContentOffset:CGPointZero];
}

- (void)reDisplayNoResultsIfNeeded {
	if (!mpDataKeys || [mpDataKeys count] == 0) {
		[self reloadData];
	}
}

- (void)deselectAll {
    NSIndexPath* lpSelIndexPath = [self indexPathForSelectedRow];
    if (lpSelIndexPath != nil) {
        [self deselectRowAtIndexPath:lpSelIndexPath animated:NO];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    int lSecNum = [mpDataKeys count];
    return lSecNum == 0 ? 1 : lSecNum;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if ([mpDataKeys count] == 0) {
		return (int)(mVisibleSize.height/tableView.rowHeight/2);
	}
	
	id lpKey = [mpDataKeys objectAtIndex:section];
    int lNData = [(NSArray*)([mpData objectForKey:lpKey]) count];
    
    return ([Global isLanguageNone] ? (int)((lNData + mNTiles - 1) / mNTiles) : lNData);
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if ([mpDataKeys count] == 0) {
		return nil;
	}
	
	NSString* lpDataKey = (NSString*)([mpDataKeys objectAtIndex:section]);
	NSArray* lpItems = (NSArray*)[mpData objectForKey:lpDataKey];

	SectionHeaderViewer* lpSectionHeaderViewer = [[SectionHeaderViewer alloc] 
												   initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30) wordsTitle:lpDataKey wordsCount:lpItems.count];
	
	return lpSectionHeaderViewer;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* DetailCellIdentifier = @"DetailCell";
    static NSString* TileCellIdentifier = @"TileCell";
	static NSString* EmptyCellIdentifier = @"EmptyCell";
	
	UITableViewCell* cell = nil;
    CGSize lCellSize = CGSizeMake(tableView.frame.size.width, 0);
	
	if ([mpDataKeys count] == 0) {
		cell = [tableView dequeueReusableCellWithIdentifier:EmptyCellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EmptyCellIdentifier];
			cell.userInteractionEnabled = false;
		}
		
		int lNRows = [tableView numberOfRowsInSection:0];
		if (indexPath.row == lNRows - 1) {
			[cell.contentView addSubview:mpLblNoResult];
		}
	}
	else if ([Global isLanguageNone]) {
        cell = [tableView dequeueReusableCellWithIdentifier:TileCellIdentifier];
		if (cell == nil) {
			// there should be no release pool for cell here. It's released outside by Apple SDK.
			cell = [[TileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TileCellIdentifier tileNum:mNTiles size:lCellSize];
            cell.userInteractionEnabled = false;
		}
		
        TileTableViewCell* lpResultCell = (TileTableViewCell*)cell;
		id lpKey = [mpDataKeys objectAtIndex:indexPath.section];
		NSArray* lpItemDatas = (NSArray*)([mpData objectForKey:lpKey]);
        int lIBeg = indexPath.row * mNTiles;
		
        if (lpItemDatas && [lpItemDatas count] > lIBeg) {
            NSMutableArray* lpWords = [[NSMutableArray alloc] initWithCapacity:0];
            for (int i=lIBeg; i<lIBeg+mNTiles && i<[lpItemDatas count]; ++i) {
                [lpWords addObject:[lpItemDatas objectAtIndex:i]];
            }
            [lpResultCell applayData:lpWords begIndex:lIBeg];
		}
    }
    else {
		cell = [tableView dequeueReusableCellWithIdentifier:DetailCellIdentifier];
		if (cell == nil) {
			// there should be no release pool for cell here. It's released outside by Apple SDK.
			cell = [[DetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DetailCellIdentifier size:lCellSize];
		}
		
        DetailTableViewCell* lpResultCell = (DetailTableViewCell*)cell;
        
		id lpKey = [mpDataKeys objectAtIndex:indexPath.section];
		NSArray* lpItemDatas = (NSArray*)([mpData objectForKey:lpKey]);
		if (lpItemDatas && [lpItemDatas count] > indexPath.row) {
            Word* lpItemData = (Word*)([lpItemDatas objectAtIndex:indexPath.row]);
			[lpResultCell applayData:lpItemData begIndex:indexPath.row];
		}
    }
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//	NSString* lpDataKey = (NSString*)[mpDataKeys objectAtIndex:indexPath.section];
//	Word* lpWord = (Word*)[((NSArray*)[mpData objectForKey:lpDataKey]) objectAtIndex:indexPath.row];
    if (mpDataKeys.count == 0 || [Global isLanguageNone]) {
        return;
    }
    
    DetailTableViewCell* lpCell = (DetailTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    CGRect lCellFrame = lpCell.frame;
    lCellFrame.origin.y -= tableView.contentOffset.y;
	[mDelegate didSelectItem:lpCell.mpWord cellFrame:lCellFrame];
}

@end
