//
//  GameViewController.m
//  Sudoku
//
//  Created by Kwang on 11/05/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameViewController.h"
#import "SudokuAppDelegate.h"
#import "MainMenuViewController.h"
#import "GameOptionInfo.h"
#import "TileView.h"
#import "SudokuEngine.h"
#import "NumberTileView.h"
#import <QuartzCore/QuartzCore.h>


//#define TEST_WIN
//#define TEST_SOLVE

#define kTagTile		0x30
#define kTagNumberBtn	0x80
#define kTagClear		0x90
#define DRAWER_ROW		6
#define DRAWER_COL		2
//#define ZOOMIN_BOARDSIZE    640
#define BOARDSIZE_ZOOMIN    640
#define BOARDSIZE_ZOOMOUT   320

@implementation GameViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	switch (g_GameOptionInfo.m_nGameType) {
		case GAME_PUZZLE:
			self.title = @"Puzzudoku";
			break;
		case GAME_PICTURE:
			self.title = @"Picture Puzzle";
			break;
		case GAME_CLASSIC:
			self.title = @"Classic Sudoku";
			break;
		default:
			break;
	}
	//	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	// Add the Insert button
	UIBarButtonItem *menuButton= [[[UIBarButtonItem alloc]
								   initWithTitle:NSLocalizedString(@"Menu", @"")
								   style:UIBarButtonItemStyleBordered
								   target:self
								   action:@selector(menuAction:)] autorelease];
	
	self.navigationItem.rightBarButtonItem = menuButton;
	
#ifdef TEST_WIN
	UIBarButtonItem *winButton= [[[UIBarButtonItem alloc]
								   initWithTitle:NSLocalizedString(@"Win", @"")
								   style:UIBarButtonItemStyleBordered
								   target:self
								   action:@selector(winAction:)] autorelease];
	
	self.navigationItem.rightBarButtonItem = winButton;
#endif
	m_fScale = 1.0f;
	
	if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
		m_fScale = [UIScreen mainScreen].scale;
	}
	
	if ([[[UIDevice currentDevice] model] isEqualToString:@"iPad"]) {
		m_fScale = 1.0;	
	}

	NSString* strBg;
	if (g_GameOptionInfo.m_nBgType == BG_LIGHT)
		strBg =[NSString stringWithFormat:@"gamebg%d_light", g_GameOptionInfo.m_nGameType];
	else
		strBg =[NSString stringWithFormat:@"gamebg%d_dark", g_GameOptionInfo.m_nGameType];

	UIImage* imgBg = [[UIImage imageNamed:SHImageString(strBg, @"jpg")] retain];
	UIImageView* bg = [[UIImageView alloc] initWithImage:imgBg];
	[self.view addSubview:bg];
	[imgBg release];
	[bg release];
	
	[self loadImages];
	[self initialize];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (m_bWin == FALSE) {
        g_GameOptionInfo.m_bEnableResume = TRUE;
        [g_GameOptionInfo saveGameResume];
    }
	[super viewWillDisappear:animated];
	if (m_bHideNavBar)
		[self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	//	[self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	for (int i = 0; i < 9; i ++) {
		CGImageRelease(m_imgNumbers[i]);
		CGImageRelease(m_imgRedNumbers[i]);
		CGImageRelease(m_imgOnNumbers[i]);
	}
//	for (int x = 0; x < 9; x ++) {
//		for (int y = 0; y < 9; y ++) {
//			CGImageRelease(m_imgPickPacks[x][y]);
//		}
//	}
	//delete m_pSudokuEngine;
	[self destroyViews];
    [super dealloc];
}

-(void) destroyViews {
	if (m_nGameType != GAME_CLASSIC) {
		[m_viewNumberBar removeFromSuperview];
		[m_viewNumberBar release];
		[m_imgSelPuzzleBorder removeFromSuperview];
		[m_imgSelPuzzleBorder release];
		[m_imgSelNumber removeFromSuperview];
		[m_imgSelNumber release];
		[m_btnUp removeFromSuperview];
		[m_btnUp release];
		[m_btnDown removeFromSuperview];
		[m_btnDown release];
		[m_imgWin removeFromSuperview];
		[m_imgWin release];
		[m_viewResult removeFromSuperview];
		[m_viewResult release];
		m_vectorPicIndex.clear();
		for (int i = 0; i < m_arrayTileViews.count; i ++) {
			TileView* tile = (TileView*)[m_arrayTileViews objectAtIndex:i];
			[tile removeFromSuperview];
		}
	}
	else {
		for (int i = 0; i < m_arrayTileViews.count; i ++) {
			NumberTileView* tile = (NumberTileView*)[m_arrayTileViews objectAtIndex:i];
			[tile removeFromSuperview];
		}
		for (int i = 0; i < m_arrayNumberBtn.count; i ++) {
			UIButton* btn = (UIButton*)[m_arrayNumberBtn objectAtIndex:i];
			[btn removeFromSuperview];
		}
		[m_arrayNumberBtn removeAllObjects];
		[m_arrayNumberBtn release];
        [m_btnClear removeFromSuperview];
		[m_btnClear release];
        [m_btnPencil removeFromSuperview];
		[m_btnPencil release];
        [m_imgNoMark removeFromSuperview];
		[m_imgNoMark release];
	}
	
    [m_imgSelX removeFromSuperview];
    [m_imgSelX release];
    [m_imgSelY removeFromSuperview];
    [m_imgSelY release];
    [m_imgSelTile removeFromSuperview];
    [m_imgSelTile release];
    [m_imgBoardLine removeFromSuperview];
    [m_imgBoardLine release];
    [m_viewBoard removeFromSuperview];
    [m_viewBoard release];
    [m_scrollBoardView removeFromSuperview];
    [m_scrollBoardView release];
    
	[m_arrayTileViews removeAllObjects];
	[m_arrayTileViews release];
	for (int x = 0; x < 9; x ++) {
		for (int y = 0; y < 9; y ++) {
            if (m_imgPickPacks[x][y])
                CGImageRelease(m_imgPickPacks[x][y]);
            m_imgPickPacks[x][y] = nil;
		}
	}
}
-(void) returnMainMenu {
	m_bHideNavBar = YES;
	g_GameOptionInfo.m_bGameState = FALSE;
	SudokuAppDelegate* delegate = [UIApplication sharedApplication].delegate;
	[self.navigationController popToViewController:delegate.viewMainMenuController animated:TRUE];
	
}
-(void) menuAction:(id)sender {
	[self returnMainMenu];
}
-(void) winAction:(id)sender {
	[self procGameWin];
//	SudokuAppDelegate* delegate = [UIApplication sharedApplication].delegate;
//	[self.navigationController popToViewController:delegate.viewMainMenuController animated:TRUE];
}

-(void) initialize {
//	for (int x = 0; x < 9; x ++) {
//		for (int y = 0; y < 9; y ++) {
//			m_arrayUsed[x][y] = [[NSMutableArray alloc] init];
//		}
//	}
	g_GameOptionInfo.m_bGameState = TRUE;
	
	m_nSelNumberBarId = -1;
	m_nSelX = -1;
	m_nSelY = -1;
	m_nSelectNumber = -1;
	m_bHideNavBar = NO;
	m_nOldTouchedDrawTileId = -1;
	m_bWin = FALSE;
	m_nGameStartTime = [NSDate timeIntervalSinceReferenceDate];

	m_nGameType = g_GameOptionInfo.m_nGameType;
	m_pSudokuEngine = g_pSudokuEngine;
	m_pSudokuEngine->initialize();
	
	NSString* strProblem;
//	strProblem = [g_GameOptionInfo.m_arrayProblem objectAtIndex:g_GameOptionInfo.m_nSelectedStage];
	int nParam, nStage;
	if (g_GameOptionInfo.m_nGameType == GAME_CLASSIC) {
		nParam = g_GameOptionInfo.m_nLevel;
		nStage = [g_GameOptionInfo getClassicCompletedCount:nParam];
	}		
	else {
		nParam = g_GameOptionInfo.m_nSelectedPack;
		nStage = g_GameOptionInfo.m_nSelectedStage;
	}
	if (g_GameOptionInfo.m_bResumeGame == FALSE) {
		strProblem = [g_GameOptionInfo getProblem:g_GameOptionInfo.m_nGameType param:nParam stage:nStage];
	}
	else {
		strProblem = g_GameOptionInfo.m_strResumeGivenKifu;
	}

//	NSLog(strProblem);
	char szBuf[128] = "";
	[strProblem getCString:szBuf maxLength:82 encoding:NSASCIIStringEncoding];
	m_pSudokuEngine->SetProblem(szBuf);
	
	if (g_GameOptionInfo.m_bResumeGame) {
		char szBuf[128] = "";
		[g_GameOptionInfo.m_strResumeKifu getCString:szBuf maxLength:82 encoding:NSASCIIStringEncoding];
		m_pSudokuEngine->SetResumeKifu(szBuf);
		g_GameOptionInfo.m_bEnableResume = FALSE;
		if (m_nGameType == GAME_CLASSIC) {
			m_pSudokuEngine->SetResumeSmallKifu(g_GameOptionInfo.m_strResumeSmallKifu);
		}
		m_bHideNavBar = YES;
	}
	
	if (m_nGameType != GAME_CLASSIC)
		m_pSudokuEngine->OnSolve();
#ifdef TEST_SOLVE
	if (m_nGameType == GAME_CLASSIC)
		m_pSudokuEngine->OnSolve();
	//test code
	for (int y = 0; y < 9; y ++) {
		NSMutableString* strSolve = [[NSMutableString alloc] init];
		for (int x = 0; x < 9; x ++) {
			[strSolve appendFormat:@"%d ", m_pSudokuEngine->GetSolvedTile(x, y)];
		}
		NSLog(strSolve);
		[strSolve release];
	}
//	m_pSudokuEngine->SetProblem(szBuf);
#endif
	//end
	//NSLog(strProblem);
	
	CGRect rt = [self getBoardRect];
	m_fTileWidth = rt.size.width / 9;
	m_fTileHeight = rt.size.height / 9;
	[self createNumberButtons];
	[self createUpDownBtn];
    
    [self createBoardScrollView];
	[self createTileViews];
	[self createSelImageView];
	[self createGameResultView];
	g_GameOptionInfo.m_bResumeGame = FALSE;
}
-(UIImage*) getStageImage:(int)stage {
	UIImage* img;
	NSString* strPack;
	
	if (g_GameOptionInfo.m_nSelectedPack < 4) {
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
		//strPack = [NSString stringWithFormat:@"picpack%02d", g_GameOptionInfo.m_nSelectedPack];
		//img = [[UIImage imageNamed:SHImageString(strPack, @"png")] retain];;
        NSString* strImg = [NSString stringWithFormat:@"%@%02d.jpg", [g_GameOptionInfo getPackName:g_GameOptionInfo.m_nSelectedPack],stage+1];
        img = [[UIImage imageNamed:strImg] retain];

	}
	return [img autorelease];
}
-(void) loadPackImage{
	UIImage* imgPackOrg = [[self getStageImage:g_GameOptionInfo.m_nSelectedStage] retain];
	UIImage* imgPack;
//	imgPack = [imgPackOrg stretchableImageWithLeftCapWidth:m_sizeTile.width*9 topCapHeight:m_sizeTile.width*9];
    // リサイズ例文（サイズを指定する方法）
    CGFloat width = m_sizeTile.width*9;  // リサイズ後幅のサイズ
    CGFloat height = m_sizeTile.height*9;  // リサイズ後高さのサイズ
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [imgPackOrg drawInRect:CGRectMake(0, 0, width, height)];
    imgPack = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();     
    CGSize totalsize = imgPackOrg.size;
    CGSize size = CGSizeMake(totalsize.width/9.0f, totalsize.height/9.0f);
//    size.width = CGImageGetWidth(imgPack);
//    size.height = CGImageGetHeight(imgPack);
	for (int x = 0; x < 9; x ++) {
		for (int y = 0; y < 9; y ++) {
			CGRect rt = CGRectMake(x*size.width, y*size.height, size.width, size.height);
			m_imgPickPacks[x][y] = CGImageCreateWithImageInRect(imgPackOrg.CGImage, rt);
		}
	}
	[imgPackOrg release];
}
-(void) loadImages {
	memset(m_imgNumbers, 0, sizeof(m_imgNumbers));
	memset(m_imgRedNumbers, 0, sizeof(m_imgRedNumbers));
	memset(m_imgOnNumbers,0, sizeof(m_imgOnNumbers));
	memset(m_imgPickPacks, 0, sizeof(m_imgPickPacks));
	NSString* str;
	NSString* strRed;
	NSString* strOn;
	switch (g_GameOptionInfo.m_nToggleIconType) {
		case TOGGLE_NUMBERS:
			str = @"number_given";
			strRed = @"number_red";
			strOn = @"number_entry";
			break;
		case TOGGLE_COLORS:
			str = @"color_given";
			strRed = @"color_red";
			strOn = @"color_entry";
			break;
		case TOGGLE_SYMBOLS:
			str = @"symbol_given";
			strRed = @"symbol_red";
			strOn = @"symbol_entry";
			break;
		default:
			break;
	}	
	CGImageRef imgRef = [UIImage imageNamed:SHLargeImageString(str, @"png")].CGImage;
	CGImageRef imgRefRed = [UIImage imageNamed:SHLargeImageString(strRed, @"png")].CGImage;
	CGImageRef imgRefOn = [UIImage imageNamed:SHLargeImageString(strOn, @"png")].CGImage;
    CGSize size;
	size.width = CGImageGetWidth(imgRef)/9;
	size.height = CGImageGetHeight(imgRef);
	CGRect rt;
	for (int i = 0; i < 9; i ++) {
		rt = CGRectMake(i*size.width, 0, size.width, size.height);
		m_imgNumbers[i] = CGImageCreateWithImageInRect(imgRef, rt);
		m_imgRedNumbers[i] = CGImageCreateWithImageInRect(imgRefRed, rt);
		m_imgOnNumbers[i] = CGImageCreateWithImageInRect(imgRefOn, rt);
	}
	//str = [NSString stringWithFormat:@"picpack%02d", g_GameOptionInfo.m_nSelectedPack];
	if (g_GameOptionInfo.m_nGameType == GAME_PICTURE) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			m_sizeTile.width = 35;
			m_sizeTile.height = 35;
		}
		else {
			m_sizeTile.width = 81;
			m_sizeTile.height = 81;
		}
	}
    else {
        UIImage* imgSize = [UIImage imageNamed:SHImageString(str, @"png")];
        m_sizeTile = CGSizeMake(imgSize.size.width/9.0f, imgSize.size.height);
    }
	
