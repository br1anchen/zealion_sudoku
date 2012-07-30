//
//  GameOptionInfo.m
//  Sudoku
//
//  Created by Kwang on 11/05/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameOptionInfo.h"
#import "SudokuEngine.h"

GameOptionInfo* g_GameOptionInfo;


@implementation GameOptionInfo

@synthesize m_arrayPicturePackInfo, m_nGameType, m_nLevel, m_nToggleIconType, m_arrayPuzzlePackInfo;
@synthesize m_nEnablePackCount, m_nSelectedPack;
@synthesize m_arrayProblem, m_nSelectedStage;
@synthesize m_nBgType, m_bGameState, m_bEnableResume, m_strResumeKifu, m_bResumeGame;
@synthesize m_strResumeGivenKifu;
@synthesize m_strResumeSmallKifu;

-(id) init {
	if ((self = [super init])) {
		m_nGameType = GAME_PUZZLE;
		m_nLevel = LEVEL_EASY;
		m_nToggleIconType = TOGGLE_NUMBERS;
		m_nEnablePackCount = DEFAULT_PICCOUNT;
		m_nBgType = BG_LIGHT;
		m_bGameState = FALSE;
		m_bEnableResume = FALSE;
		m_strResumeKifu = nil;
		m_bResumeGame = FALSE;
		memset(m_bBuyedPackPitureState, 0, sizeof(m_bBuyedPackPitureState));
        memset(m_bDownloadPackState, NO, sizeof(m_bDownloadPackState));
		[self loadData];
		[self loadPuzzlePackInfo];
		[self loadPicturePackInfo];
		[self loadProblem:0];
        [self loadDownloadPackState];
		[self loadAllProblem];
	}
	return self;
}
-(void) setBuyPicState:(int)index buy:(BOOL)bBuy {
	m_bBuyedPackPitureState[index] = bBuy;
    if (bBuy) {
        m_nEnablePackCount ++;
    }
}
-(BOOL) getBuyPicState:(int)index {
    return m_bBuyedPackPitureState[index];
}
-(void) initEnablePackCount {
    m_nEnablePackCount = DEFAULT_PICCOUNT;
    for (int i = 0; i < BUY_PICCOUNT; i ++) {
        if (m_bBuyedPackPitureState[i] || m_bDownloadPackState[i])
            m_nEnablePackCount ++;
        else
            continue;
    }
}
-(int) getPackPicIndex:(int)number {
	if (number < DEFAULT_PICCOUNT) 
		return number;
	int index, count = 0;
	int offset = number - DEFAULT_PICCOUNT;
	for (int i = 0; i <BUY_PICCOUNT; i ++) {
		if (m_bBuyedPackPitureState[i]) {
			count ++;
			if (offset == count) {
				index = i;
				break;
			}
		}
	}
	return index+DEFAULT_PICCOUNT;
}
-(int) getBuyPackIndex:(int)number {
	int index, count = 0;
	int offset = number;
	for (int i = 0; i <BUY_PICCOUNT; i ++) {
		if (m_bBuyedPackPitureState[i] == NO) {
			if (offset == count) {
				index = i;
				break;
			}
			count ++;
		}
	}
	return index+DEFAULT_PICCOUNT;
}
-(int) getBuyPackCount {
    int count = 0;
    for (int i = 0; i < BUY_PICCOUNT; i ++) {
        if (m_bBuyedPackPitureState[i] == NO)
            count ++;
    }
    return count;
}

- (int) getBuyPackIndexByListId:(int)listId
{
    int ctBuyed = 0;
    for(int i =0;i< BUY_PICCOUNT;i ++){
        if (m_bBuyedPackPitureState[i] == true){
            ctBuyed ++;
            if(ctBuyed == listId - 3){
                return i+4;
            }
        }
        else
            continue;
    }

}

