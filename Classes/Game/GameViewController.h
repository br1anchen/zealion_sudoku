//
//  GameViewController.h
//  Sudoku
//
//  Created by Kwang on 11/05/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <vector>
#include <algorithm>
#import "SudokuEngine.h"
#import "GameResultView.h"
#import "BoardView.h"
//class CSudokuEngine;
using namespace std;

enum PICK_STATE {
	PICK_NONE,
	PICK_BOARD,
	PICK_DRAWTILE,
	PICK_TILEMOVE,
};

@class TileView;

@interface GameViewController : UIViewController<UIScrollViewDelegate, BoardViewDelegate> {
	int			m_nGameType;
	
	vector<int>		m_vectorPicIndex;
	UIImageView*	m_viewNumberBar;
	UIButton*		m_btnUp;
	UIButton*		m_btnDown;
	
	CGFloat			m_fScale;
	
	int				m_nSelectNumber;
	
	int				m_nPickState;
	
	CGImageRef		m_imgNumbers[9];
	CGImageRef		m_imgRedNumbers[9];
	CGImageRef		m_imgOnNumbers[9];
	CGImageRef		m_imgPickPacks[9][9];
	
	NSMutableArray*	m_arrayTileViews;
	UIImageView*	m_imgSelPuzzleBorder;
	UIImageView*	m_imgSelNumber;
	UIImageView*	m_imgSelX;
	UIImageView*	m_imgSelY;
	UIImageView*	m_imgSelTile;
	
	int		m_nSelNumberBarId;
	
	CGSize	m_sizeTile;
	CGFloat	m_fTileWidth;
	CGFloat	m_fTileHeight;
    CGSize  m_sizeSelX;
    CGSize  m_sizeSelY;
    CGSize  m_sizeSelTile;
	int		m_nSelX;
	int		m_nSelY;
	int		m_nOldSelX;
	int		m_nOldSelY;
	
	CSudokuEngine*	m_pSudokuEngine;
	
	int			m_nShowDrawLineIndex;
	BOOL		m_bPick;
	CGPoint		m_ptMouseBegine;
	TileView*	m_tileViewSelected;
	int			m_nSelectedDrawTileId;
	int			m_nTouchedDrawTileId;
	int			m_nOldTouchedDrawTileId;
	
	UIImageView*	m_imgWin;
	BOOL			m_bWin;
	BOOL			m_bHideNavBar;
	
	NSMutableArray*	m_arrayNumberBtn;
	UIButton*		m_btnClear;
	UIButton*		m_btnPencil;
	BOOL			m_bEnablePencil;
	UIImageView*	m_imgNoMark;
	
	NSTimeInterval	m_nGameStartTime;
	NSTimeInterval	m_nGameEndTime;
	
	GameResultView*	m_viewResult;
    //added by kgh 2011/11/28
    BoardView*      m_viewBoard;
    UIScrollView*   m_scrollBoardView;
    UIImageView*    m_imgBoardLine;
	BOOL			m_bZoom;
	int				m_nZoomX;
	int				m_nZoomY;
}

-(void) initialize;
-(void) loadImages;
-(void) loadPackImage;
//-(void) initGame;
-(UIImage*) getStageImage:(int)stage;
-(void) createTileViews;
-(void) createNumberButtons;
-(void) createUpDownBtn;
-(void) createSelImageView;
-(void) createGameResultView;
-(void) procResumeGame;
-(void) hideTileView:(BOOL)bHide x:(int)x y:(int)y;
-(void) destroyViews;

-(void) setSelectedTile:(int)x y:(int)y value:(int)value;

-(CGRect) getTileRect:(int)x y:(int)y;
-(CGPoint) getTileCenterPos:(int)x y:(int)y;
-(CGRect) getBoardRect;
-(CGPoint) getBoardCenterPos;
-(CGRect) getDrawerRect;
-(int) getBoardTileIndex:(CGPoint)pt;
-(int) getDrawerTileIndex:(CGPoint)pt;
-(CGSize) getTileSize;

-(void) pickInDrawerTile:(CGPoint)pt;
-(void) pickOutDrawerTile:(CGPoint)pt;
-(void) moveSelectedDrawerTile:(CGPoint)pt;
-(void) cancelSelectedDrawerTile;
-(void) deleteDrawerTile:(int)index;
-(BOOL) isCorrectDrawerTilePos:(CGPoint)pt;
-(CGRect) getDrawerTileRect:(int) index;
//touched
-(void) touchDrawerTile:(int)index;
-(void) releaseTouchedDrawerTile:(int)index;
-(BOOL) isRightPlace:(int)x y:(int)y;
-(BOOL) isRightDrawTile:(int)tile;
//puzzle
-(void) setPickState:(int)state;
-(void) showSelPuzzleBorder:(BOOL)bShow;
-(void) moveSelPuzzleBorder:(int)x y:(int)y;

-(void) moveDrawTileToPlace;
-(void) doneMoveDrawTileToPlace;
-(void) fixedDrawTileToPlace:(int)x y:(int)y;

-(void) showSelLines:(BOOL)bShow;
-(void) showSelTileView:(BOOL)bShow;
-(void) setSelLinesViewPos:(int)x y:(int)y;
-(void) moveSelLines:(int)x y:(int)y;
-(void) moveSelXLine:(int)x;
-(void) moveSelYLine:(int)x;
-(void) stopMoveSelXLine;
-(void) stopMoveSelYLine;

-(void) arrangeDrawerTilePos:(int)nStartIndex;
-(void) animeDrawerTileView:(TileView*)tile pos:(CGPoint)center;
-(void) doneDrawerTilerAnim;
//classic
-(void) showSelNumber:(BOOL)bShow;
-(void) moveSelNumber:(int)number;
-(void) setSelNumberViewPos:(int)number;
-(void) updateNumberBtnState:(BOOL)bEnable;
-(void) changeSelectNumber:(int)number;
-(void) changeNumberBtnImage:(int)number selected:(BOOL)bSelected;
-(void) showNoMark:(int)x y:(int)y;
-(void) hideNoMark;
-(void) setHideNoMarkAnim;
-(void) stopHideNoMarkAnim;
-(void) showRedNumber:(int)number x:(int)x y:(int)y;
-(void) showSmallNumbers:(int)x y:(int)y;

-(void) onNumber:(id)sender;
-(void) onClear;
-(void) onPencil;
-(void) setPencilState:(BOOL)bEnable;
-(void) onUp;
-(void) onDown;
-(void) updateBtnState;
-(void) updateClearBtn:(int)nTile;
-(void) updatePencilBtn:(int)nTile;

-(void) initDrawerTilePos;
-(void) setDrawerTilePos:(int)showLineIndex;

-(void) checkCompleted;
-(BOOL) isCompleted;
-(void) procGameWin;
-(void) showResultView;
-(void) hideResultView;
-(void) startGameWinAnime;
-(void) returnMainMenu;

-(void) nextPuzzle;

-(void) singleTouchOnBoardView:(CGPoint)pos;
//for board scroll
-(void) lockView;
-(void) unlockView;
-(void) createBoardScrollView;
-(BOOL) isEnableZoomDevice;
-(CGSize) getZoomBoardSize;
-(void) zoomIn: (int)x y:(int) y;
-(void) zoomOut;
-(void) correctBoard;
-(void) completeZoomOut;
-(void) resizeTileViews;
-(void) resizeSelLineViews;
@end