//	UIImage* imgPackOrg = [[self getStageImage:g_GameOptionInfo.m_nSelectedStage] retain];
//	UIImage* imgPack;
//	imgPack = [imgPackOrg stretchableImageWithLeftCapWidth:m_sizeTile.width*9 topCapHeight:m_sizeTile.width*9];
//	if (g_GameOptionInfo.m_nGameType != GAME_PICTURE && imgPackOrg.size.width != m_sizeTile.width*9)
//	{
//		imgPack = [imgPackOrg stretchableImageWithLeftCapWidth:m_sizeTile.width*9 topCapHeight:m_sizeTile.width*9];
//	}
//	else {
//		m_sizeTile.width = CGImageGetWidth(imgPackOrg.CGImage)/9;
//		m_sizeTile.height = CGImageGetHeight(imgPackOrg.CGImage)/9;
//		imgPack = imgPackOrg;
//	}

//	for (int x = 0; x < 9; x ++) {
//		for (int y = 0; y < 9; y ++) {
//			rt = CGRectMake(x*m_sizeTile.width, y*m_sizeTile.height, m_sizeTile.width, m_sizeTile.height);
//			m_imgPickPacks[x][y] = CGImageCreateWithImageInRect(imgPack.CGImage, rt);
//		}
//	}
	m_sizeTile.width *= m_fScale;
	m_sizeTile.height *= m_fScale;
	[self loadPackImage];
	m_sizeTile.width /= m_fScale;
	m_sizeTile.height /= m_fScale;
