//
//  TileView.m
//  Sudoku
//
//  Created by Kwang on 11/06/08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NumberTileView.h"
#import "GameOptionInfo.h"

@implementation NumberTileView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		self.backgroundColor = [UIColor clearColor];
		m_bShowRedNumber = FALSE;
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
	[m_imgNumber release];
	[m_imgRedNumber release];
	[m_arraySmallNumber release];
    [super dealloc];
}

-(void) setImage:(BOOL)bGiven number:(CGImageRef)imgNumber rednumber:(CGImageRef)imgRed {
	m_bGiven = bGiven;
	if (bGiven == FALSE) {
		[self loadSmallNumber];
	}
	[self setNumberImage:imgNumber rednumber:imgRed];
}

-(void) loadSmallNumber {
	NSString* strImage;
	switch (g_GameOptionInfo.m_nToggleIconType) {
		case TOGGLE_NUMBERS:
			strImage = @"small_number";
			break;
		case TOGGLE_COLORS:
			strImage = @"small_color";
			break;
		case TOGGLE_SYMBOLS:
			strImage = @"small_symbol";
			break;
		default:
			break;
	}
	m_arraySmallNumber = [[NSMutableArray alloc] init];
	UIImage* image = [UIImage imageNamed:SHImageString(strImage, @"png")];
	CGRect rtSmall;
	CGFloat h = CGImageGetHeight(image.CGImage);
	CGFloat w = h;
	CGSize sizeBounds = self.bounds.size;
	CGFloat x,y;
	for (int i = 0; i < 9; i ++) {
		rtSmall = CGRectMake(i*w, 0, w, h);
		CGImageRef imgRefSmall = CGImageCreateWithImageInRect(image.CGImage, rtSmall);
		x = (i%3)*(sizeBounds.width/3);
		y = (i/3)*(sizeBounds.height/3);
		UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, sizeBounds.width/3, sizeBounds.height/3)];
        imgView.image = [UIImage imageWithCGImage:imgRefSmall];
//		imgView.frame = ;
		[m_arraySmallNumber addObject:imgView];
		[self addSubview:imgView];
		imgView.hidden = YES;
		CGImageRelease(imgRefSmall);
		[imgView release];
	}
}
-(void) setNumberImage:(CGImageRef)imgNumber rednumber:(CGImageRef)imgRed {
	if (imgNumber != nil) {
		if (m_imgNumber == nil) {
			m_imgNumber = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:imgNumber]];
			m_imgNumber.frame = [self bounds];
			[self addSubview:m_imgNumber];
		}
		else {
			m_imgNumber.image = [UIImage imageWithCGImage:imgNumber];
		}
		m_imgNumber.hidden = NO;
	}
	else {
		m_imgNumber.hidden = YES;
	}

	if (imgRed != nil) {
		if (m_imgRedNumber == nil) {
			m_imgRedNumber = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:imgRed]];
			m_imgRedNumber.frame = [self bounds];
			[self addSubview:m_imgRedNumber];
		}
		else {
			m_imgRedNumber.image = [UIImage imageWithCGImage:imgRed];
		}
		m_imgRedNumber.hidden = YES;
	}
}
-(void) unselect {
	m_imgNumber.hidden = NO;
	m_imgRedNumber.hidden = NO;
	m_bShowRedNumber = FALSE;
}
-(void) showRedNumber {
	m_imgNumber.hidden = YES;
	m_imgRedNumber.alpha = 1.0f;
	m_imgRedNumber.hidden = NO;
	m_bShowRedNumber = TRUE;
	[self performSelector:@selector(hideRedNumber) withObject:nil afterDelay:0.4f];
}
-(void) hideRedNumber {
	[self setHideRedNumberAnim];
}
-(void) setHideRedNumberAnim {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDidStopSelector:@selector(stopHideRedNumberAnim)];
	// アニメーションをコミット
	m_imgRedNumber.alpha = 0.0f;
	[UIView commitAnimations];
}
-(void) stopHideRedNumberAnim {
	m_imgRedNumber.hidden = YES;
	m_imgNumber.hidden = NO;
	m_bShowRedNumber = FALSE;
}
-(BOOL) isShowRedNumber {
	return m_bShowRedNumber;
}
-(void) showSmallNumber:(int)number show:(BOOL)bShow {
	if (number <= 0)
		return;
//	m_imgNumber.hidden = YES;
	UIImageView* small = (UIImageView*)[m_arraySmallNumber objectAtIndex:number-1];
	small.hidden = !bShow;
}
-(void) hideAllSmallNumber {
//	m_imgNumber.hidden = NO;
	for (int i = 0; i < 9; i ++) {
		UIImageView* small = (UIImageView*)[m_arraySmallNumber objectAtIndex:i];
		small.hidden = YES;
	}
}

@end