-(void) loadData {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL bFirst = [defaults boolForKey:@"FirstStartApp"];
	memset(m_nClassicCompletedCount, 0, sizeof(m_nClassicCompletedCount));
	if (!bFirst) {
		[self initPuzzlePackProblemState];
		[self initPicturePackProblemState];
        [self copyDefaultPackToDoc];
	}
	else {
		m_nToggleIconType = [defaults integerForKey:@"ToggleIcon"];
		m_nBgType = [defaults integerForKey:@"BgType"];
		m_nClassicCompletedCount[0] = [defaults integerForKey:@"ProblemCount0"];
		m_nClassicCompletedCount[1] = [defaults integerForKey:@"ProblemCount1"];
		m_nClassicCompletedCount[2] = [defaults integerForKey:@"ProblemCount2"];
		m_bEnableResume = [defaults integerForKey:@"GameResume"];
		if ([self loadPuzzlePackProblemState] == FALSE)
			[self initPuzzlePackProblemState];
		if ([self loadPicturePackProblemState] == FALSE)
			[self initPicturePackProblemState];
	}
	
}
-(void) saveData {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:YES forKey:@"FirstStartApp"];
	[defaults setInteger:m_nToggleIconType forKey:@"ToggleIcon"];
	[defaults setInteger:m_nBgType forKey:@"BgType"];
	[defaults setInteger:m_nClassicCompletedCount[0] forKey:@"ProblemCount0"];
	[defaults setInteger:m_nClassicCompletedCount[1] forKey:@"ProblemCount1"];
	[defaults setInteger:m_nClassicCompletedCount[2] forKey:@"ProblemCount2"];
	if (m_bGameState == FALSE)
		[defaults setInteger:0 forKey:@"GameResume"];
	else {
		BOOL nResume = [self saveGameResume];
		[defaults setInteger:nResume forKey:@"GameResume"];
	}

	[self savePuzzlePackInfo];
	[self savePuzzlePackProblemState];
	[self savePicturePackInfo];
	[self savePicturePackProblemState];
    [self saveDownloadPackState];
}
-(BOOL) loadGameResume {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *strPath = [documentsDirectory stringByAppendingPathComponent:@"ResumeKifu.plist"];
	
	NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithContentsOfFile:strPath];
	if (dic) {
		m_nGameType = [[dic objectForKey:@"GameType"] intValue];
		int nPack = [[dic objectForKey:@"Pack"] intValue];
		int nStage = [[dic objectForKey:@"Stage"] intValue];
		if (m_nGameType == GAME_CLASSIC) {
			m_nLevel = nPack;
//			nStage = 0;
		}
		else{
			m_nSelectedPack = nPack;
			m_nSelectedStage = nStage;
		}
		if (m_strResumeGivenKifu)
			[m_strResumeGivenKifu release];
		m_strResumeGivenKifu = [[NSString alloc] initWithString:[dic objectForKey:@"ResumeGivenKif"]];
		if (m_strResumeKifu)
			[m_strResumeKifu release];
		m_strResumeKifu = [[NSString alloc] initWithString:[dic objectForKey:@"ResumeKif"]];
		if (m_strResumeSmallKifu)
			[m_strResumeSmallKifu release];
		m_strResumeSmallKifu = [[NSString alloc] initWithString:[dic objectForKey:@"ResumeSmallKif"]];
		return TRUE;
	}
	else {
		return FALSE;
	}
}
-(BOOL) saveGameResume {
	int nPack, nStage;
	if (m_nGameType == GAME_CLASSIC) {
		nPack = m_nLevel;
		nStage = 0;
	}
	else{
		nPack = m_nSelectedPack;
		nStage = m_nSelectedStage;
	}
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writablePath = [documentsDirectory stringByAppendingPathComponent:@"ResumeKifu.plist"];

	NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
	[dic setObject:[NSNumber numberWithInt:m_nGameType] forKey:@"GameType"];
	[dic setObject:[NSNumber numberWithInt:nPack] forKey:@"Pack"];
	[dic setObject:[NSNumber numberWithInt:nStage] forKey:@"Stage"];
	[dic setObject:g_pSudokuEngine->getGivenKifuString() forKey:@"ResumeGivenKif"];
	[dic setObject:g_pSudokuEngine->getKifuString() forKey:@"ResumeKif"];
	[dic setObject:g_pSudokuEngine->getSmallKifuString() forKey:@"ResumeSmallKif"];
	BOOL bRet = [dic writeToFile:writablePath atomically:TRUE];
	[dic release];
	return bRet;
}
//download
-(void) setDownloadPackState:(int)index download:(BOOL)download {
    m_bDownloadPackState[index] = download;
}
-(BOOL) getDownloadPackState:(int)index {
    return m_bDownloadPackState[index];
}
-(void) copyDefaultPackToDoc {
    for (int i = 0; i < DEFAULT_PICCOUNT; i ++) {
        for (int j = 0; j < MAX_STAGE; j ++) {
            NSString* strFileName = [NSString stringWithFormat:@"%@%02d", [self getPackName:i], j+1];
            [self copyFileFromMainbunble:strFileName ext:@"jpg"];
        }
    }
}
///////////////////puzzle pack///////////////////////////////////////////
-(void) initPuzzlePackProblemState {
	memset(m_nPuzzlePackProblemState, PROBLEM_LOCK, sizeof(m_nPuzzlePackProblemState));
	for (int i = 0; i < PICTURE_COUNT; i ++) {
		for (int j = 0; j < 5; j ++) {
			m_nPuzzlePackProblemState[i][j] = PROBLEM_UNLOCK;
		}
	}
	//m_nPackProblemState[0][0]= PROBLEM_SOLVED;//test code
}
-(bool) loadPuzzlePackProblemState {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *stringDocumentDir = [paths objectAtIndex:0];
	NSString *strFileName = @"PuzzleProblemState.dat";
    NSString* filepath = [stringDocumentDir stringByAppendingPathComponent:strFileName];
	FILE *fp = fopen([filepath cStringUsingEncoding:1],"rb");
	if (fp == NULL) {
		//NSLog([filepath stringByAppendingString:@" not found"]);
		return FALSE;
	}
	int nSize = (int)sizeof(m_nPuzzlePackProblemState);
	int nReadBytes = fread(&m_nPuzzlePackProblemState, 1, nSize, fp);
	fclose(fp);
	
	if (nReadBytes != nSize)
	{
		return FALSE;
	}
		
	return TRUE;	
}
-(bool) savePuzzlePackProblemState {
	BOOL bRet = TRUE;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *stringDocumentDir = [paths objectAtIndex:0];
	NSString *strFileName = @"PuzzleProblemState.dat";
    NSString* filepath = [stringDocumentDir stringByAppendingPathComponent:strFileName];
	FILE *fp = fopen([filepath cStringUsingEncoding:1],"wb");
	if (fp == NULL) {
		//NSLog([filepath stringByAppendingString:@" not found"]);
		return FALSE;
	}
	int nSize = (int)sizeof(m_nPuzzlePackProblemState);
	int nWriteBytes = fwrite(&m_nPuzzlePackProblemState, 1, nSize, fp);
	fclose(fp);
	
	if (nWriteBytes != nSize)
		bRet = FALSE;
	
	return bRet;	
}