//	[imgPackOrg release];
}
-(void) createTileViews {
	UIImage* imgSel = [[UIImage imageNamed:SHImageString(@"select", @"png")] retain];
	m_imgSelPuzzleBorder = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, m_sizeTile.width, m_sizeTile.height)];
	m_imgSelPuzzleBorder.image = imgSel;
	m_imgSelNumber = [[UIImageView alloc] initWithImage:imgSel];
	UIImage* imgTileSel = [[UIImage imageNamed:SHImageString(@"sel_drawtile", @"png")] retain];

	m_arrayTileViews = [[NSMutableArray alloc] init];
	m_vectorPicIndex.reserve(100);
	int nType = g_GameOptionInfo.m_nGameType;
	CGImageRef imgPack, imgNumber, imgSelect, imgRed;
	BOOL bGiven;
	for (int x= 0; x < 9; x ++) {
		for (int y = 0; y < 9; y ++) {
			bGiven = m_pSudokuEngine->IsGiven(x, y);
			int nTile = m_pSudokuEngine->GetTile(x, y)-1;
			switch (nType) {
				case GAME_CLASSIC:
					imgPack = nil;
					imgRed = nil;
					if (bGiven) {
						imgNumber = m_imgNumbers[nTile];
					}						
					else if (nTile >= 0) {
						imgNumber = m_imgOnNumbers[nTile];
					}						
					else
						imgNumber = nil;
					if (nTile >= 0)
						imgRed = m_imgRedNumbers[nTile];
					break;
				case GAME_PICTURE:
					imgPack = m_imgPickPacks[x][y];
					imgNumber = nil;
					break;
				case GAME_PUZZLE:
					imgPack = m_imgPickPacks[x][y];
					if (bGiven)
						imgNumber = m_imgNumbers[nTile];
					else {
						int nT = m_pSudokuEngine->GetSolvedTile(x, y)-1;
						if (nT >= 0) {
							imgNumber = m_imgOnNumbers[nT];
							if (nTile >= 0 && nTile != nT)
								NSLog(@"Solve error!");
						}
						else {
							imgNumber = nil;
							NSLog(@"Solve error!=1");
						}
					}
					break;
				default:
					break;
			}

			imgSelect = nil;
			if (bGiven) {
				imgSelect = nil;
			}
			else {
				if (nType != GAME_CLASSIC && nTile < 0) {
					m_vectorPicIndex.push_back(x*9+y);
                }
				imgSelect = imgTileSel.CGImage;
			}
			if (nType != GAME_CLASSIC) {
				TileView* tile = [[TileView alloc] initWithFrame:[self getTileRect:x y:y]];
				[tile setImage:nType given:bGiven picpack:imgPack number:imgNumber select:imgSelect];
				if (nTile >= 0) {
					[tile setFixed];
				}
				tile.hidden = (nTile < 0);
				tile.tag = kTagTile+x*9+y;
                if (nType != GAME_CLASSIC && nTile < 0) {
                    [tile setBoardTile:NO];
                    [self.view addSubview:tile];
                }
                else {
                    [tile setBoardTile:YES];
                    [m_viewBoard addSubview:tile];
                }
                
				[m_arrayTileViews addObject:tile];
				
				[tile release];
			}
			else {
				NumberTileView* tile = [[NumberTileView alloc] initWithFrame:[self getTileRect:x y:y]];
				[tile setImage:bGiven number:imgNumber rednumber:imgRed];
				if (m_pSudokuEngine->IsSmallNumber(x, y)) {
					//kgh
					NSMutableArray* array = m_pSudokuEngine->GetSmallNumbers(x, y);
					for (int i = 0; i < array.count; i ++) {
						int small = [[array objectAtIndex:i] intValue];
						[tile showSmallNumber:small show:TRUE];
					}
					tile.hidden = NO;
				}
				else {
					tile.hidden = (nTile < 0);
				}

				tile.tag = kTagTile+x*9+y;
				[m_arrayTileViews addObject:tile];
				[m_viewBoard addSubview:tile];
				[tile release];
			}

		}
	}
	
	[self.view addSubview:m_imgSelPuzzleBorder];
	[self.view addSubview:m_imgSelNumber];
	m_imgSelPuzzleBorder.hidden = YES;
	m_imgSelNumber.hidden = YES;
	random_shuffle(m_vectorPicIndex.begin(), m_vectorPicIndex.end());
	[self initDrawerTilePos];
	[imgSel release];
	[imgTileSel release];
}
-(void) createSelImageView {
    UIImage* img;
    CGRect rtBoard = [self getBoardRect];
    CGSize size;
    
    img = [[UIImage imageNamed:SHImageString(@"selX_line", @"png")] retain];
    if (m_nGameType == GAME_PICTURE)
        size = CGSizeMake(rtBoard.size.width/9, rtBoard.size.height);
    else
        size = img.size;
    m_sizeSelX = size;
    m_imgSelX = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    m_imgSelX.image = [UIImage imageNamed:SHLargeImageString(@"selX_line", @"png")];
    [m_viewBoard addSubview:m_imgSelX];
    m_imgSelX.hidden = YES;
    [img release];
    
    img = [[UIImage imageNamed:SHImageString(@"selY_line", @"png")] retain];
    if (m_nGameType == GAME_PICTURE)
        size = CGSizeMake(rtBoard.size.width, rtBoard.size.height/9);
    else
        size = img.size;
    m_sizeSelY = size;
    m_imgSelY = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    m_imgSelY.image = [UIImage imageNamed:SHLargeImageString(@"selY_line", @"png")];
    [m_viewBoard addSubview:m_imgSelY];
    m_imgSelY.hidden = YES;
    [img release];
    
    img = [[UIImage imageNamed:SHImageString(@"sel_tile", @"png")] retain];
    m_sizeSelTile = CGSizeMake(m_sizeTile.width*2, m_sizeTile.height*2);
    m_imgSelTile = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, m_sizeTile.width*2, m_sizeTile.height*2)];
    m_imgSelTile.image = [UIImage imageNamed:SHLargeImageString(@"sel_tile", @"png")];
    [m_viewBoard addSubview:m_imgSelTile];
    [img release];
    m_imgSelTile.hidden = YES;

    if (m_nGameType == GAME_CLASSIC) {
        m_imgNoMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SHImageString(@"error", @"png")]];
        [m_viewBoard addSubview:m_imgNoMark];
        m_imgNoMark.hidden = YES;
    }
}
-(void) createGameResultView {
//	if (m_nGameType == GAME_CLASSIC)
//		return;
	m_viewResult = [[GameResultView alloc] initResultView:self];
	CGRect rt = m_viewResult.frame;
	m_viewResult.center = CGPointMake(SCREEN_WIDTH/2, -rt.size.height/2);
	[self.view addSubview:m_viewResult];
}
-(void) hideTileView:(BOOL)bHide x:(int)x y:(int)y {
	UIView* tile = (UIView*)[m_arrayTileViews objectAtIndex:x*9+y];
	tile.hidden = bHide;
}
-(void) procResumeGame {
	if (g_GameOptionInfo.m_bResumeGame == FALSE)
		return;
//	NSString* strProblem = g_GameOptionInfo.m_strResumeKifu;
//	char szBuf[128] = "";
//	[strProblem getCString:szBuf maxLength:82 encoding:NSASCIIStringEncoding];
//	int tiles[BOARD_SIZE][BOARD_SIZE];
//	for(int i=0;i<BOARD_SIZE;i++)
//	{
//		for(int j=0;j<BOARD_SIZE;j++)
//		{
//			tiles[i-1][j-1] = szProblem[j*9+i] - '0';
//		}
//	}
//	for (int x= 0; x < 9; x ++) {
//		for (int y = 0; y < 9; y ++) {
//			bGiven = m_pSudokuEngine->IsGiven(x, y);
//			if (nType == GAME_CLASSIC) {
//				imgPack = nil;
//			}
//			else {
//				imgPack = m_imgPickPacks[x][y];
//			}
//			if (nType != GAME_PICTURE) {
//				if (bGiven) {
//					int nTile = m_pSudokuEngine->GetTile(x, y)-1;
//					imgNumber = m_imgNumbers[nTile];
//				}
//				else if (nType == GAME_PUZZLE) {
//					int nTile = m_pSudokuEngine->GetSolvedTile(x, y)-1;
//					if (nTile >= 0)
//						imgNumber = m_imgOnNumbers[nTile];
//					else {
//						int a = 0;
//						a ++;
//					}
//					
//				}
//				else {
//					imgNumber = nil;
//				}
//			}
//			else {
//				imgNumber = nil;
//			}
//			
//			imgSelect = nil;
//			if (bGiven) {
//				imgSelect = nil;
//			}
//			else {
//				m_vectorPicIndex.push_back(x*9+y);
//			}
//			
//			[tile setImage:nType given:bGiven picpack:imgPack number:imgNumber select:imgSelect];
//			tile.hidden = !bGiven;
//			tile.tag = kTagTile+x*9+y;
//			[m_arrayTileViews addObject:tile];
//			[self.view addSubview:tile];
//			[tile release];
//		}
//	}
//	g_GameOptionInfo.m_bResumeGame = FALSE;
}
-(void) createNumberButtons {
	if (m_nGameType != GAME_CLASSIC)
		return;
	m_arrayNumberBtn = [[NSMutableArray alloc] init];
	NSString* str;
	switch (g_GameOptionInfo.m_nToggleIconType) {
		case TOGGLE_NUMBERS:
			str = @"n%02d";
			break;
		case TOGGLE_COLORS:
			str = @"c%02d_01";
			break;
		case TOGGLE_SYMBOLS:
			str = @"s%02d";
			break;
		default:
			break;
	}
	CGRect rt;
//	UIImage* img = [[UIImage imageNamed:SHImageString(str,@"png")] retain];
//	m_viewNumberBar = [[UIImageView alloc] initWithImage:img];
	CGFloat x,y,w,h,offsetX,offsetY;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		x = 22, y = 762;
		offsetX = 110, offsetY = 100;
		w = 90, h = 90;
	}
	else {
		x = 10, y = 330;
		offsetX = 48, offsetY = 42;
		w = 40, h = 40;
	}
	
	for (int i = 0; i < 9; i ++) {
		rt = CGRectMake(x+offsetX*(i%5), y+offsetY*(i/5), w, h);
		UIButton* btn = [[UIButton alloc] initWithFrame:rt];
		NSString* strImg = [NSString stringWithFormat:str,i+1];
		[btn setBackgroundImage:[UIImage imageNamed:SHImageString(strImg,@"png")] forState:UIControlStateNormal];
		btn.tag = kTagNumberBtn+i;
		[btn addTarget:self action:@selector(onNumber:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:btn];
		[m_arrayNumberBtn addObject:btn];
		[btn release];		
	}
	rt = CGRectMake(x+offsetX*4, y+offsetY, w, h);
	m_btnClear = [[UIButton alloc] initWithFrame:rt];
	m_btnClear.tag = kTagClear;
	[m_btnClear setBackgroundImage:[UIImage imageNamed:SHImageString(@"nx",@"png")] forState:UIControlStateNormal];
	[m_btnClear setBackgroundImage:[UIImage imageNamed:SHImageString(@"nx_01",@"png")] forState:UIControlStateHighlighted];
	[m_btnClear addTarget:self action:@selector(onClear) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:m_btnClear];

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		rt = CGRectMake(580, 772, 146, 146);
	else
		rt = CGRectMake(246, 340, 68, 68);
	m_btnPencil = [[UIButton alloc] initWithFrame:rt];
	m_btnPencil.tag = kTagClear;
	[m_btnPencil setBackgroundImage:[UIImage imageNamed:SHImageString(@"pencil_nor",@"png")] forState:UIControlStateNormal];
	[m_btnPencil addTarget:self action:@selector(onPencil) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:m_btnPencil];
	
	m_bEnablePencil = FALSE;
	//m_viewNumberBar.center = pt;
//	[self.view addSubview:m_viewNumberBar];
//	[img release];
	[self updateNumberBtnState:FALSE];
}
-(void) onNumber:(id)sender {
	UIButton* btn = (UIButton*)sender;
	int number = btn.tag - kTagNumberBtn + 1;
	if (m_nSelX == -1 || m_nSelY == -1)
		return;
	if (m_pSudokuEngine->IsGiven(m_nSelX, m_nSelY))
		return;
	NumberTileView* tile = (NumberTileView*)[m_arrayTileViews objectAtIndex:m_nSelX*9+m_nSelY];
	if (m_bEnablePencil) {
		BOOL bShowSmall = m_pSudokuEngine->SetSmallNumber(m_nSelX, m_nSelY, number);
		tile.hidden = NO;
		if (bShowSmall) {
			[self updateClearBtn:number];
			[tile showSmallNumber:number show:bShowSmall];
			[self changeNumberBtnImage:number selected:bShowSmall];
		}
	}
	else {
		int nTile = m_pSudokuEngine->GetTile(m_nSelX, m_nSelY);
		if (nTile == number) {
			//value = 0;
			return;
		}
		if (m_pSudokuEngine->IsSmallNumber(m_nSelX, m_nSelY)) {
			m_pSudokuEngine->ResetSmallNumber(m_nSelX, m_nSelY);
			[tile hideAllSmallNumber];
		}
		switch (g_GameOptionInfo.m_nLevel) {
			case LEVEL_EASY:
				if (m_pSudokuEngine->SetTileIfValid(m_nSelX, m_nSelY, number)) {
					[tile setNumberImage:m_imgOnNumbers[number-1] rednumber:m_imgRedNumbers[number-1]];
					tile.hidden = NO;
					[self changeSelectNumber:number];
					[self checkCompleted];
				}
				else {
					//kgh
					[self showNoMark:m_nSelX y:m_nSelY];
					[self showRedNumber:number x:m_nSelX y:m_nSelY];
				}
				break;
			case LEVEL_MEDIUM:
				if (m_pSudokuEngine->SetTileIfValid(m_nSelX, m_nSelY, number)) {
					[tile setNumberImage:m_imgOnNumbers[number-1] rednumber:m_imgRedNumbers[number-1]];
					tile.hidden = NO;
					[self changeSelectNumber:number];
					[self checkCompleted];
				}
				else {
					//kgh
					[self showNoMark:m_nSelX y:m_nSelY];
				}
				break;
			case LEVEL_HARD:
				{
					m_pSudokuEngine->SetTileIfAnyOne(m_nSelX, m_nSelY, number);
					[tile setNumberImage:m_imgOnNumbers[number-1] rednumber:m_imgRedNumbers[number-1]];
					tile.hidden = NO;
					//kgh
					[self changeSelectNumber:number];
					[self checkCompleted];
				}
				break;
			default:
				break;
		}
	}
}
-(void) updateClearBtn:(int)nTile {
	m_btnClear.enabled = (nTile > 0);
}
-(void) updatePencilBtn:(int)nTile {
	m_btnPencil.enabled = (nTile <= 0);
}
-(void) onClear {
	NumberTileView* tile = (NumberTileView*)[m_arrayTileViews objectAtIndex:m_nSelX*9+m_nSelY];
	if (m_bEnablePencil) {
		m_pSudokuEngine->ResetSmallNumber(m_nSelX, m_nSelY);
		[tile hideAllSmallNumber];
		tile.hidden = YES;
		for (int i = 0; i < 9; i ++) {
			[self changeNumberBtnImage:i+1 selected:FALSE];
		}
		
	}
	else {
		if (m_nSelX == -1 || m_nSelY == -1)
			return;
		if (m_pSudokuEngine->IsGiven(m_nSelX, m_nSelY))
			return;
		int nTile = m_pSudokuEngine->GetTile(m_nSelX, m_nSelY);
		if (nTile == 0) {
			return;
		}
		[tile setNumberImage:nil rednumber:nil];
		m_pSudokuEngine->SetTile(m_nSelX, m_nSelY, 0);
		m_pSudokuEngine->CalculateUsedTiles();
		[self hideTileView:YES x:m_nSelX y:m_nSelY];
		[self changeSelectNumber:-1];
	}
	m_btnClear.enabled = FALSE;
}
-(void) onPencil {
	[self setPencilState:1-m_bEnablePencil];
	if (m_bEnablePencil) {
		[self showSmallNumbers:m_nSelX y:m_nSelY];
	}
	else {
		NumberTileView* tile = (NumberTileView*)[m_arrayTileViews objectAtIndex:m_nSelX*9+m_nSelY];
		[tile hideAllSmallNumber];
		for (int i = 0; i < 9; i ++) {
			[self changeNumberBtnImage:i+1 selected:FALSE];
		}
	}
}

