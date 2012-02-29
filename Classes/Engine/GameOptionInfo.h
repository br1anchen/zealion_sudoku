//
//  GameOptionInfo.h
//  Sudoku
//
//  Created by Kwang on 11/05/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAX_STAGE			25
#define DEFAULT_PICCOUNT	4
#define BUY_PICCOUNT        7

enum GAME_TYPE {
	GAME_PUZZLE,
	GAME_CLASSIC,
	GAME_PICTURE,
	GAMETYPE_COUNT
};

enum LEVEL_TYPE {
	LEVEL_EASY,
	LEVEL_MEDIUM,
	LEVEL_HARD,
	LEVEL_COUNT
};

enum TOGGLEICON_TYPE {
	TOGGLE_SYMBOLS,
	TOGGLE_COLORS,
	TOGGLE_NUMBERS,
	TOGGLE_COUNT
};

enum PICTUREPACK_TYPE {
	PICTURE_ART,
	PICTURE_CITY,
	PICTURE_FOOD,
	PICTURE_MOUNTAIN,//free
	PICTURE_SPORTS,
	PICTURE_CAT,
	PICTURE_BIRD,
	PICTURE_DOG,
	PICTURE_GRAPHICS,
	PICTURE_NATURE,
	PICTURE_SPACE,
	PICTURE_COUNT
};

enum PROBLEM_STATE {
	PROBLEM_LOCK,
	PROBLEM_UNLOCK,
	PROBLEM_SOLVED,
};

enum BG_TYPE {
	BG_LIGHT,
	BG_DARK
};


@interface GameOptionInfo : NSObject {
	int		m_nGameType;
	int		m_nLevel;
	int		m_nToggleIconType;
	int		m_nEnablePackCount;
	int		m_nSelectedPack;
	int		m_nSelectedStage;
	int		m_nBgType;
	BOOL	m_bGameState;
	BOOL	m_bEnableResume;
	BOOL	m_bResumeGame;
	
	//in app
	BOOL	m_bBuyedPackPitureState[BUY_PICCOUNT];
    BOOL    m_bDownloadPackState[BUY_PICCOUNT];
	
	NSMutableArray* m_arrayPuzzlePackInfo;
	NSMutableArray* m_arrayPicturePackInfo;
	
	NSMutableArray*	m_arrayProblem;
	NSArray*		m_arrayProblem0;
	NSArray*		m_arrayProblem1;
	NSArray*		m_arrayProblem2;
	NSArray*		m_arrayProblem3;
	NSArray*		m_arrayProblem4;

	int		m_nPuzzlePackProblemState[PICTURE_COUNT][MAX_STAGE];
	int		m_nPicturePackProblemState[PICTURE_COUNT][MAX_STAGE];
	int		m_nClassicCompletedCount[LEVEL_COUNT];

	NSString* m_strResumeSmallKifu;
	NSString* m_strResumeGivenKifu;
	NSString* m_strResumeKifu;
}

@property (nonatomic, retain) NSMutableArray* m_arrayPuzzlePackInfo;
@property (nonatomic, retain) NSMutableArray* m_arrayPicturePackInfo;
@property (nonatomic, retain) NSMutableArray* m_arrayProblem;
@property (nonatomic, retain) NSString* m_strResumeGivenKifu;
@property (nonatomic, retain) NSString* m_strResumeKifu;
@property (nonatomic, retain) NSString* m_strResumeSmallKifu;
@property (nonatomic) int m_nGameType;
@property (nonatomic) int m_nLevel;
@property (nonatomic) int m_nToggleIconType;
@property (nonatomic) int m_nEnablePackCount;
@property (nonatomic) int m_nSelectedPack;
@property (nonatomic) int m_nSelectedStage;
@property (nonatomic) int m_nBgType;
@property (nonatomic) BOOL m_bGameState;
@property (nonatomic) BOOL m_bEnableResume;
@property (nonatomic) BOOL m_bResumeGame;

-(void) loadData;
-(void) saveData;

-(BOOL) loadGameResume;
-(BOOL) saveGameResume;

-(void) initPuzzlePackProblemState;
-(bool) loadPuzzlePackProblemState;
-(bool) savePuzzlePackProblemState;
-(bool) loadPuzzlePackInfo;
-(bool) savePuzzlePackInfo;

-(void) initPicturePackProblemState;
-(bool) loadPicturePackProblemState;
-(bool) savePicturePackProblemState;
-(bool) loadPicturePackInfo;
-(bool) savePicturePackInfo;

-(BOOL) loadDownloadPackState;
-(BOOL) saveDownloadPackState;

-(void) loadAllProblem;
-(NSArray*) loadProblem:(int)nLevel;

-(int) getPuzzlePackProblemState:(int)pack stage:(int)stage;
-(void) setPuzzlePackProblemState:(int)pack stage:(int)stage state:(int)state;
-(int) getSolvedPuzzlePackProblemCount:(int)pack;
-(void) unlockPuzzlePackProblem:(int)pack;
-(void) updatePuzzlePackInfo:(int)pack;

-(int) getPicturePackProblemState:(int)pack stage:(int)stage;
-(void) setPicturePackProblemState:(int)pack stage:(int)stage state:(int)state;
-(int) getSolvedPicturePackProblemCount:(int)pack;
-(void) unlockPicturePackProblem:(int)pack;
-(void) updatePicturePackInfo:(int)pack;

-(int) getClassicCompletedCount:(int)nLevel;
-(void) increaseClassicCompletedCount:(int)nLevel;

-(void) createProblem:(int)gametype param:(int)param;
-(NSString*) getProblem:(int)gametype param:(int)param stage:(int)stage;

-(void) solveProblem:(int)gametype pack:(int)pack stage:(int)stage;

//in app
-(void) setBuyPicState:(int)index buy:(BOOL)bBuy;
-(BOOL) getBuyPicState:(int)index;
-(int) getPackPicIndex:(int)number;
-(int) getBuyPackIndex:(int)number;
-(void) initEnablePackCount;
-(int) getBuyPackCount;

//download
-(void) setDownloadPackState:(int)index download:(BOOL)download;
-(BOOL) getDownloadPackState:(int)index;
-(void) copyDefaultPackToDoc;

-(NSString*) getPackName:(int)packtype;
-(NSString*) getDirPackName:(int)packtype;
-(NSString*) getPackImageFilePath:(int)packtype stage:(int)stage;

- (NSString*) getFilePathWithFileName:(NSString*)strFileName;
- (void) deleteFile:(NSString*)strPath;
- (void) copyFileFromMainbunble:(NSString*)strFileName ext:(NSString*)ext;

@end

extern GameOptionInfo* g_GameOptionInfo;
