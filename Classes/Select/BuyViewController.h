//
//  BuyViewController.h
//  Sudoku
//
//  Created by Kwang on 11/10/04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BuyViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView*	m_viewTable;
    NSMutableArray*     m_arrayButtons;
}

//-(void) initBuyPackState;

-(void) buttonAction:(id)sender;

-(UIButton*) createButton:(int)tag;
-(UIButton*) getButton:(int)tag;

-(CGFloat) getCellHeight;
-(UIImage*) getPackImage:(int)pack;

@end
