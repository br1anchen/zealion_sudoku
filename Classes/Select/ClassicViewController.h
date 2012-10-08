//
//  ClassicViewController.h
//  Sudoku
//
//  Created by Kwang on 11/05/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ClassicViewController : UIViewController {
	IBOutlet UILabel* m_labelEasy;
	IBOutlet UILabel* m_labelMedium;
	IBOutlet UILabel* m_labelHard;
	IBOutlet UILabel* m_labelEasyRank;
	IBOutlet UILabel* m_labelMediumRank;
	IBOutlet UILabel* m_labelHardRank;
	BOOL	m_bHideNavBar;
}

-(void) setCompleteLabel;
-(void) setRankLabel;
-(NSString*) getRankString:(int)index;
-(IBAction) onEasy:(id)sender;
-(IBAction) onMedium:(id)sender;
-(IBAction) onHard:(id)sender;

-(void) pushGameView;

@end
