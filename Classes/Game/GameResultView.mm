//
//  GameResultView.m
//  Sudoku
//
//  Created by Kwang on 11/06/29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameResultView.h"
#import "GameOptionInfo.h"
#import "GameViewController.h"



@implementation GameResultView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		UIImageView* bg = [[UIImageView alloc] initWithFrame:self.bounds];
		bg.image = [UIImage imageNamed:@"success_box.png"];
		[self addSubview:bg];
		[bg release];
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
	[m_labelTime release];
	[m_btnNextPuzzle release];
	[m_btnSaveImage release];
    [super dealloc];
}

-(id) initResultView:(GameViewController*) controller {
	m_controller = controller;
	CGRect rt;
	CGFloat w, h;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		w = 768, h = 662;
	}
	else {
		w = 320, h = 276;
	}
	rt = CGRectMake((SCREEN_WIDTH-w)/2, (SCREEN_HEIGHT-h)/2, w, h);
	[self initWithFrame:rt];
	[self createBtns];
	[self createLabelTime];
	return self;
}
-(void) createLabelTime {
	CGRect rt;
	CGFloat w, h;
	UIFont* font;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		w = 342, h = 70;
		rt = CGRectMake(216, 238, w, h);
		font = [UIFont systemFontOfSize:38];
	}
	else {
		w = 142,h = 30;
		rt = CGRectMake(90, 98, w, h);
		font = [UIFont systemFontOfSize:24];
	}
	m_labelTime = [[UILabel alloc] initWithFrame:rt];
	m_labelTime.textAlignment = UITextAlignmentCenter;
	m_labelTime.font = font;
	m_labelTime.backgroundColor = [UIColor clearColor];
	[self addSubview:m_labelTime];	
}
-(void) createBtns {
	CGRect rtNext, rtSave;
	CGFloat w, h;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		w = 432, h = 110;
        if (g_GameOptionInfo.m_nGameType == GAME_CLASSIC) {
            rtNext = CGRectMake((self.bounds.size.width-w)/2, 430, w, h);
        }
        else {
            rtNext = CGRectMake((self.bounds.size.width-w)/2, 370, w, h);
            rtSave = CGRectMake((self.bounds.size.width-w)/2, 498, w, h);
        }
	}
	else {
		w = 172, h = 40;
        if (g_GameOptionInfo.m_nGameType == GAME_CLASSIC) {
            rtNext = CGRectMake((self.bounds.size.width-w)/2, 184, w, h);
        }
        else {
            rtNext = CGRectMake((self.bounds.size.width-w)/2, 154, w, h);
            rtSave = CGRectMake((self.bounds.size.width-w)/2, 208, w, h);
        }
	}
	
	m_btnNextPuzzle = [[UIButton alloc] initWithFrame:rtNext];
	[m_btnNextPuzzle setBackgroundImage:[UIImage imageNamed:@"nextpuzzle_nor.png"] forState:UIControlStateNormal];
	[m_btnNextPuzzle setBackgroundImage:[UIImage imageNamed:@"nextpuzzle_pre.png"] forState:UIControlStateHighlighted];
	[m_btnNextPuzzle addTarget:self action:@selector(onNextPuzzle) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:m_btnNextPuzzle];

    if (g_GameOptionInfo.m_nGameType != GAME_CLASSIC) {
        m_btnSaveImage = [[UIButton alloc] initWithFrame:rtSave];
        [m_btnSaveImage setBackgroundImage:[UIImage imageNamed:@"saveimage_nor.png"] forState:UIControlStateNormal];
        [m_btnSaveImage setBackgroundImage:[UIImage imageNamed:@"saveimage_pre.png"] forState:UIControlStateHighlighted];
        [m_btnSaveImage addTarget:self action:@selector(onSaveImage) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:m_btnSaveImage];
    }
}
-(void) setTime:(int)seconds {
	if (seconds >= 3600)
		m_labelTime.text = [NSString stringWithFormat:@"Time %d:%02d:%02d", seconds/3600, (seconds%3600)/60, seconds%60];
	else {
		m_labelTime.text = [NSString stringWithFormat:@"Time %d:%02d", (seconds)/60, seconds%60];
	}
}
-(void) onNextPuzzle {
	[m_controller nextPuzzle];
}
-(void) onSaveImage {
//	NSString* str = [NSString stringWithFormat:@"picpack%02d", g_GameOptionInfo.m_nSelectedPack];
	UIImage* imgPackOrg = [self getStageImage:g_GameOptionInfo.m_nSelectedStage];
	UIImageWriteToSavedPhotosAlbum(imgPackOrg, nil, nil, nil);
	//[imgPackOrg release];
	m_btnSaveImage.enabled = FALSE;
}
-(UIImage*) getStageImage:(int)stage {
	UIImage* img;
	NSString* strPack;
	
	if (g_GameOptionInfo.m_nSelectedPack < PICTURE_COUNT) {
//        strPack = [NSString stringWithFormat:@"%@%02d.jpg", [g_GameOptionInfo getPackName:g_GameOptionInfo.m_nSelectedPack], stage+1];
        strPack = [g_GameOptionInfo getPackImageFilePath:g_GameOptionInfo.m_nSelectedPack stage:stage];
//		switch (g_GameOptionInfo.m_nSelectedPack) {
//			case PICTURE_CITY:
//				strPack = [NSString stringWithFormat:@"city%02d.png", stage+1];
//				break;
//			case PICTURE_NATURE:
//				strPack = [NSString stringWithFormat:@"Nature%02d.png", stage+1];
//				break;
//			case PICTURE_ART:
//				strPack = [NSString stringWithFormat:@"art%02d.png", stage+1];
//				break;
//			default:
//				break;
//		}
//		img = [[UIImage imageNamed:strPack] retain];
        img = [[UIImage alloc] initWithContentsOfFile:strPack];
	}
	else {
		strPack = [NSString stringWithFormat:@"picpack%02d", g_GameOptionInfo.m_nSelectedPack];
		img = [[UIImage imageNamed:SHImageString(strPack, @"png")] retain];;
	}
	return [img autorelease];
}

@end
