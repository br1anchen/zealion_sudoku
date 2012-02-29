//
//  TileView.h
//  Sudoku
//
//  Created by Kwang on 11/06/08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NumberTileView : UIView {
	int				m_nType;
	UIImageView*	m_imgNumber;
	UIImageView*	m_imgRedNumber;
	
	NSMutableArray*	m_arraySmallNumber;
	BOOL			m_bSelected;
	BOOL			m_bGiven;
	BOOL			m_bShowRedNumber;
}

-(void) setImage:(BOOL)bGiven number:(CGImageRef)imgNumber rednumber:(CGImageRef)imgRed;
-(void) loadSmallNumber;
-(void) setNumberImage:(CGImageRef)imgNumber rednumber:(CGImageRef)imgRed;
-(void) unselect;
-(BOOL) isShowRedNumber;
-(void) showRedNumber;
-(void) hideRedNumber;
-(void) setHideRedNumberAnim;
-(void) stopHideRedNumberAnim;
//small
-(void) showSmallNumber:(int)number show:(BOOL)bShow;
-(void) hideAllSmallNumber;

@end