-(bool) loadPuzzlePackInfo {
	BOOL success;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writablePath = [documentsDirectory stringByAppendingPathComponent:@"PuzzlePack.plist"];
	
	if ([fileManager fileExistsAtPath:writablePath] == NO) {
		NSString *defaultDBPath = [[NSBundle mainBundle] pathForResource:@"PuzzlePack" ofType:@"plist"];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:writablePath error:&error];
		if (!success) {
			NSCAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		}
	}
		
	NSString *strError;
	NSPropertyListFormat format;
	NSData *plistData = [NSData dataWithContentsOfFile:writablePath];
	NSArray *amountData = [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&strError];
	
	m_arrayPuzzlePackInfo = [[NSMutableArray alloc] initWithCapacity:[amountData count]];
	if (amountData) {
		for (NSDictionary *item in amountData) {
			NSMutableDictionary* newItem = [NSMutableDictionary dictionaryWithDictionary:item];
			[m_arrayPuzzlePackInfo addObject:newItem];
		}
	}
	return YES;
}
-(bool) savePuzzlePackInfo {
//	NSString *path = [[NSBundle mainBundle] pathForResource:@"PicturePack" ofType:@"plist"];
//	
//	[m_arrayPicturePackInfo writeToFile:path atomically: YES];
	BOOL success;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writablePath = [documentsDirectory stringByAppendingPathComponent:@"PuzzlePack.plist"];
	
	if ([fileManager fileExistsAtPath:writablePath] == NO) {
		NSString *defaultDBPath = [[NSBundle mainBundle] pathForResource:@"PuzzlePack" ofType:@"plist"];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:writablePath error:&error];
		if (!success) {
			NSCAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		}
	}
	
