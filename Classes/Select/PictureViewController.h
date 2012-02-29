//
//  PictureViewController.h
//  Sudoku
//
//  Created by Kwang on 11/05/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PictureViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView*	m_viewTable;
    IBOutlet UIButton*      m_btnGetMore;
	BOOL	m_bHideNavBar;
}

-(IBAction) onMorePiture:(id)sender;
-(void) menuAction:(id)sender;
-(CGFloat) getCellHeight;
-(UIImage*) getPackImage:(int)pack;

@end
