//
//  TileView.m
//  Sudoku
//
//  Created by Kwang on 11/06/08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TileView.h"


@implementation TileView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		self.backgroundColor = [UIColor clearColor];
		m_ptBasePos = frame.origin;
        m_bBoardTile = NO;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
	[m_imgPicPack release];
	[m_imgNumber release];
	[m_imgSelected release];
    [super dealloc];
}

-(void) setImage:(int)type given:(BOOL)given picpack:(CGImageRef)imgPicPack number:(CGImageRef)imgNumber select:(CGImageRef)imgSelect {
	m_nType = type;
	m_bGiven = given;
	if (imgPicPack != nil) {
		m_imgPicPack = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:imgPicPack]];
		m_imgPicPack.frame = [self bounds];
		[self addSubview:m_imgPicPack];
	}
	if (imgNumber != nil) {
		m_imgNumber = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:imgNumber]];
		m_imgNumber.frame = [self bounds];
		[self addSubview:m_imgNumber];
	}
	if (imgSelect != nil) {
		m_imgSelected = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:imgSelect]];
		m_imgSelected.frame = [self bounds];
		[self addSubview:m_imgSelected];
		m_imgSelected.hidden = YES;
	}
	if (m_bGiven == FALSE)
		[self setShadowImage];
    else {
        [self setBoardTile:YES];
    }
}
-(void) setShadowImage {
	m_imgShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SHImageString(@"piece_shadow", @"png")]];
	[self addSubview:m_imgShadow];
	[self sendSubviewToBack:m_imgShadow];
}
-(void) setNumberImage:(CGImageRef)imgNumber {
	if (imgNumber != nil) {
		if (m_imgNumber == nil) {
			m_imgNumber = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:imgNumber]];
			m_imgNumber.frame = [self bounds];
			[self addSubview:m_imgNumber];
		}
		else {
			m_imgNumber.image = [UIImage imageWithCGImage:imgNumber];
		}
	}
}
-(void) setSelected:(BOOL)select {
	if (m_bSelected == select) {
		return;
	}
	m_bSelected = select;
	m_imgSelected.hidden = !select;
	if (select) {
		[self fadeInSelectedImage];
	}
}

-(void) setPos:(CGPoint)pt {
	m_ptBasePos = pt;
	self.frame = CGRectMake(pt.x, pt.y, self.bounds.size.width, self.bounds.size.height);
}
-(void) setFixed {
	m_imgShadow.hidden = YES;
}
-(CGPoint) getOrgCenterPos {
	return CGPointMake(m_ptBasePos.x+self.bounds.size.width/2, m_ptBasePos.y+self.bounds.size.height/2);
}
-(void) fadeInSelectedImage {
	if (m_bSelected == FALSE) {
		return;
	}
	m_imgSelected.alpha = 0.0f;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationDidStopSelector:@selector(stopFadeInSelectedImage)];
	// アニメーションをコミット
	m_imgSelected.alpha = 1.0f;
	[UIView commitAnimations];
	
}
-(void) fadeOutSelectedImage {
	if (m_bSelected == FALSE) {
		return;
	}
	m_imgSelected.alpha = 1.0f;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationDidStopSelector:@selector(stopFadeOutSelectedImage)];
	// アニメーションをコミット
	m_imgSelected.alpha = 0.0f;
	[UIView commitAnimations];
}
-(void) stopFadeInSelectedImage {
	if (m_bSelected) {
		[self fadeOutSelectedImage];
	}
}
-(void) stopFadeOutSelectedImage {
	if (m_bSelected) {
		[self fadeInSelectedImage];
	}
}
-(BOOL) isBoardTile {
    return m_bBoardTile;
}
-(void) setBoardTile:(BOOL)board {
    m_bBoardTile = board;
}

-(void) setResize:(CGRect)frame {
    [self setFrame:frame];
    CGRect bound = self.bounds;
    m_imgShadow.frame = bound;
    m_imgPicPack.frame = bound;
    m_imgNumber.frame = bound;
    m_imgSelected.frame = bound;
}
-(void) setResizeAnim:(CGRect)frame {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.1];
	[UIView setAnimationDidStopSelector:@selector(stopResizeAnim)];
	// アニメーションをコミット
    [self setFrame:frame];
    CGRect bound = self.bounds;
    m_imgShadow.frame = bound;
    m_imgPicPack.frame = bound;
    m_imgNumber.frame = bound;
    m_imgSelected.frame = bound;
	[UIView commitAnimations];
}
-(void) stopResizeAnim {
    
}
@end