//	NSMutableDictionary* item = (NSMutableDictionary*)[m_arrayPuzzlePackInfo objectAtIndex:0];
//	BOOL lock = [[item objectForKey:@"Lock"] boolValue];
////	NSNumber* num = [item objectForKey:@"Lock"];
//	NSNumber* temp = [NSNumber numberWithBool:YES];
//	//[num initWithBool:YES];
//	
//	[item setValue:@"kgh" forKey:@"Name"];
//	[item setValue:temp forKey:@"Lock"];
//	
//	lock = [[item objectForKey:@"Lock"] boolValue];
	NSArray *amountData = [[NSArray alloc] initWithArray:m_arrayPuzzlePackInfo];
	NSString *strError;
//	NSPropertyListFormat format;
	NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:amountData format:kCFPropertyListBinaryFormat_v1_0 errorDescription:&strError];
	[plistData writeToFile:writablePath atomically:TRUE];
	[amountData release];
	return YES;
}
///////////////////picture pack///////////////////////////////////////////
-(void) initPicturePackProblemState {
	memset(m_nPicturePackProblemState, PROBLEM_LOCK, sizeof(m_nPicturePackProblemState));
	for (int i = 0; i < PICTURE_COUNT; i ++) {
		for (int j = 0; j < 5; j ++) {
			m_nPicturePackProblemState[i][j] = PROBLEM_UNLOCK;
		}
	}
	//m_nPackProblemState[0][0]= PROBLEM_SOLVED;//test code
}
-(bool) loadPicturePackProblemState {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *stringDocumentDir = [paths objectAtIndex:0];
	NSString *strFileName = @"ProblemState.dat";
    NSString* filepath = [stringDocumentDir stringByAppendingPathComponent:strFileName];
	FILE *fp = fopen([filepath cStringUsingEncoding:1],"rb");
	if (fp == NULL) {
		//NSLog([filepath stringByAppendingString:@" not found"]);
		return FALSE;
	}
	int nSize = (int)sizeof(m_nPicturePackProblemState);
	int nReadBytes = fread(&m_nPicturePackProblemState, 1, nSize, fp);
	fclose(fp);
	
	if (nReadBytes != nSize)
	{
		return FALSE;
	}
	
	return TRUE;	
}
-(bool) savePicturePackProblemState {
	BOOL bRet = TRUE;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *stringDocumentDir = [paths objectAtIndex:0];
	NSString *strFileName = @"ProblemState.dat";
    NSString* filepath = [stringDocumentDir stringByAppendingPathComponent:strFileName];
	FILE *fp = fopen([filepath cStringUsingEncoding:1],"wb");
	if (fp == NULL) {
		//NSLog([filepath stringByAppendingString:@" not found"]);
		return FALSE;
	}
	int nSize = (int)sizeof(m_nPicturePackProblemState);
	int nWriteBytes = fwrite(&m_nPicturePackProblemState, 1, nSize, fp);
	fclose(fp);
	
	if (nWriteBytes != nSize)
		bRet = FALSE;
	
	return bRet;	
}