-(void) setPencilState:(BOOL)bEnable {
	m_bEnablePencil = bEnable;
	NSString* strImage;
	if (m_bEnablePencil)
		strImage = @"pencil_on";
	else
		strImage = @"pencil_nor";
	[m_btnPencil setBackgroundImage:[UIImage imageNamed:SHImageString(strImage,@"png")] forState:UIControlStateNormal];
}
-(void) createUpDownBtn {
	if (m_nGameType == GAME_CLASSIC)
		return;
	UIImage* imgN;
	UIImage* imgP;
	CGRect rt;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		rt = CGRectMake(636, 756, 119, 106);
	}
	else {
		rt = CGRectMake(270, 326, 51, 46);
	}

	m_btnUp = [[UIButton alloc] initWithFrame:rt];
	imgN = [[UIImage imageNamed:SHImageString(@"up_nor", @"png")] retain];
	imgP = [[UIImage imageNamed:SHImageString(@"up_pre", @"png")] retain];
	[m_btnUp setImage:imgN forState:UIControlStateNormal];
	[m_btnUp setImage:imgP forState:UIControlStateHighlighted];
	[m_btnUp addTarget:self action:@selector(onUp) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:m_btnUp];
	[imgN release];
	[imgP release];

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		rt = CGRectMake(636, 854, 119, 106);
	}
	else {
		rt = CGRectMake(270, 369, 51, 46);
	}
	m_btnDown = [[UIButton alloc] initWithFrame:rt];
	imgN = [[UIImage imageNamed:SHImageString(@"down_nor", @"png")] retain];
	imgP = [[UIImage imageNamed:SHImageString(@"down_pre", @"png")] retain];
	[m_btnDown setImage:imgN forState:UIControlStateNormal];
	[m_btnDown setImage:imgP forState:UIControlStateHighlighted];
	[m_btnDown addTarget:self action:@selector(onDown) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:m_btnDown];
	[imgN release];
	[imgP release];
}
-(void) onUp {
	m_nShowDrawLineIndex --;
	if (m_nShowDrawLineIndex < 0)
		m_nShowDrawLineIndex = 0;
	[self setDrawerTilePos:m_nShowDrawLineIndex];
	[self updateBtnState];
	if (m_nOldTouchedDrawTileId != -1 & m_nPickState == PICK_DRAWTILE) {
		if (m_nOldTouchedDrawTileId < m_nShowDrawLineIndex*DRAWER_ROW || m_nOldTouchedDrawTileId >= (m_nShowDrawLineIndex+DRAWER_COL)*DRAWER_ROW) {
			[self setPickState:PICK_NONE];
		}
	}
}
-(void) onDown {
	m_nShowDrawLineIndex ++;
	if (m_nShowDrawLineIndex > m_vectorPicIndex.size()/DRAWER_ROW)
		m_nShowDrawLineIndex = m_vectorPicIndex.size()/DRAWER_ROW - 1;
	[self setDrawerTilePos:m_nShowDrawLineIndex];
	[self updateBtnState];
	if (m_nOldTouchedDrawTileId != -1 & m_nPickState == PICK_DRAWTILE) {
		if (m_nOldTouchedDrawTileId < m_nShowDrawLineIndex*DRAWER_ROW || m_nOldTouchedDrawTileId >= (m_nShowDrawLineIndex+DRAWER_COL)*DRAWER_ROW) {
			[self setPickState:PICK_NONE];
		}
	}
}
-(void) updateBtnState {
	m_btnUp.enabled = (m_nShowDrawLineIndex > 0);
	if (m_vectorPicIndex.size()/DRAWER_ROW < DRAWER_COL || m_nShowDrawLineIndex > m_vectorPicIndex.size()/DRAWER_ROW-DRAWER_COL)
		m_btnDown.enabled = FALSE;
	else {
		m_btnDown.enabled = TRUE;
	}
}

-(void) setSelectedTile:(int)x y:(int)y value:(int)value {
	if (x == -1 || y == -1)
		return;
	if (m_pSudokuEngine->IsGiven(x, y))
		return;
	int nTile = m_pSudokuEngine->GetTile(x, y);
	if (nTile == value) {
		value = 0;
	}

	if (value != -1 && m_pSudokuEngine->SetTileIfValid(x, y, value)) {
		//nTile = value;kgh
		TileView* tile = (TileView*)[m_arrayTileViews objectAtIndex:x*9+y];
		if (value != 0) {
			[tile setNumberImage:m_imgOnNumbers[value-1]];
			nTile = value;
		}
		tile.hidden = !value;
		if ([self isCompleted]) {
			[self procGameWin];
		}
	}
	if (nTile != 0) {
		[self showSelNumber:TRUE];
		[self moveSelNumber:nTile-1];
	}
}
-(CGRect) getTileRect:(int)x y:(int)y {
	CGFloat posX = 0, posY = 0, width, height;
	CGFloat smallX = 0, largeX = 0, startX = 0, startY = 0;
    CGSize size = [self getTileSize];
	width = size.width;
	height = size.height;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		startX = 7;
		startY = 7;
		if (m_nGameType != GAME_PICTURE) {
			smallX = 2;
			largeX = 7;
		}
	}
	else {
		if (m_nGameType != GAME_PICTURE) {
//			smallX = 1, largeX = 2;
//			startX = 2, startY = 7;
			smallX = 1, largeX = 2;
			startX = 2, startY = 2;
		}
		else {
//			startX = 2, startY = 8;
			startX = 2, startY = 2;
		}
        if (m_bZoom) {
            smallX *= 2, largeX *= 2;
			startX *= 2, startY *= 2;
        }
	}

	posX = startX + width*x + (x/3)*largeX + (x-x/3)*smallX;
	posY = startY + height*y + (y/3)*largeX + (y-y/3)*smallX;
	return CGRectMake(posX, posY, width, height);
}

-(CGPoint) getTileCenterPos:(int)x y:(int)y {
	CGRect rt = [self getTileRect:x y:y];
	return CGPointMake(rt.origin.x+rt.size.width/2, rt.origin.y+rt.size.height/2);
}
-(CGRect) getBoardRect {
	CGRect rt;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		if (m_nGameType != GAME_PICTURE)
			rt = CGRectMake(0, 0, 740, 740);
		else
			rt = CGRectMake(0, 0, 740, 740);
	}
	else {
        if (m_bZoom == NO)
            rt = CGRectMake(0, 0, 320, 320);
        else
            rt = CGRectMake(0, 0, BOARDSIZE_ZOOMIN, BOARDSIZE_ZOOMIN);
	}

	return rt;
}
-(CGPoint) getBoardCenterPos {
	CGRect rt = [self getBoardRect];
	return CGPointMake(rt.origin.x+rt.size.width/2, rt.origin.y+rt.size.height/2);
}
-(CGRect) getDrawerRect {
	CGRect rt;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		if (m_nGameType == GAME_CLASSIC)
			rt = CGRectMake(20, 20, 0, 0);
		else {
			rt = CGRectMake(24, 772, 100*DRAWER_ROW, 106*2);
		}
	}
	else {
		rt = CGRectMake(12, 322, 242, 106);
	}

	return rt;
}
-(CGSize) getTileSize {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return m_sizeTile;
    else {
        if (m_bZoom)
            return CGSizeMake(m_sizeTile.width*2, m_sizeTile.height*2);
        else
            return m_sizeTile;
    }
}
-(CGRect) getDrawerTileRect:(int) index {
	CGFloat x, y, offsetX, offsetY;//kgh-
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		x = 24;
		y = 770;
		offsetX = 100;
		offsetY = 102;
	}
	else {
		x = 14;
		y = 330;
		offsetX = 41;
		offsetY = 42;
	}
	return CGRectMake(x+(index%DRAWER_ROW)*offsetX, y+(index/DRAWER_ROW)*offsetY, m_sizeTile.width, m_sizeTile.height);
}
-(int) getBoardTileIndex:(CGPoint)pos {
	CGRect rect = [self getBoardRect];
	if (CGRectContainsPoint(rect, pos) == FALSE) {
		return -1;
	}
    CGFloat width, height;
	width = rect.size.width / 9;
	height = rect.size.height / 9;

	int nSelX, nSelY;
    if (m_bZoom) {
        CGPoint ptOffset = m_scrollBoardView.contentOffset;
        nSelX = (pos.x - rect.origin.x+ptOffset.x) / width;
        nSelY = (pos.y - rect.origin.y+ptOffset.y) / height;
    }
    else {
        nSelX = (pos.x - rect.origin.x) / width;
        nSelY = (pos.y - rect.origin.y) / height;
    }
	return nSelX*9+nSelY;
}
-(int) getDrawerTileIndex:(CGPoint)pt {
	CGRect rt;
	int i;
	int nIndex = -1;
	for (i = 0; i < DRAWER_ROW*DRAWER_COL; i ++) {
		rt = [self getDrawerTileRect:i];
		if (CGRectContainsPoint(rt, pt))
			break;
	}
	if (i != DRAWER_ROW*DRAWER_COL) {
	 	nIndex = m_nShowDrawLineIndex*DRAWER_ROW+i;
		int nCount = m_vectorPicIndex.size();
		if (nCount <= nIndex) {
			nIndex = -1;
		}
	}
	return nIndex;
}
-(void) touchDrawerTile:(int)index {
	int tag = m_vectorPicIndex[index];
	TileView* tile = (TileView*)[m_arrayTileViews objectAtIndex:tag];
	[tile setSelected:TRUE];
}
-(void) releaseTouchedDrawerTile:(int)index {
	int tag = m_vectorPicIndex[index];
	TileView* tile = (TileView*)[m_arrayTileViews objectAtIndex:tag];
	[tile setSelected:FALSE];
}
-(BOOL) isRightPlace:(int)x y:(int)y {
	int tag = m_vectorPicIndex[m_nTouchedDrawTileId];
	TileView* tile = (TileView*)[m_arrayTileViews objectAtIndex:tag];
	if (tile.tag-kTagTile == x*9+y) {
		return TRUE;
	}
	else {
		return FALSE;
	}

}
-(BOOL) isRightDrawTile:(int)tileID {
	int tag = m_vectorPicIndex[tileID];
	TileView* tile = (TileView*)[m_arrayTileViews objectAtIndex:tag];
	if (tile.tag-kTagTile == m_nSelX*9+m_nSelY) {
		return TRUE;
	}
	else {
		return FALSE;
	}
}

