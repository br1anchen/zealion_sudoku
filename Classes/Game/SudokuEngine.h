// SudokuEngine.h : header file
//

#include "stdio.h"
#import <Foundation/Foundation.h>

#pragma once

#define BOARD_SIZE 9

/////////////////////////////////////////////////////////////////////////////
// CSudokuEngine dialog

class CSudokuEngine
{
public:
	CSudokuEngine();	// standard constructor
	~CSudokuEngine();	// standard destructor
	
	void SetProblem(char* szProblem);
	void SetResumeKifu(char* szKifu);
	void SetResumeSmallKifu(NSString* strSmall);

	BOOL OnNew(int nLevel);
	BOOL OnSolve();
	void OnNew();
	void OnEdit();
	void OnStart();
	void OnCheck();
	
	// Construction
	int GetTile(int x, int y);
	int GetSolvedTile(int x, int y);
	void SetTile(int x, int y, int value);
	BOOL SetTileIfValid(int x, int y, int value);
	BOOL SetTileIfAnyOne(int x, int y, int value);
	BOOL SetSmallNumber(int x, int y, int value);
	void ResetSmallNumber(int x, int y);
	BOOL IsSmallNumber(int x, int y);
	NSMutableArray* GetUsedTiles(int x, int y);
	NSMutableArray* GetSmallNumbers(int x, int y);
	
	void CalculateUsedTiles();
	NSMutableArray* CalculateUsedTiles(int x, int y);
	void CalculateGivenTiles();
	BOOL IsGiven(int x, int y);
	bool IsCompleted();
	void SetSelectedTile(int tile);
	NSString* getGivenKifuString();
	NSString* getKifuString();
	NSString* getSmallKifuString();

public:
	void initialize();
	int MakeCountRandom(int not_num);
	int RandomCheck(char count[],int random_num);
	int MakeNewGame(int diff);
	int InitNewGame();
	int IdxToMat(int index);
	int MatToIdx(int index);
	int CheckOutNum(int y,int x,int num);
	int ExpertSolve(int index);
	int MatToTmp(int y, int x);	//인자값은 어느위치부터 그 뒤를 복사할건지 설정
	int TmpToMat(int y, int x);	//인자값은 어느위치부터 그 뒤를 복사할건지 설정
	int CheckSolution();
	int Trans_EditBox();
	int fill_blank();	//-1반환시 게임이 성립되지 않는 에러 0은 정상
	int empty_count();
	int expect_count(char *count,int* solve);
	void CountRenNum();
	//int i,j,k,l,m,n,o;	//임시변수들
	int solve;
	int mode; //0=아무것도아님 1=게임중 2=편집중 3=게임끝
	char count[10];

	//mat[가로][세로][임의의 수 대입을위한배열]
	char mat[BOARD_SIZE+1][BOARD_SIZE+1][BOARD_SIZE+1];
	char mat_idx[99][BOARD_SIZE+1][BOARD_SIZE+1][BOARD_SIZE+1];

	//새게임을 만들때 사용하는 배열
	char mat_new[3][5][10][10];	//[게임난이도 0~2][빈칸의랜덤모양 0~4][y좌표][x좌표]
	int mat_size;
	
	//빈칸에 숫자 입력시 임시적으로 저장하는 변수
	char mat_tmp[BOARD_SIZE+1][BOARD_SIZE+1][BOARD_SIZE+1];
	char rem_num[BOARD_SIZE+1];	//각 숫자마다 사용할수 있는 횟수를 저장
	char rem_num_tmp[BOARD_SIZE+1];
//	CEdit *mat_ed[BOARD_SIZE+1][BOARD_SIZE+1];

	//에디트 박스가 read-only 상태인지를 저장하는 배열
	//문제의 수정을 방지하기위함.
	char mat_readonly[10][10];

	int		tiles[BOARD_SIZE][BOARD_SIZE];
	bool	given[BOARD_SIZE][BOARD_SIZE];
	NSMutableArray*		m_arrayUsed[BOARD_SIZE][BOARD_SIZE];
	NSMutableArray*		m_arraySmall[BOARD_SIZE][BOARD_SIZE];

// Implementation
protected:
};

extern CSudokuEngine*	g_pSudokuEngine;