-(bool) loadPicturePackInfo {
	//	NSString *path = [[NSBundle mainBundle] pathForResource:@"PicturePack" ofType:@"plist"];
	//	m_arrayPicturePackInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	//	
	//	int count = [m_arrayPicturePackInfo count];
	//	
	//	NSString *value;
	//	value = [plistDict objectForKey:@"ProductVersion"];
	BOOL success;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writablePath = [documentsDirectory stringByAppendingPathComponent:@"PicturePack.plist"];
	
	if ([fileManager fileExistsAtPath:writablePath] == NO) {
		NSString *defaultDBPath = [[NSBundle mainBundle] pathForResource:@"PicturePack" ofType:@"plist"];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:writablePath error:&error];
		if (!success) {
			NSCAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		}
	}
	
	//    NSString *strPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"PicturePack.plist"];
	//	NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:strPath];
	
	//	NSURL* url = [NSURL URLWithString:URL_PLIST];
	//	NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfURL:url];
	
	//	NSString *value = [plistDict objectForKey:@"VideoNum"];
	//	m_nVideoNum = [value intValue];
	
	NSString *strError;
	NSPropertyListFormat format;
	NSData *plistData = [NSData dataWithContentsOfFile:writablePath];
	NSArray *amountData = [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&strError];
	
	m_arrayPicturePackInfo = [[NSMutableArray alloc] initWithCapacity:[amountData count]];
	if (amountData) {
		for (NSDictionary *item in amountData) {
			NSMutableDictionary* newItem = [NSMutableDictionary dictionaryWithDictionary:item];
			[m_arrayPicturePackInfo addObject:newItem];
		}
	}
	return YES;
}
-(bool) savePicturePackInfo {
	//	NSString *path = [[NSBundle mainBundle] pathForResource:@"PicturePack" ofType:@"plist"];
	//	
	//	[m_arrayPicturePackInfo writeToFile:path atomically: YES];
	BOOL success;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writablePath = [documentsDirectory stringByAppendingPathComponent:@"PicturePack.plist"];
	
	if ([fileManager fileExistsAtPath:writablePath] == NO) {
		NSString *defaultDBPath = [[NSBundle mainBundle] pathForResource:@"PicturePack" ofType:@"plist"];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:writablePath error:&error];
		if (!success) {
			NSCAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		}
	}
	//    NSString *strPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"PicturePack.plist"];
	//	NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:strPath];
	
	//	NSURL* url = [NSURL URLWithString:URL_PLIST];
	//	NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfURL:url];
	
	//	NSString *value = [plistDict objectForKey:@"VideoNum"];
	//	m_nVideoNum = [value intValue];
	
	NSArray *amountData = [[NSArray alloc] initWithArray:m_arrayPicturePackInfo];
	NSString *strError;
	//	NSPropertyListFormat format;
	NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:amountData format:kCFPropertyListBinaryFormat_v1_0 errorDescription:&strError];
	[plistData writeToFile:writablePath atomically:TRUE];
	[amountData release];
	return YES;
}
-(BOOL) loadDownloadPackState {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *stringDocumentDir = [paths objectAtIndex:0];
	NSString *strFileName = @"DownloadPackState.dat";
    NSString* filepath = [stringDocumentDir stringByAppendingPathComponent:strFileName];
	FILE *fp = fopen([filepath cStringUsingEncoding:1],"rb");
	if (fp == NULL) {
		//NSLog([filepath stringByAppendingString:@" not found"]);
		return FALSE;
	}
	int nSize = (int)sizeof(m_bDownloadPackState);
	int nReadBytes = fread(&m_bDownloadPackState, 1, nSize, fp);
	fclose(fp);
	
	if (nReadBytes != nSize)
	{
		return FALSE;
	}
	
	return TRUE;	
    
}
-(BOOL) saveDownloadPackState {
	BOOL bRet = TRUE;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *stringDocumentDir = [paths objectAtIndex:0];
	NSString *strFileName = @"DownloadPackState.dat";
    NSString* filepath = [stringDocumentDir stringByAppendingPathComponent:strFileName];
	FILE *fp = fopen([filepath cStringUsingEncoding:1],"wb");
	if (fp == NULL) {
		//NSLog([filepath stringByAppendingString:@" not found"]);
		return FALSE;
	}
	int nSize = (int)sizeof(m_bDownloadPackState);
	int nWriteBytes = fwrite(&m_bDownloadPackState, 1, nSize, fp);
	fclose(fp);
	
	if (nWriteBytes != nSize)
		bRet = FALSE;
	
	return bRet;	
}