-(void) setPickState:(int)state {
	m_nPickState = state;
	if (state == PICK_DRAWTILE) {
		[self touchDrawerTile:m_nOldTouchedDrawTileId];
	}
	else if (state == PICK_NONE){
		if (m_nOldTouchedDrawTileId != -1) {
			[self releaseTouchedDrawerTile:m_nOldTouchedDrawTileId];
			m_nOldTouchedDrawTileId = -1;
		}
	}

//	[self showSelPuzzleBorder:(state == PICK_BOARD)];
    [self showSelLines:(state == PICK_BOARD)];
}
-(void) showSelPuzzleBorder:(BOOL)bShow {
//	m_imgSelPuzzleBorder.hidden = !bShow;
}
-(void) moveSelPuzzleBorder:(int)x y:(int)y {
	m_imgSelPuzzleBorder.center = [self getTileCenterPos:x y:y];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (m_bWin) {
		return;
	}
	UITouch* touch = [touches anyObject];
	if ([touch tapCount] == 1 && [touches count] == 1) {
		CGPoint pos = [touch locationInView:self.view];
		CGRect rect;
		if (m_nGameType == GAME_CLASSIC) {
			rect = m_viewNumberBar.frame;
			if (CGRectContainsPoint(rect, pos)) {
				CGFloat x = (pos.x - rect.origin.x);
				int nSel = x / (rect.size.width/9);
				[self setSelectedTile:m_nSelX y:m_nSelY value:nSel+1];
				return;
			}
			rect = [self getBoardRect]; 
			if (CGRectContainsPoint(rect, pos)) {
				int nSelX = (pos.x - rect.origin.x) / m_fTileWidth;
				int nSelY = (pos.y - rect.origin.y) / m_fTileHeight;
				if (m_pSudokuEngine->IsGiven(nSelX, nSelY))
					return;
				[self moveSelLines:nSelX y:nSelY];
			}
		}
		else {
			//kgh
			rect = [self getDrawerRect];
			if (CGRectContainsPoint(rect, pos)) {
				[self pickInDrawerTile:pos];
				return;
			}
			rect = [self getBoardRect]; 
			if (CGRectContainsPoint(rect, pos)) {
				int nSelX = (pos.x - rect.origin.x) / m_fTileWidth;
				int nSelY = (pos.y - rect.origin.y) / m_fTileHeight;
				if (m_pSudokuEngine->GetTile(nSelX, nSelY) != 0)
					return;
				if (m_nPickState == PICK_DRAWTILE) {
					if ([self isRightPlace:nSelX y:nSelY]) {
						//kgh
                        [self moveSelLines:nSelX y:nSelY];
						[self moveDrawTileToPlace];
						m_nSelX = nSelX;
						m_nSelY = nSelY;
					}
                    else {
                        [self setPickState:PICK_NONE];//kgh
                    }
				}
				else if (m_nPickState == PICK_NONE || m_nPickState == PICK_BOARD) {
                    [self moveSelLines:nSelX y:nSelY];
					[self setPickState:PICK_BOARD];
					m_nSelX = nSelX;
					m_nSelY = nSelY;
				}
			}
		}

	}
}
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (m_bWin)
        return;
	UITouch* touch = [touches anyObject];
	if ([touch tapCount] == 1 && [touches count] == 1) {
		CGPoint pos = [touch locationInView:self.view];
		if (m_nGameType != GAME_CLASSIC) {			
			if (m_bPick) {
				[self moveSelectedDrawerTile:pos];
			}
		}
		
	}
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (m_bWin)
        return;
	UITouch* touch = [touches anyObject];
//	if ([touch tapCount] == 1 && [touches count] == 1) 
	{
		CGPoint pos = [touch locationInView:self.view];
		if (m_nGameType != GAME_CLASSIC) {			
			if (m_bPick) {
				[self pickOutDrawerTile:pos];
			}
		}
	}
}

-(void) updateNumberBtnState:(BOOL)bEnable {
	for (int i = 0; i < 9; i ++) {
		UIButton* btn = (UIButton*)[m_arrayNumberBtn objectAtIndex:i];
		btn.enabled = bEnable;
	}
	m_btnPencil.enabled = bEnable;
	m_btnClear.enabled = bEnable;
}
-(void) changeSelectNumber:(int)number {
	if (m_nSelectNumber == number)
		return;
	if (m_nSelectNumber > 0) {
		[self changeNumberBtnImage:m_nSelectNumber selected:FALSE];
	}
	if (number > 0)
		[self changeNumberBtnImage:number selected:TRUE];
	m_nSelectNumber = number;
	[self updateClearBtn:number];
	[self updatePencilBtn:number];
}
-(void) changeNumberBtnImage:(int)number selected:(BOOL)bSelected {
	if (number <= 0) {
		return;
	}
	NSString* str;
	switch (g_GameOptionInfo.m_nToggleIconType) {
		case TOGGLE_NUMBERS:
			if (bSelected)
				str = @"n%02d_01";
			else
				str = @"n%02d";
			break;
		case TOGGLE_COLORS:
			if (bSelected)
				str = @"c%02d";
			else
				str = @"c%02d_01";
			break;
		case TOGGLE_SYMBOLS:
			if (bSelected)
				str = @"s%02d_01";
			else
				str = @"s%02d";
			break;
		default:
			break;
	}
	UIButton* btn = (UIButton*)[m_arrayNumberBtn objectAtIndex:number-1];
	NSString* strImage = [NSString stringWithFormat:str, number];
	[btn setBackgroundImage:[UIImage imageNamed:SHImageString(strImage, @"png")] forState:UIControlStateNormal];
}
-(void) showNoMark:(int)x y:(int)y {
	m_imgNoMark.center = [self getTileCenterPos:x y:y];
	m_imgNoMark.alpha = 1.0f;
	m_imgNoMark.hidden = NO;
	[self hideTileView:YES x:x y:y];
	[self performSelector:@selector(hideNoMark) withObject:nil afterDelay:0.4f];
}
-(void) hideNoMark {
	[self setHideNoMarkAnim];
}
-(void) setHideNoMarkAnim {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDidStopSelector:@selector(stopHideNoMarkAnim)];
	// アニメーションをコミット
	m_imgNoMark.alpha = 0.0f;
	[UIView commitAnimations];
}
-(void) stopHideNoMarkAnim {
	m_imgNoMark.hidden = YES;
	[self hideTileView:NO x:m_nSelX y:m_nSelY];
}
-(void) showRedNumber:(int)number x:(int)x y:(int)y {
	if (number <= 0)
		return;
	int i;
	//col
	for (i = 0; i < 9; i ++) {
		if (number == m_pSudokuEngine->GetTile(i, y)){
			NumberTileView* tile = (NumberTileView*)[m_arrayTileViews objectAtIndex:i*9+y];
			if ([tile isShowRedNumber] == FALSE)
				[tile showRedNumber];
		}
	}
	//row
	for (i = 0; i < 9; i ++) {
		if (number == m_pSudokuEngine->GetTile(x, i)){
			NumberTileView* tile = (NumberTileView*)[m_arrayTileViews objectAtIndex:x*9+i];
			if ([tile isShowRedNumber] == FALSE)
				[tile showRedNumber];
		}
	}
	int nBaseX = (x/3)*3;
	int nBaseY = (y/3)*3;
	for (i = nBaseX; i < nBaseX+3; i ++) {
		for (int j = nBaseY; j < nBaseY+3; j ++) {
			if (number == m_pSudokuEngine->GetTile(i, j)){
				NumberTileView* tile = (NumberTileView*)[m_arrayTileViews objectAtIndex:i*9+j];
				if ([tile isShowRedNumber] == FALSE)
					[tile showRedNumber];
			}
		}
	}
}
-(void) showSmallNumbers:(int)x y:(int)y {
	if (m_pSudokuEngine->IsSmallNumber(x, y) == FALSE) {
		return;
	}
	NumberTileView* tile = (NumberTileView*)[m_arrayTileViews objectAtIndex:x*9+y];
	NSMutableArray* array = m_pSudokuEngine->GetSmallNumbers(x, y);
	for (int i = 0; i < array.count; i ++) {
		int small = [[array objectAtIndex:i] intValue];
		[tile showSmallNumber:small show:TRUE];
		[self changeNumberBtnImage:small selected:TRUE];
	}
}
-(void) showSelNumber:(BOOL)bShow {
	m_imgSelNumber.hidden = !bShow;
}
-(void) moveSelNumber:(int)number {
	if (m_nSelNumberBarId == number)
		return;
	if (m_nSelNumberBarId == -1) {
		[self setSelNumberViewPos:number];
	}
	else {
		CGPoint center = m_imgSelNumber.center;
		// アニメーション設定開始
		[UIView beginAnimations:nil context:NULL];
		// 0.1秒かけて
		[UIView setAnimationDuration:0.1];
		// 位置を真ん中に移動する
		CGRect rt = m_viewNumberBar.frame;
		CGFloat nCellW = rt.size.width / 9;
		CGFloat x = (number-m_nSelNumberBarId)*nCellW;
		//CGAffineTransform trans = CGAffineTransformMakeTranslation(x, 0);
		// Affine変換
		m_imgSelNumber.center = CGPointMake(center.x+x, center.y);
		// アニメーションをコミット
		[UIView commitAnimations];
	}
	m_nSelNumberBarId = number;
	m_nSelectNumber = number+1;
}
-(void) setSelNumberViewPos:(int)number {
	CGRect rt = m_viewNumberBar.frame;
	CGFloat nCellW = rt.size.width / 9;
	CGFloat nCellH = rt.size.height;
	m_imgSelNumber.frame = CGRectMake(rt.origin.x + nCellW*number + (nCellW-m_imgSelNumber.bounds.size.width)/2, rt.origin.y + (nCellH-m_imgSelNumber.bounds.size.height)/2, m_imgSelNumber.bounds.size.width, m_imgSelNumber.bounds.size.height);
}

-(void) showSelLines:(BOOL)bShow {
//	m_imgSelPuzzleBorder.hidden = !bShow;
    [m_viewBoard bringSubviewToFront:m_imgSelX];
    [m_viewBoard bringSubviewToFront:m_imgSelY];
    [m_viewBoard bringSubviewToFront:m_imgSelTile];
	m_imgSelX.hidden = !bShow;
	m_imgSelY.hidden = !bShow;
	m_imgSelTile.hidden = !bShow;
}
-(void) showSelTileView:(BOOL)bShow {
	m_imgSelTile.hidden = !bShow;
	self.view.userInteractionEnabled = bShow;
}

