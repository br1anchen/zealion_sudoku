//
//  TileView.h
//  Sudoku
//
//  Created by Kwang on 11/06/08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TileView : UIView {
	int				m_nType;
	UIImageView*	m_imgShadow;
	UIImageView*	m_imgPicPack;
	UIImageView*	m_imgNumber;
	UIImageView*	m_imgSelected;
	CGPoint			m_ptBasePos;
	BOOL			m_bSelected;
	BOOL			m_bGiven;
    BOOL            m_bBoardTile;
}

-(void) setImage:(int)type given:(BOOL)given picpack:(CGImageRef)imgPicPack number:(CGImageRef)imgNumber select:(CGImageRef)imgSelect;
-(void) setShadowImage;
-(void) setSelected:(BOOL)select;
-(void) setNumberImage:(CGImageRef)imgNumber;
-(void) setPos:(CGPoint)pt;
-(CGPoint) getOrgCenterPos;
-(void) setFixed;
-(void) fadeInSelectedImage;
-(void) fadeOutSelectedImage;
-(void) stopFadeInSelectedImage;
-(void) stopFadeOutSelectedImage;

-(BOOL) isBoardTile;
-(void) setBoardTile:(BOOL)board;

-(void) setResize:(CGRect)frame;
-(void) setResizeAnim:(CGRect)frame;
-(void) stopResizeAnim;

@end
