//
//  OptionViewController.h
//  Sudoku
//
//  Created by Kwang on 11/05/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface OptionViewController : UIViewController {
	IBOutlet UIImageView*	m_imgSymbals;
	IBOutlet UIImageView*	m_imgColors;
	IBOutlet UIImageView*	m_imgNumbers;
	IBOutlet UIImageView*	m_imgBgLight;
	IBOutlet UIImageView*	m_imgBgDark;
	int		m_nToggleIcon;
	int		m_nBgType;
}

-(void) changeToggleIcon:(int)toggle;
-(void) changeBgType:(int)bgtype;
-(IBAction) onDone:(id)sender;

@end