-(void) moveSelLines:(int)x y:(int)y {
	if (m_nSelX == x && m_nSelY == y)
		return;
	if (m_nSelX == -1 || m_nSelY == -1) {
		[self showSelLines:TRUE];
		[self setSelLinesViewPos:x y:y];
		[self updateNumberBtnState:TRUE];
        m_nSelX = x;
        m_nSelY = y;
        [self resizeSelLineViews];
	}
	else {
		m_nOldSelX = m_nSelX;
		m_nOldSelY = m_nSelY;
		m_nSelX = x;
		m_nSelY = y;
		[self showSelTileView:FALSE];
		if (m_nOldSelX != x) {
			[self moveSelXLine:x];
		}
		else
			[self moveSelYLine:y];
//		CGPoint center = m_imgSelBoard.center;
//		// アニメーション設定開始
//		[UIView beginAnimations:nil context:NULL];
//		// 0.1秒かけて
//		[UIView setAnimationDuration:0.1];
//		// 位置を真ん中に移動する
//		CGRect rt = [self getTileRect:x y:y];
//		//CGAffineTransform trans = CGAffineTransformMakeTranslation(x, 0);
//		// Affine変換
//		m_imgSelBoard.center = CGPointMake(rt.origin.x+m_imgSelBoard.bounds.size.width/2, rt.origin.y+m_imgSelBoard.bounds.size.height/2);
//		// アニメーションをコミット
//		[UIView commitAnimations];
	}
	m_nSelX = x;
	m_nSelY = y;
	//kgh
	for (int i = 0; i < 9; i ++) {
		[self changeNumberBtnImage:i+1 selected:FALSE];
	}
	[self changeSelectNumber:0];
	if (m_pSudokuEngine->IsSmallNumber(x, y)) {
		[self showSmallNumbers:x y:y];
		[self setPencilState:TRUE];
		[self updateClearBtn:1];
	}
	else {
		int nTile = m_pSudokuEngine->GetTile(x, y);
		if (nTile > 0) {
			[self setPencilState:FALSE];
			[self changeSelectNumber:nTile];
		}
		else if (m_bEnablePencil){
			
		}
		[self updateClearBtn:nTile];
		[self updatePencilBtn:nTile];
	}
}
-(void) moveSelXLine:(int)x {
	// アニメーション設定開始
	[UIView beginAnimations:nil context:NULL];
	// 0.1秒かけて
	[UIView setAnimationDuration:0.2];
	[UIView setAnimationDelegate:self];
	// 位置を真ん中に移動する
	CGPoint center = [self getTileCenterPos:m_nSelX y:m_nSelY];
	CGPoint ptBoardCenter = [self getBoardCenterPos];
	m_imgSelX.center = CGPointMake(center.x, ptBoardCenter.y);
	[UIView setAnimationDidStopSelector:@selector(stopMoveSelXLine)];
	// アニメーションをコミット
	[UIView commitAnimations];
}
-(void) moveSelYLine:(int)x {
	// アニメーション設定開始
	[UIView beginAnimations:nil context:NULL];
	// 0.1秒かけて
	[UIView setAnimationDuration:0.2];
	[UIView setAnimationDelegate:self];
	// 位置を真ん中に移動する
	CGPoint center = [self getTileCenterPos:m_nSelX y:m_nSelY];
	CGPoint ptBoardCenter = [self getBoardCenterPos];
	m_imgSelY.center = CGPointMake(ptBoardCenter.x, center.y);
	[UIView setAnimationDidStopSelector:@selector(stopMoveSelYLine)];
	// アニメーションをコミット
	[UIView commitAnimations];
}
-(void) stopMoveSelXLine {
	if (m_nOldSelY != m_nSelY)
		[self moveSelYLine:m_nSelY];
	else {
		[self showSelTileView:TRUE];
		[self setSelLinesViewPos:m_nSelX y:m_nSelY];
	}
}
-(void) stopMoveSelYLine {
	[self showSelTileView:TRUE];
	[self setSelLinesViewPos:m_nSelX y:m_nSelY];
}
-(void) setSelLinesViewPos:(int)x y:(int)y {
	CGPoint center = [self getTileCenterPos:x y:y];
	CGPoint ptBoardCenter = [self getBoardCenterPos];
	m_imgSelX.center = CGPointMake(center.x, ptBoardCenter.y);
    [self.view bringSubviewToFront:m_imgSelX];
	m_imgSelY.center = CGPointMake(ptBoardCenter.x, center.y);
    [self.view bringSubviewToFront:m_imgSelY];
	m_imgSelTile.center = center;
    [self.view bringSubviewToFront:m_imgSelTile];
//	m_imgSelBoard.frame = CGRectMake(rt.origin.x, rt.origin.y, m_imgSelBoard.bounds.size.width, m_imgSelBoard.bounds.size.height);
}

-(void) initDrawerTilePos {
	if (m_nGameType == GAME_CLASSIC)
		return;
	
	CGRect rt;
	m_nShowDrawLineIndex = 0;
	for (int i = 0; i < m_vectorPicIndex.size(); i ++) {
		int nIndex = m_vectorPicIndex[i];
		TileView* tile = (TileView*)[m_arrayTileViews objectAtIndex:nIndex];
		rt = [self getDrawerTileRect:i];
		[tile setPos:CGPointMake(rt.origin.x, rt.origin.y)];
		if (tile.hidden == NO) {
			int a = 0;
			a ++;
		}
		tile.hidden = (i >= (m_nShowDrawLineIndex+DRAWER_COL)*DRAWER_ROW);
	}
	[self updateBtnState];
}
-(void) setDrawerTilePos:(int)showLineIndex {
	CGFloat x, y, offsetX, offsetY;//kgh-
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		x = 24;
		y = 770;
		offsetX = 100;
		offsetY = 102;
	}
	else {
		x = 14;
		y = 330;
		offsetX = 41;
		offsetY = 42;
	}
	
	int nLine, nIndex;
	int nOffsetLine;
	for (int i = 0; i < m_vectorPicIndex.size(); i ++) {
		nIndex = m_vectorPicIndex[i];
		nLine = i / DRAWER_ROW;
		nOffsetLine = nLine - showLineIndex;
		TileView* tile = (TileView*)[m_arrayTileViews objectAtIndex:nIndex];
		[tile setPos:CGPointMake(x+(i%DRAWER_ROW)*offsetX, y+nOffsetLine*offsetY)];
		if (nOffsetLine < 0 || nOffsetLine >= DRAWER_COL)
			tile.hidden = YES;
		else {
			tile.hidden = NO;
		}
	}
}
-(void) pickInDrawerTile:(CGPoint)pt {
	int nIndex = [self getDrawerTileIndex:pt];
	if (nIndex == -1)
		return;
	m_nSelectedDrawTileId = nIndex;
	m_nTouchedDrawTileId = nIndex;
	int tag = m_vectorPicIndex[m_nSelectedDrawTileId];
	m_bPick = TRUE;
	m_tileViewSelected = (TileView*)[m_arrayTileViews objectAtIndex:tag];
	[self.view bringSubviewToFront:m_tileViewSelected];
    if (m_bZoom) {
        CGSize size = [self getTileSize];
        [m_tileViewSelected setResizeAnim:CGRectMake(pt.x-size.width/2, pt.y-size.height/2, size.width, size.height)];
    }
	[self moveSelectedDrawerTile:pt];
}
-(void) pickOutDrawerTile:(CGPoint)pt {
	if (m_bPick == FALSE)
		return;
	int nBoardId = [self getBoardTileIndex:pt];
	if (nBoardId == -1 || nBoardId != (m_tileViewSelected.tag-kTagTile)) {
		//kgh
		int nIndex = [self getDrawerTileIndex:pt];
		if (nIndex != -1 && m_nTouchedDrawTileId == nIndex) {
			if (m_nPickState == PICK_NONE || m_nPickState == PICK_DRAWTILE) {
				if (m_nOldTouchedDrawTileId != -1 && m_nOldTouchedDrawTileId != m_nTouchedDrawTileId)
					[self releaseTouchedDrawerTile:m_nOldTouchedDrawTileId];
				m_nOldTouchedDrawTileId = m_nTouchedDrawTileId;
                [self cancelSelectedDrawerTile];
				[self setPickState:PICK_DRAWTILE];
			}
			else if (m_nPickState == PICK_BOARD){
				if ([self isRightDrawTile:m_nTouchedDrawTileId]) {
					[self moveDrawTileToPlace];
					return;
				}
                else {
                    [self cancelSelectedDrawerTile];
                    [self setPickState:PICK_NONE];
                }
			}

		}
        else {
            [self cancelSelectedDrawerTile];
        }
	}
	else {
		int x = nBoardId/9, y = nBoardId%9;
//		m_tileViewSelected.frame = [self getTileRect:x y:y];
//		[m_tileViewSelected setFixed];
//		[self deleteDrawerTile:m_nSelectedDrawTileId];
//		int nTile = m_pSudokuEngine->GetSolvedTile(x, y);
//		m_pSudokuEngine->SetTile(x, y, nTile);
//		[self checkCompleted];
//		[self setPickState:PICK_NONE];
		[self fixedDrawTileToPlace:x y:y];
	}

	m_bPick = FALSE;
	m_nSelectedDrawTileId = -1;
    if (m_bZoom == NO)
        m_tileViewSelected = nil;
}

-(void) moveDrawTileToPlace {
	if (m_nPickState == PICK_DRAWTILE) {
		[self releaseTouchedDrawerTile:m_nOldTouchedDrawTileId];
		m_nOldTouchedDrawTileId = -1;
	}
	int tag = m_vectorPicIndex[m_nTouchedDrawTileId];
	m_tileViewSelected  = (TileView*)[m_arrayTileViews objectAtIndex:tag];
    [m_tileViewSelected removeFromSuperview];
    [m_viewBoard addSubview:m_tileViewSelected];
	[m_viewBoard bringSubviewToFront:m_tileViewSelected];
    if (m_bZoom) {
        CGSize size = [self getTileSize];
        CGRect fr = m_tileViewSelected.frame;
        CGPoint pt = fr.origin;
        [m_tileViewSelected setResize:CGRectMake(pt.x, pt.y, size.width, size.height)];
    }

	// アニメーション設定開始
	[UIView beginAnimations:nil context:NULL];
	// 0.1秒かけて
	[UIView setAnimationDuration:0.1];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(doneMoveDrawTileToPlace)];
	// 位置を真ん中に移動する
	//CGAffineTransform trans = CGAffineTransformMakeTranslation(x, 0);
	// Affine変換
	m_tileViewSelected.center = [self getTileCenterPos:m_nSelX y:m_nSelY];
	// アニメーションをコミット
	[UIView commitAnimations];
}

-(void) doneMoveDrawTileToPlace {
	[self fixedDrawTileToPlace:m_nSelX y:m_nSelY];
}