//////////////////////////////////////////////////////////////
-(void) loadAllProblem {
	m_arrayProblem0 = [[NSArray alloc] initWithArray:[self loadProblem:0]];
	m_arrayProblem1 = [[NSArray alloc] initWithArray:[self loadProblem:1]];
	m_arrayProblem2 = [[NSArray alloc] initWithArray:[self loadProblem:2]];
	m_arrayProblem3 = [[NSArray alloc] initWithArray:[self loadProblem:3]];
	m_arrayProblem4 = [[NSArray alloc] initWithArray:[self loadProblem:4]];
}
-(NSArray*) loadProblem:(int)nLevel {
	NSString* strFile = [NSString stringWithFormat:@"puzzle%d", nLevel];
	NSString *path = [[NSBundle mainBundle] pathForResource:strFile ofType:nil];
	NSData* data = [NSData dataWithContentsOfFile:path];
	NSString* strPro = [NSString stringWithCString:(char*)[data bytes] encoding:NSASCIIStringEncoding];
	NSArray* arr = [strPro componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
//	int nCount = [m_arrayProblem count];
	return arr;
}
////////////////////////////puzzle pack/////////////////////////
-(int) getPuzzlePackProblemState:(int)pack stage:(int)stage {
	return m_nPuzzlePackProblemState[pack][stage];
}
-(void) setPuzzlePackProblemState:(int)pack stage:(int)stage state:(int)state {
	m_nPuzzlePackProblemState[pack][stage] = state;
}
-(int) getSolvedPuzzlePackProblemCount:(int)pack {
	int nCount = 0;
	for (int i = 0; i < MAX_STAGE; i ++) {
		if (m_nPuzzlePackProblemState[pack][i] == PROBLEM_SOLVED)
			nCount ++;
	}
	return nCount;
}
-(void) unlockPuzzlePackProblem:(int)pack {
	for (int i = 0; i < MAX_STAGE; i ++) {
		if (m_nPuzzlePackProblemState[pack][i] == PROBLEM_LOCK) {
			m_nPuzzlePackProblemState[pack][i] = PROBLEM_UNLOCK;
			break;
		}
	}
}

-(void) unlockAllPuzzlePackProblem:(int)pack
{
    for (int i = 0; i < MAX_STAGE; i ++) {
		if (m_nPuzzlePackProblemState[pack][i] == PROBLEM_LOCK) {
			m_nPuzzlePackProblemState[pack][i] = PROBLEM_UNLOCK;
		}
	}
}

-(void) updatePuzzlePackInfo:(int)pack {
	NSMutableDictionary* item = (NSMutableDictionary*)[m_arrayPuzzlePackInfo objectAtIndex:pack];
	int nCount = [self getSolvedPuzzlePackProblemCount:pack];
	[item setValue:[NSNumber numberWithInt:nCount] forKey:@"Solve"];
	if (nCount >= 20 && pack < m_nEnablePackCount-1) {
		item = (NSMutableDictionary*)[m_arrayPuzzlePackInfo objectAtIndex:pack+1];
		[item setValue:[NSNumber numberWithBool:NO] forKey:@"Lock"];
	}
}
////////////////////////////picture pack/////////////////////////
-(int) getPicturePackProblemState:(int)pack stage:(int)stage {
	return m_nPicturePackProblemState[pack][stage];
}
-(void) setPicturePackProblemState:(int)pack stage:(int)stage state:(int)state {
	m_nPicturePackProblemState[pack][stage] = state;
}
-(int) getSolvedPicturePackProblemCount:(int)pack {
	int nCount = 0;
	for (int i = 0; i < MAX_STAGE; i ++) {
		if (m_nPicturePackProblemState[pack][i] == PROBLEM_SOLVED)
			nCount ++;
	}
	return nCount;
}
-(void) unlockPicturePackProblem:(int)pack {
	for (int i = 0; i < MAX_STAGE; i ++) {
		if (m_nPicturePackProblemState[pack][i] == PROBLEM_LOCK) {
			m_nPicturePackProblemState[pack][i] = PROBLEM_UNLOCK;
			break;
		}
	}
}

-(void) unlockAllPicturePackProblem:(int)pack
{
    for (int i = 0; i < MAX_STAGE; i ++) {
		if (m_nPicturePackProblemState[pack][i] == PROBLEM_LOCK) {
			m_nPicturePackProblemState[pack][i] = PROBLEM_UNLOCK;
		}
	}
}

-(void) updatePicturePackInfo:(int)pack {
	NSMutableDictionary* item = (NSMutableDictionary*)[m_arrayPicturePackInfo objectAtIndex:pack];
	int nCount = [self getSolvedPicturePackProblemCount:pack];
	[item setValue:[NSNumber numberWithInt:nCount] forKey:@"Solve"];
	int nMax = [[item objectForKey:@"Problem"] intValue];
	if (nCount >= nMax && pack < m_nEnablePackCount-1) {
		item = (NSMutableDictionary*)[m_arrayPicturePackInfo objectAtIndex:pack+1];
		[item setValue:[NSNumber numberWithBool:NO] forKey:@"Lock"];
	}
}

////////////////////////////classic/////////////////////////
-(int) getClassicCompletedCount:(int)nLevel {
	return m_nClassicCompletedCount[nLevel];
}
-(void) increaseClassicCompletedCount:(int)nLevel {
	m_nClassicCompletedCount[nLevel] ++;
}

-(void) createProblem:(int)gametype param:(int)param{
	if (m_arrayProblem)
		[m_arrayProblem release];
	if (gametype == GAME_CLASSIC) {
		NSArray* temp;
		switch (param) {
			case LEVEL_EASY:
				temp = m_arrayProblem1;
				break;
			case LEVEL_MEDIUM:
				temp = m_arrayProblem2;
				break;
			case LEVEL_HARD:
				temp = m_arrayProblem4;
				break;
			default:
				break;
		}
		m_arrayProblem = [[NSMutableArray alloc] initWithArray:temp];
	}
	else {
		int nBase;
		if (gametype == GAME_PUZZLE)
			nBase = 700;
		else {
			nBase = 800;
		}

		m_arrayProblem = [[NSMutableArray alloc] init];
		NSArray* arr[5] = {
			m_arrayProblem0, m_arrayProblem1, m_arrayProblem2, m_arrayProblem3, m_arrayProblem4
		};
		for (int i = 0; i < 5; i ++) {
			for (int j = 0; j < 5; j ++) {
				[m_arrayProblem addObject:[arr[i] objectAtIndex:nBase+param*5+j]];
			}
		}
	}
}
-(NSString*) getProblem:(int)gametype param:(int)param stage:(int)stage {
	const int BASE_CLASSICSTAGE = 50;
	const int PROBLEM_COUNT = 1000;
	NSString* strProblem;
	if (gametype == GAME_CLASSIC) {
		NSArray* temp;
		switch (param) {
			case LEVEL_EASY:
				if (stage < BASE_CLASSICSTAGE)
					temp = m_arrayProblem0;
				else
					temp = m_arrayProblem1;
				break;
			case LEVEL_MEDIUM:
				if (stage < BASE_CLASSICSTAGE)
					temp = m_arrayProblem2;
				else
					temp = m_arrayProblem3;
				break;
			case LEVEL_HARD:
				if (stage < BASE_CLASSICSTAGE)
					temp = m_arrayProblem3;
				else
					temp = m_arrayProblem4;
				break;
			default:
				break;
		}
		int nRand = arc4random()%PROBLEM_COUNT;
		strProblem = [[NSString alloc] initWithString:(NSString*)[temp objectAtIndex:(nRand%PROBLEM_COUNT)]];
	}
	else {
		NSArray* arr[5] = {
			m_arrayProblem1, m_arrayProblem2, m_arrayProblem3, m_arrayProblem4
		};
		strProblem = [[NSString alloc] initWithString:(NSString*)[arr[stage/7] objectAtIndex:arc4random()%PROBLEM_COUNT]];
	}
	return [strProblem autorelease];
}
-(void) solveProblem:(int)gametype pack:(int)pack stage:(int)stage {
	switch (gametype) {
		case GAME_PUZZLE:
			if ([self getPuzzlePackProblemState:pack stage:stage] != PROBLEM_SOLVED) {
				[self setPuzzlePackProblemState:pack stage:stage state:PROBLEM_SOLVED];
				[self unlockPuzzlePackProblem:pack];
				[self updatePuzzlePackInfo:pack];
			}
			break;
		case GAME_PICTURE:
			if ([self getPicturePackProblemState:pack stage:stage] != PROBLEM_SOLVED) {
				[self setPicturePackProblemState:pack stage:stage state:PROBLEM_SOLVED];
				[self unlockPicturePackProblem:pack];
				[self updatePicturePackInfo:pack];
			}
			break;
		case GAME_CLASSIC:
			[self increaseClassicCompletedCount:pack];
			break;
		default:
			break;
	}
}
-(NSString*) getPackName:(int)packtype {
//    NSString* strPackName[PICTURE_COUNT] = {
//        @"city", @"Nature", @"Cat", @"dog", @"bird", @"graphics", @"food", @"sports", @"mountain", @"space", @"art"
//    };
    NSString* strPackName[PICTURE_COUNT] = {
        @"art", @"city", @"food", @"mountain", @"sports", @"Cat", @"bird", @"dog", @"graphics", @"Nature", @"space", 
    };
    return strPackName[packtype];
}
-(NSString*) getDirPackName:(int)packtype {
//    NSString* strPackName[PICTURE_COUNT] = {
//        @"City", @"Nature", @"Cat", @"Dog", @"Bird", @"Graphics", @"Food", @"Sports", @"Mountain", @"Space", @"Art"
//    };
    NSString* strPackName[PICTURE_COUNT] = {
        @"Art", @"City", @"Food", @"Mountain", @"Sports", @"Cat", @"Bird", @"Dog", @"Graphics", @"Nature", @"Space", 
    };
    return strPackName[packtype];
}
-(NSString*) getPackImageFilePath:(int)packtype stage:(int)stage {
    NSString* filename = [NSString stringWithFormat:@"%@%02d.jpg", [self getPackName:packtype], stage+1];
    return [NSString stringWithString:[self getFilePathWithFileName:filename]];
}
- (NSString*) getFilePathWithFileName:(NSString*)strFileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:strFileName];
}
- (void) deleteFile:(NSString*)strPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if ([fileManager fileExistsAtPath:strPath] == YES) {
        [fileManager removeItemAtPath:strPath error:&error];
    }
}
- (void) copyFileFromMainbunble:(NSString*)strFileName ext:(NSString*)ext {
    NSString* fullName = [NSString stringWithFormat:@"%@.%@", strFileName, ext];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* strPath = [self getFilePathWithFileName:fullName];
    NSError *error;
    if ([fileManager fileExistsAtPath:strPath] == NO) {
        NSString *defaultDBPath = [[NSBundle mainBundle] pathForResource:strFileName ofType:ext];
        BOOL success = [fileManager copyItemAtPath:defaultDBPath toPath:strPath error:&error];
        if (!success) {
            NSCAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
        }
    }
}

-(void) dealloc {
	if (m_strResumeKifu)
		[m_strResumeKifu release];
	[m_arrayPuzzlePackInfo release];
	[m_arrayPicturePackInfo release];
	[m_arrayProblem release];
	[m_arrayProblem0 release];
	[m_arrayProblem1 release];
	[m_arrayProblem2 release];
	[m_arrayProblem3 release];
	[m_arrayProblem4 release];
	[super dealloc];
}
@end