static int s_nTestTitleTag = -1;
-(void) fixedDrawTileToPlace:(int)x y:(int)y {
    [m_tileViewSelected removeFromSuperview];
    [m_viewBoard addSubview:m_tileViewSelected];
    s_nTestTitleTag = m_tileViewSelected.tag;
    [m_tileViewSelected setBoardTile:YES];
//	[m_viewBoard bringSubviewToFront:m_tileViewSelected];
	m_tileViewSelected.frame = [self getTileRect:x y:y];
	[m_tileViewSelected setFixed];
    int nTouched = m_nTouchedDrawTileId;
	[self setPickState:PICK_NONE];//kgh
	[self deleteDrawerTile:nTouched];
	int nTile = m_pSudokuEngine->GetSolvedTile(x, y);
	m_pSudokuEngine->SetTile(x, y, nTile);
	m_pSudokuEngine->CalculateUsedTiles();
	m_tileViewSelected = nil;
	[self checkCompleted];
//	[self setPickState:PICK_NONE];
	SudokuAppDelegate* delegate = [UIApplication sharedApplication].delegate;
	[delegate playSoundEffect:0];
}
-(void) moveSelectedDrawerTile:(CGPoint)pt {
	if (m_bPick == FALSE)
		return;
	m_tileViewSelected.center = pt;
}
-(void) cancelSelectedDrawerTile {
	CGPoint center = [m_tileViewSelected getOrgCenterPos];
//    if (m_bZoom) {
//        CGPoint ptCenter = m_tileViewSelected.center;
//        [m_tileViewSelected setResizeAnim:CGRectMake(ptCenter.x-m_sizeTile.width, ptCenter.y-m_sizeTile.height, m_sizeTile.width, m_sizeTile.height)];
//    }
	// アニメーション設定開始
	[UIView beginAnimations:nil context:NULL];
	// 0.1秒かけて
	[UIView setAnimationDuration:0.1];
    [UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(stopCancelSelectedDrawerTile)];
	// 位置を真ん中に移動する
	//CGAffineTransform trans = CGAffineTransformMakeTranslation(x, 0);
	// Affine変換
	m_tileViewSelected.center = center;
	// アニメーションをコミット
	[UIView commitAnimations];
}
-(void) stopCancelSelectedDrawerTile {
    if (m_bZoom) {
        CGPoint ptCenter = m_tileViewSelected.center;
//        CGSize sizeTitle = [self getTileSize];//kgh
        [m_tileViewSelected setResizeAnim:CGRectMake(ptCenter.x-m_sizeTile.width, ptCenter.y-m_sizeTile.height, m_sizeTile.width, m_sizeTile.height)];
        m_tileViewSelected = nil;
    }
}
-(void) deleteDrawerTile:(int)index {
	m_vectorPicIndex.erase(m_vectorPicIndex.begin()+index);
	[self arrangeDrawerTilePos:index];
	[self updateBtnState];
}
-(BOOL) isCorrectDrawerTilePos:(CGPoint)pt {
	int nBoardId = [self getBoardTileIndex:pt];
	if (nBoardId == -1 || nBoardId != (m_tileViewSelected.tag-kTagTile))
		return FALSE;
	return TRUE;
}

-(void) arrangeDrawerTilePos:(int)nStartIndex {
	CGFloat x, y, offsetX, offsetY;//kgh-
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		x = 24;
		y = 770;
		offsetX = 100;
		offsetY = 102;
	}
	else {
		x = 14;
		y = 330;
		offsetX = 41;
		offsetY = 42;
	}
	
	int nLine, nIndex;
	int nOffsetLine, showLineIndex = m_nShowDrawLineIndex;
	CGPoint pos;
	for (int i = nStartIndex; i < m_vectorPicIndex.size(); i ++) {
		nIndex = m_vectorPicIndex[i];
		nLine = i / DRAWER_ROW;
		nOffsetLine = nLine - showLineIndex;
		pos = CGPointMake(x+(i%DRAWER_ROW)*offsetX, y+nOffsetLine*offsetY);
		TileView* tile = (TileView*)[m_arrayTileViews objectAtIndex:nIndex];		
		if (nOffsetLine < 0 || nOffsetLine >= DRAWER_COL) {
			tile.hidden = YES;
			[tile setPos:pos];
		}
		else {
			if (tile.hidden == YES) {
				tile.hidden = NO;
				[tile setPos:pos];
			}
			else
				[self animeDrawerTileView:tile pos:pos];
		}
	}
	[self performSelector:@selector(doneDrawerTilerAnim) withObject:nil afterDelay:03];
	
}
-(void) animeDrawerTileView:(TileView*)tile pos:(CGPoint)pos {
	// アニメーション設定開始
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	// 0.1秒かけて
	[UIView setAnimationDuration:0.1];
	// 位置を真ん中に移動する
	//CGAffineTransform trans = CGAffineTransformMakeTranslation(x, 0);
	// Affine変換
	tile.center = CGPointMake(pos.x + m_sizeTile.width/2, pos.y + m_sizeTile.height/2);
	[UIView setAnimationDidStopSelector:@selector(doneDrawerTilerAnim)];
	// アニメーションをコミット
	[UIView commitAnimations];
}
-(void) doneDrawerTilerAnim {
	[self setDrawerTilePos:m_nShowDrawLineIndex];
}

-(void) checkCompleted {
	//kgh
	if (m_nGameType == GAME_CLASSIC) {
		if (m_pSudokuEngine->CheckSolution() == 0) {
			[self procGameWin];
		}
	}
	else {
		if (m_vectorPicIndex.size() == 0) {
			[self procGameWin];
		}
	}

}
-(BOOL) isCompleted {
	if (m_nGameType == GAME_CLASSIC)
		return m_pSudokuEngine->IsCompleted();
	int nSize = m_vectorPicIndex.size();
	return (nSize == 0);
}
-(void) procGameWin {
    [self zoomOut];
	int nPack, nStage;
	if (m_nGameType == GAME_CLASSIC) {
		nPack = g_GameOptionInfo.m_nLevel;
		nStage = 0;
	}
	else{
		nPack = g_GameOptionInfo.m_nSelectedPack;
		nStage = g_GameOptionInfo.m_nSelectedStage;
	}
	[g_GameOptionInfo solveProblem:m_nGameType pack:nPack stage:nStage];

	m_bWin = TRUE;
	g_GameOptionInfo.m_bGameState = FALSE;
    [self showResultView];
//	if (m_nGameType != GAME_CLASSIC) {
//		
//	}
//	else {
//		self.view.userInteractionEnabled = FALSE;
//		[self startGameWinAnime];
//	}

}
-(void) showResultView {
	m_nGameEndTime = [NSDate timeIntervalSinceReferenceDate];
	[m_viewResult setTime:m_nGameEndTime - m_nGameStartTime];
	[self.view bringSubviewToFront:m_viewResult];
	m_viewResult.hidden = FALSE;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:1.0];
	
	// アニメーションをコミット
	m_viewResult.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
	[UIView commitAnimations];
}
-(void) hideResultView {
	m_viewResult.hidden = YES;
	CGRect rt = m_viewResult.frame;
	m_viewResult.center = CGPointMake(SCREEN_WIDTH/2, -rt.size.height/2);
}

-(void) startGameWinAnime {
	if (m_nGameType != GAME_CLASSIC) {
		return;
	}
	UIImage* img = [[UIImage imageNamed:SHImageString(@"success", @"png")] retain];
	m_imgWin = [[UIImageView alloc] initWithImage:img];
	m_imgWin.center = CGPointMake(SCREEN_WIDTH/2, 0);
	[self.view addSubview:m_imgWin];
	[img release];

	// Bounces the placard back to the center
	CALayer *welcomeLayer = m_imgWin.layer;	
	// Create a keyframe animation to follow a path back to the center
	CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	bounceAnimation.removedOnCompletion = NO;
	
	CGFloat animationDuration = 2.5;
	
	// Create the path for the bounces
	CGMutablePathRef thePath = CGPathCreateMutable();
	
	CGFloat midX = self.view.center.x;
	CGFloat midY = self.view.center.y;
	CGFloat originalOffsetX = m_imgWin.center.x - midX;
	CGFloat originalOffsetY = m_imgWin.center.y - midY;
	CGFloat offsetDivider = 4.0;
	
	BOOL stopBouncing = NO;
	
	// Start the path at the placard's current location
	CGPathMoveToPoint(thePath, NULL, m_imgWin.center.x, m_imgWin.center.y);
	CGPathAddLineToPoint(thePath, NULL, midX, midY);
	
	// Add to the bounce path in decreasing excursions from the center
	while (stopBouncing != YES) {
		CGPathAddLineToPoint(thePath, NULL, midX + originalOffsetX/offsetDivider, midY + originalOffsetY/offsetDivider);
		CGPathAddLineToPoint(thePath, NULL, midX, midY);
		
		offsetDivider += 4;
		animationDuration += 1/offsetDivider;
		if ((abs((int)(originalOffsetX/offsetDivider)) < 6) && (abs((int)(originalOffsetY/offsetDivider)) < 6)) {
			stopBouncing = YES;
		}
	}
	
	bounceAnimation.path = thePath;
	bounceAnimation.duration = animationDuration;
	
	
	// Create a basic animation to restore the size of the placard
	CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
	transformAnimation.removedOnCompletion = YES;
	transformAnimation.duration = animationDuration;
	transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
	
	
	// Create an animation group to combine the keyframe and basic animations
	CAAnimationGroup *theGroup = [CAAnimationGroup animation];
	
	// Set self as the delegate to allow for a callback to reenable user interaction
	theGroup.delegate = self;
	theGroup.duration = animationDuration;
	theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	
	theGroup.animations = [NSArray arrayWithObjects:bounceAnimation, transformAnimation, nil];
	
	
	// Add the animation group to the layer
	[welcomeLayer addAnimation:theGroup forKey:@"animateTextViewToCenter"];
	
	// Set the placard view's center and transformation to the original values in preparation for the end of the animation
	m_imgWin.center = self.view.center;
	m_imgWin.transform = CGAffineTransformIdentity;
	
	CGPathRelease(thePath);
}
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	self.view.userInteractionEnabled = TRUE;
}
-(void) nextPuzzle {
	[self hideResultView];
	int nStage = g_GameOptionInfo.m_nSelectedStage;
	nStage ++;
    if (g_GameOptionInfo.m_nGameType == GAME_CLASSIC) {
        
    }
    else {
        if (nStage >= MAX_STAGE) {
            [self.navigationController popViewControllerAnimated:TRUE];
            return;
        }
        int nProblemState;
        if (g_GameOptionInfo.m_nGameType == GAME_PUZZLE)
            nProblemState = [g_GameOptionInfo getPuzzlePackProblemState:g_GameOptionInfo.m_nSelectedPack stage:nStage];
        else
            nProblemState = [g_GameOptionInfo getPicturePackProblemState:g_GameOptionInfo.m_nSelectedPack stage:nStage];
        if (nProblemState == PROBLEM_LOCK) {
            [self.navigationController popViewControllerAnimated:TRUE];
            return;
        }
    }
	g_GameOptionInfo.m_nSelectedStage = nStage;
//	[g_GameOptionInfo createProblem:g_GameOptionInfo.m_nGameType param:nStage];
	[self destroyViews];
    if (g_GameOptionInfo.m_nGameType != GAME_CLASSIC)
        [self loadPackImage];
	[self initialize];
	[self.view setNeedsDisplay];
}
#pragma mark - Board Scroll method
-(void) lockView {
    self.view.userInteractionEnabled = NO;
}
-(void) unlockView {
    self.view.userInteractionEnabled = YES;
}
//for board scroll
-(void) createBoardScrollView {
	NSString* strLine;

    strLine =[NSString stringWithFormat:@"line gamebg%d_dark", g_GameOptionInfo.m_nGameType];
   
	UIImage* imgLine = [[UIImage imageNamed:SHImageString(strLine, @"png")] retain];
    CGSize size = imgLine.size;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        size = CGSizeMake(320, 320);
    NSLog(@"Board size , w = %f, h = %f", size.width, size.height);
	m_imgBoardLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [m_imgBoardLine setImage:[UIImage imageNamed:SHLargeImageString(strLine, @"png")]];
    m_viewBoard = [[BoardView alloc] initWithRect:CGRectMake(0, 0, size.width, size.height)];
    m_viewBoard.delegate = self;
    CGFloat x, y;
    x = (SCREEN_WIDTH- imgLine.size.width)/2;
    y = 8*SCALE_SCREEN_HEIGHT;
	m_scrollBoardView = [[UIScrollView alloc] initWithFrame: CGRectMake(x, y, imgLine.size.width, imgLine.size.height)];
//	m_scrollBoardView.center = CGPointMake(160, 214);
	m_scrollBoardView.delegate = self;
	m_scrollBoardView.contentSize = CGSizeMake(m_imgBoardLine.frame.size.width, m_imgBoardLine.frame.size.height);
	m_scrollBoardView.maximumZoomScale = 3.0;
	m_scrollBoardView.minimumZoomScale = 1.0;
	m_scrollBoardView.clipsToBounds = YES;
    m_scrollBoardView.bounces = NO;
	[self.view addSubview: m_scrollBoardView];	
    [m_viewBoard addSubview:m_imgBoardLine];
    [m_scrollBoardView addSubview:m_viewBoard];
    m_scrollBoardView.userInteractionEnabled = YES;
//	m_scrollBoardView.center = CGPointMake(160, 160);
    [imgLine release];
}
-(BOOL) isEnableZoomDevice {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (m_nGameType != GAME_CLASSIC)
            return YES;
    }
    return NO;
}
-(CGSize) getZoomBoardSize {
    return CGSizeMake(BOARDSIZE_ZOOMIN, BOARDSIZE_ZOOMIN);
}

- (void) zoomIn: (int)x y:(int) y {
    
	if (m_bZoom == TRUE) {
		return;
	}
	
	[self lockView];
	m_bZoom		= TRUE;
	m_nZoomX	= x;
	m_nZoomY	= y;
    CGSize size = [self getZoomBoardSize];
	m_scrollBoardView.contentSize = size;	
	//self.contentMode = UIViewContentModeRedraw;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.2];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector: @selector(correctBoard)];
	
	CGRect rt = CGRectMake(x*size.width/320.0 - 320/2, 
						   y*size.height/320.0 - 320/2, 320/1, 320/1);
	[m_scrollBoardView scrollRectToVisible:rt animated:NO];
	
	m_viewBoard.frame = CGRectMake(0, 0, size.width, size.height);
    m_imgBoardLine.frame = CGRectMake(0, 0, size.width, size.height);
    [self resizeTileViews];
    [self resizeSelLineViews];
	[UIView commitAnimations];
}
-(void) correctBoard {
	CGAffineTransform transform = CGAffineTransformMakeScale(1, 1);
    CGSize size = [self getZoomBoardSize];
	m_viewBoard.transform = transform;
	m_viewBoard.center = CGPointMake(size.width/2, size.height/2);
	m_viewBoard.frame = CGRectMake(0, 0, size.width, size.height);
	m_imgBoardLine.center = CGPointMake(size.width/2, size.height/2);
    m_imgBoardLine.frame = CGRectMake(0, 0, size.width, size.height);
    [self resizeTileViews];
    [self resizeSelLineViews];
	int nScaleX = m_nZoomX*size.width/320;
	int nScaleY = m_nZoomY*size.height/320;
	NSLog(@"m_nZoomX=%d ,  m_nZoomY=%d", m_nZoomX, m_nZoomY);
	
	if ( nScaleX < 160 ) {
		m_nZoomX = 0;
	}
    else if ( nScaleX > (size.width-160) ) {
        m_nZoomX = 160*size.width/320.0;
	} else {
		m_nZoomX = m_nZoomX*size.width/320.0-160;
	}
	if ( nScaleY < 160 ) {
		m_nZoomY = 0;
	} 
    else if ( nScaleY > (size.height-160)) {
        m_nZoomY = 160*size.height/320.0;
	} else {
		m_nZoomY = m_nZoomY*size.height/320.0-160;
	}
	
	NSLog(@"m_nZoomX=%d ,  m_nZoomY=%d", m_nZoomX, m_nZoomY);
	
	//[boardScrollView setContentOffset:CGPointMake(m_nZoomX-80, m_nZoomY-80) animated:NO]; 
	[m_scrollBoardView setContentOffset:CGPointMake(m_nZoomX, m_nZoomY) animated:NO]; 
	m_scrollBoardView.contentSize = size;	
	[self unlockView];
}
-(void) zoomOut {
	[self lockView];
	
	if (m_bZoom == FALSE) {
		[self completeZoomOut];
		return;
	}
    
	m_bZoom = FALSE;		
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.2];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector: @selector(completeZoomOut)];
	m_scrollBoardView.contentSize = CGSizeMake(320, 320);
	m_viewBoard.frame = CGRectMake(0, 0, 320, 320);	
    m_imgBoardLine.frame = CGRectMake(0, 0, 320, 320);
    [self resizeTileViews];
    [self resizeSelLineViews];
	[UIView commitAnimations];
}
- (void) completeZoomOut {
    [self unlockView];
}
-(void) resizeTileViews {
    int tag;
    TileView* tile;
	for (int x= 0; x < 9; x ++) {
		for (int y = 0; y < 9; y ++) {
            tag = kTagTile+x*9+y;
            tile = (TileView*)[m_viewBoard viewWithTag:tag];
            if (tag == s_nTestTitleTag) {
                NSLog(@"sel tag = %d", s_nTestTitleTag);
            }
            if ([tile isBoardTile] == NO)
                continue;
            [tile setResize:[self getTileRect:x y:y]];
        }
    }
}
-(void) resizeSelLineViews {
    if (m_nSelX == -1 || m_nSelY == -1)
        return;
    CGRect rt = [self getTileRect:m_nSelX y:m_nSelY];
    if (m_bZoom) {
        m_imgSelX.frame = CGRectMake(rt.origin.x, 0, m_sizeSelX.width*2, m_sizeSelX.height*2);
        m_imgSelY.frame = CGRectMake(0, rt.origin.y, m_sizeSelY.width*2, m_sizeSelY.height*2);
        m_imgSelTile.frame = CGRectMake(rt.origin.x-m_sizeSelTile.width/2, rt.origin.y-m_sizeSelTile.height/2, m_sizeSelTile.width*2, m_sizeSelTile.height*2);
    }
    else {
        m_imgSelX.frame = CGRectMake(rt.origin.x, 0, m_sizeSelX.width, m_sizeSelX.height);
        m_imgSelY.frame = CGRectMake(0, rt.origin.y, m_sizeSelY.width, m_sizeSelY.height);
        m_imgSelTile.frame = CGRectMake(rt.origin.x-m_sizeSelTile.width/4, rt.origin.y-m_sizeSelTile.height/4, m_sizeSelTile.width, m_sizeSelTile.height);
    }
}
#pragma mark - Board View Delegate method
-(void) onSingleTouch:(CGPoint)pos {
    if (m_bWin)
        return;
    [self singleTouchOnBoardView:pos];
}
-(void) onDoubleTouch:(CGPoint)pos {
    if (m_bWin || [self isEnableZoomDevice] == NO)
        return;
    if (m_bZoom == NO) {
        [self zoomIn:pos.x y:pos.y];
    }
    else {
        [self zoomOut];
    }
}
- (void) onZoomin:(CGPoint) pos {
    if (m_bWin || [self isEnableZoomDevice] == NO)
        return;
    if (self.view.userInteractionEnabled == NO)
        return;
    if (m_bZoom == NO) {
        [self zoomIn:pos.x y:pos.y];
    }
}
- (void) onZoomout:(CGPoint)pos {
    if (m_bWin || [self isEnableZoomDevice] == NO)
        return;
    if (self.view.userInteractionEnabled == NO)
        return;
    if (m_bZoom == YES) {
        [self zoomOut];
    }
}

-(void) singleTouchOnBoardView:(CGPoint)pos {
    CGRect rect = [self getBoardRect];
    CGFloat width, height;
	width = rect.size.width / 9;
	height = rect.size.height / 9;
    if (m_nGameType == GAME_CLASSIC) {
        int nSelX = (pos.x) / m_fTileWidth;
        int nSelY = (pos.y) / m_fTileHeight;
        if (m_pSudokuEngine->IsGiven(nSelX, nSelY))
            return;
        [self moveSelLines:nSelX y:nSelY];
    }
    else {
        int nSelX = (pos.x - rect.origin.x) / width;
        int nSelY = (pos.y - rect.origin.y) / height;
        if (m_pSudokuEngine->GetTile(nSelX, nSelY) != 0)
            return;
        if (m_nPickState == PICK_DRAWTILE) {
            if ([self isRightPlace:nSelX y:nSelY]) {
                //kgh
                [self moveSelLines:nSelX y:nSelY];
                [self moveDrawTileToPlace];
                m_nSelX = nSelX;
                m_nSelY = nSelY;
            }
            else {
                [self setPickState:PICK_NONE];//kgh
            }
        }
        else if (m_nPickState == PICK_NONE || m_nPickState == PICK_BOARD) {
            [self moveSelLines:nSelX y:nSelY];
            [self setPickState:PICK_BOARD];
            m_nSelX = nSelX;
            m_nSelY = nSelY;
        }
    }
}
@end
