// SudokuEngine.cpp : implementation file
//

#import "SudokuEngine.h"


CSudokuEngine*	g_pSudokuEngine;
/////////////////////////////////////////////////////////////////////////////
// CSudokuEngine dialog

CSudokuEngine::CSudokuEngine()
{
	for(int i=1;i<=BOARD_SIZE;i++)
	{
		for(int j=1;j<=BOARD_SIZE;j++)
		{
			m_arrayUsed[i-1][j-1] = nil;
			m_arraySmall[i-1][j-1] = nil;
		}
	}
	initialize();
}

CSudokuEngine::~CSudokuEngine()
{
	for (int x = 0; x < 9; x++) {
		for (int y = 0; y < 9; y++) {
			if (m_arrayUsed[x][y])
				[m_arrayUsed[x][y] release];
			if (m_arraySmall[x][y])
				[m_arraySmall[x][y] release];
		}
	}
}

/////////////////////////////////////////////////////////////////////////////
// CSudokuEngine message handlers

void CSudokuEngine::initialize()
{
	// TODO: Add extra initialization here
//	m_bn_check.EnableWindow(FALSE);	//정답체크버턴 비활성
//	m_bn_solve.EnableWindow(FALSE);	//정답풀이버턴 비활성
//	m_bn_start.EnableWindow(FALSE);	//시작버턴 비활성

	mode = 0;	//현재 모드를 초기모드로 설정

	srand(time(NULL));	//랜덤값생성을위한 seed값 입력

	for (int x = 0; x < 9; x++) {
		for (int y = 0; y < 9; y++) {
			if (m_arrayUsed[x][y]) 
				[m_arrayUsed[x][y] release];
			m_arrayUsed[x][y] = nil;
			if (m_arraySmall[x][y])
				[m_arraySmall[x][y] release];
			m_arraySmall[x][y] = nil;
		}
	}
	
//	InitNewGame();	//새게임을할때 쓰는 함수 빈칸 모양을 만듬
	memset(mat, 0, sizeof(mat));

	mat_size = (BOARD_SIZE+1)*(BOARD_SIZE+1)*(BOARD_SIZE+1);	//mat_idx의 크기를 지정
	memset(tiles, 0, sizeof(tiles));
	memset(given, 0, sizeof(given));
	
}

void CSudokuEngine::SetProblem(char* szProblem)
{
	for(int i=0;i<BOARD_SIZE;i++)
	{
		for(int j=0;j<BOARD_SIZE;j++)
		{
			mat[i+1][j+1][0] = szProblem[j*9+i] - '0';
			tiles[i][j] = mat[i+1][j+1][0];
		}
	}
	Trans_EditBox();
	CalculateUsedTiles();
	CalculateGivenTiles();
}

void CSudokuEngine::SetResumeKifu(char* szKifu) 
{
	for(int i=0;i<BOARD_SIZE;i++)
	{
		for(int j=0;j<BOARD_SIZE;j++)
		{
			if (IsGiven(i, j))
				continue;
			int nTile = szKifu[j*9+i] - '0';
			if (nTile > 0)
				SetTile(i, j, nTile);
		}
	}
	Trans_EditBox();
	CalculateUsedTiles();
}
void CSudokuEngine::SetResumeSmallKifu(NSString* strSmall)
{
	NSArray* arraySmall = [strSmall componentsSeparatedByString:@"|"];
	for (int x = 0; x < 9; x++) {
		for (int y = 0; y < 9; y++) {
			NSString* str = [arraySmall objectAtIndex:x*9+y];
			if (str == nil || [str length] == 0) {
				m_arraySmall[x][y] = nil;
			}
			else {
				m_arraySmall[x][y] = [[NSMutableArray alloc] init];
				char szBuf[128] = "";
				[str getCString:szBuf maxLength:82 encoding:NSASCIIStringEncoding];
				for (int i = 0; i < strlen(szBuf); i ++) {
					[m_arraySmall[x][y] addObject:[NSNumber numberWithInt:(szBuf[i]-'0')]];
				}
			}
		}
	}
}
NSString* CSudokuEngine::getGivenKifuString() 
{
	char szBuf[128];
	memset(szBuf, 0, sizeof(szBuf));
	int i = 0;
	for (int y = 0; y < BOARD_SIZE; y ++) {
		for (int x = 0; x < BOARD_SIZE; x ++) {
			if (tiles[x][y] <= 0 || !IsGiven(x, y)) {
				szBuf[i] = '0';
			}
			else {
				szBuf[i] = '0'+(char)tiles[x][y];
			}

			i ++;
			if (tiles[x][y] > 0 && IsGiven(x, y)) {
				NSLog(@"put(%d, %d)", x, y);
			}
		}
	}
	return [[[NSString alloc] initWithCString:szBuf encoding:NSASCIIStringEncoding] autorelease];
}
NSString* CSudokuEngine::getKifuString() 
{
	char szBuf[128];
	memset(szBuf, 0, sizeof(szBuf));
	int i = 0;
	for (int y = 0; y < BOARD_SIZE; y ++) {
		for (int x = 0; x < BOARD_SIZE; x ++) {
			szBuf[i] = '0'+(char)tiles[x][y];
			i ++;
			if (tiles[x][y] > 0 && !IsGiven(x, y)) {
				NSLog(@"put(%d, %d)", x, y);
			}
		}
	}
	return [[[NSString alloc] initWithCString:szBuf encoding:NSASCIIStringEncoding] autorelease];
}
NSString* CSudokuEngine::getSmallKifuString()
{
	NSMutableString* strSmall = [[NSMutableString alloc] init];
	for (int x = 0; x < 9; x++) {
		for (int y = 0; y < 9; y++) {
			if (m_arraySmall[x][y]) {
				for (int i = 0; i < m_arraySmall[x][y].count; i ++) {
					[strSmall appendFormat:@"%d",[[m_arraySmall[x][y] objectAtIndex:i] intValue]];
				}
			}
			[strSmall appendString:@"|"];
		}
	}
	return [strSmall autorelease];
}
// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

//void CSudokuEngine::OnPaint() 
//{
//	//mat안에 들어있는 data를 빈칸에 채우는 기능
//	for(i=0;i<9;i++)
//	{
//		for(j=0;j<9;j++)
//		{
//			if(mat[i+1][j+1][0] != 0)
//			{
//				SetDlgItemInt(IDC_EDIT1_1+(i*10)+j, mat[i+1][j+1][0]);
//				//IDC_EDIT1_1+(i*10)+j부분은 미리 resource.h파일을 화면의 칸과
//				//resource의 상수값 맞춰 놓았음
//			}
//			else
//			{
//				SetDlgItemText(IDC_EDIT1_1+(i*10)+j,"");
//			}
//		}
//	}
//}


void CSudokuEngine::CountRenNum()
{
	int tmp;
	//rem값을 9로초기화
	for(int i=1;i<=9;i++)
	{
		 rem_num[i]=9;
	}

	//rem값을 계산
	for(int i=1;i<=9;i++)
	{
		for(int j=1;j<=9;j++)
		{
			tmp = mat[i][j][0];
			rem_num[tmp]--;
		}
	}
}

int CSudokuEngine::expect_count(char *count, int *solve)
{
	int cnt=0;	//숫자를 세는 변수
	int i;
	for(i=1;i<=9;i++)
	{

		if( *(count+i) != TRUE)
		{
			cnt++;
			*solve = i;
		}
	}
	return cnt;

}

int CSudokuEngine::empty_count()		//count배열을 비운다.
{
	int i;
	for(i=0;i<=9;i++)
		count[i] = FALSE;
	return 0;
}

int CSudokuEngine::fill_blank()
{
	int i,j,l,m,n,o;
	for(o=0;o<100;o++)
	{
		empty_count();
		for(l=0;l<=6;l+=3)	//정사각 아홉칸( 3X3 )을 나누기 위해 3씩 점프
		{
			for(m=0;m<=6;m+=3)
			{
				for(i=1;i<=3;i++)
				{
					for(j=1;j<=3;j++)
					{
						if(count[ mat[l+i][m+j][0] ] == FALSE)	//count배열안에 중복이 있는지 검사
							count[ mat[l+i][m+j][0] ] = TRUE;
						else
						{
							if( mat[l+i][m+j][0] !=0 )
							{
								
								return -1;
							}
						}
					}
					for(j=1;j<=3;j++)
					{
						if(mat[l+i][m+j][0] ==0)
							for(n=1;n<=9;n++)
								if(count[n] == TRUE)	//mat상에서 중복으로 TRUE가 되도록 count
									//에서 TRUE만 선별해서 입력
									mat[l+i][m+j][n] = TRUE ;
								
					}
				}
				empty_count();	//정사각을 다 검사한후 다음 검사전에 
				//배열을 초기화
			}
		}
		//가로줄 검사
		empty_count();
		for(i=1;i<=9;i++)
		{
			for(j=1;j<=9;j++)
			{
				if(count[ mat[i][j][0] ] == FALSE)	//count배열안에 중복이 있는지 검사
					count[ mat[i][j][0] ] = TRUE;
				else
				{
					if( mat[i][j][0] != 0 )
					{
						
						return -1;
					}
				}
			}
			for(j=1;j<=9;j++)
			{
				if(mat[i][j][0] ==0)
					for(n=1;n<=9;n++)
						if(count[n] == TRUE)
							mat[i][j][n] = TRUE ;
						
			}
			empty_count();
		}
		
		
		//세로줄 검사
		empty_count();
		for(j=1;j<=9;j++)
		{
			for(i=1;i<=9;i++)
			{
				if(count[ mat[i][j][0] ] == FALSE)	//count배열안에 중복이 있는지 검사
					count[ mat[i][j][0] ] = TRUE;
				else
				{
					if( mat[i][j][0] != 0 )
					{
						
						return -1;
					}
				}
			}
			for(i=1;i<=9;i++)
			{
				if(mat[i][j][0] ==0)
					for(n=1;n<=9;n++)
						if(count[n] == TRUE)
							mat[i][j][n] = TRUE ;
						
			}
			empty_count();
		}
		
		for(i=1;i<=BOARD_SIZE;i++)	//rem_num배열을 초기화
			rem_num_tmp[i]=rem_num[i];
		for(i=1;i<=9;i++)
		{
			for(j=1;j<=9;j++)
			{
				n=expect_count(&(mat[i][j][0]),&solve);
				
				if(n==1)
				{
					mat[i][j][0] = solve;	//정답을 배열에 입력
					CheckOutNum(i,j, solve);	//테스트용코드*********
					rem_num_tmp[solve]--;
				}
				
				
			}
		}
	}
	return 0;
}

BOOL CSudokuEngine::OnSolve() 
{
	int i;
	// TODO: Add your control notification handler code here
	mode =3;	//현재 모드를 게임끝으로 설정
	int rtn_value;
	for(i=0;i<100;i++)
		rtn_value = fill_blank();

	if(rtn_value == -1)
	{
		//MessageBox("입력값이 잘못 되었습니다.");
		return FALSE;
	}
	else
	{		//계산이 성공적으로 끝났을때
		//Invalidate();
	}

	MatToTmp(1,1);
	
	if( CheckSolution() !=0 )	//단순계산으로 해결이 안될경우 고급모드로 계산함
	{
		//MessageBox("고급모드로 계산함");
		rtn_value = ExpertSolve(0);
	}
	return TRUE;
}

BOOL CSudokuEngine::OnNew(int nLevel) 
{
	
	if( MakeNewGame(nLevel) != 0) {
		//MessageBox("새 게임을 만드는데 실패했습니다.");
		return FALSE;
	}
	return TRUE;
}

void CSudokuEngine::OnEdit() 
{
	// TODO: Add your control notification handler code here
	int i,j;
	// TODO: Add your control notification handler code here
	
	mode = 2;	//현재모드를 편집 모드로 설정
	for(i=1;i<=9;i++)
	{
		for(j=1;j<=9;j++)
		{
			mat_readonly[i][j] = 0;
		}
	}
//	mat_ed[1][1]->SetFocus();	//첫번째칸으로 포커스이당
//
//	m_bn_check.EnableWindow(FALSE);	//정답체크버턴 비활성
//	m_bn_solve.EnableWindow(FALSE);	//정답풀이버턴 비활성
//	m_bn_start.EnableWindow(TRUE);	//시작버턴 활성
//	
//	
//	m_title1.ShowWindow(SW_HIDE);	//타이틀 문자를 삭제
//	m_title2.ShowWindow(SW_HIDE);
//	m_title3.ShowWindow(SW_HIDE);
//	Invalidate();
}

void CSudokuEngine::OnStart() 
{
	
	mode = 1;	//현재모드를 게임중 모드로 설정
	// TODO: Add your control notification handler code here
//	m_bn_check.EnableWindow(TRUE);
//	m_bn_solve.EnableWindow(TRUE);
	Trans_EditBox();
}

int CSudokuEngine::Trans_EditBox()//편집모드로 입력한 값을 읽기전용 EditBox로 전환하여 준다.
{
	int i,j;
	for(i=1;i<=9;i++)
	{
		for(j=1;j<=9;j++)
		{
			if(mat[i][j][0] != 0)
			{
//				mat_ed[i][j]->SetReadOnly();
				mat_readonly[i][j]=1;
			}else{
				mat_readonly[i][j]=0;
			}
		}
	}
	return 0;
}

int CSudokuEngine::GetSolvedTile(int x, int y)
{
	return mat[x+1][y+1][0];
}
void CSudokuEngine::OnCheck() 
{
	// TODO: Add your control notification handler code here

	if( CheckSolution() == 0 )	//정답일때
		;//MessageBox("정답입니다.");
	else		//오답일때
		;//MessageBox("오답입니다.");
}


int CSudokuEngine::CheckSolution()	//입력된값이 답이 맞는지 검사	0을리턴하면 맞고 -1은 틀립
{
	int i,j,l,m;

	for(i=1;i<=9;i++)	//빈칸( 0 ) 이 있는지 검사
		for(j=1;j<=9;j++)
			if(mat[i][j][0] == 0)	//빈칸이 있으면 정답이 아니라고 판단
				return -1;
	empty_count();
	for(l=0;l<=6;l+=3)	//정사각 아홉칸( 3X3 )을 나누기 위해 3씩 점프
	{
		for(m=0;m<=6;m+=3)
		{
			for(i=1;i<=3;i++)
			{
				for(j=1;j<=3;j++)
				{
					if(count[ mat[l+i][m+j][0] ] == FALSE)	//count배열안에 중복이 있는지 검사
						count[ mat[l+i][m+j][0] ] = TRUE;
					else
					{
						if( mat[l+i][m+j][0] !=0 )
						{
							
							return -1;
						}
					}
				}
				
			}
			empty_count();	//정사각을 다 검사한후 다음 검사전에 
			//배열을 초기화
		}
	}
	//가로줄 검사
	empty_count();
	for(i=1;i<=9;i++)
	{
		for(j=1;j<=9;j++)
		{
			if(count[ mat[i][j][0] ] == FALSE)	//count배열안에 중복이 있는지 검사
				count[ mat[i][j][0] ] = TRUE;
			else
			{
				if( mat[i][j][0] != 0 )
				{
					
					return -1;
				}
			}
		}
		
		empty_count();
	}
	
	
	//세로줄 검사
	empty_count();
	for(j=1;j<=9;j++)
	{
		for(i=1;i<=9;i++)
		{
			if(count[ mat[i][j][0] ] == FALSE)	//count배열안에 중복이 있는지 검사
				count[ mat[i][j][0] ] = TRUE;
			else
			{
				if( mat[i][j][0] != 0 )
				{
					
					return -1;
				}
			}
		}
		
		empty_count();
	}
	return 0;
	
}

int CSudokuEngine::TmpToMat(int y, int x)	//인자값은 어느위치부터 그 뒤를 복사할건지 설정
{
	int i,j,k,seq=0;
	for(i=y;i<=9;i++)	//mat_tmp에 mat를 복사
	{
		if(seq ==0)
		{
			j=x;
			seq=1;
		}
		else
		{
			j=1;
		}
		for(j=x;j<=9;j++)
		{
			for(k=1;k<=9;k++)
			{
				mat[i][j][k] = mat_tmp[i][j][k];
			}
		}
	}
	return 0;
}

int CSudokuEngine::MatToTmp(int y, int x)	//인자값은 어느위치부터 그 뒤를 복사할건지 설정
{
	int i,j,k,seq=0;
	for(i=y;i<=9;i++)	//mat_tmp에 mat를 복사
	{
		if(seq ==0)
		{
			j=x;
			seq=1;
		}
		else
		{
			j=1;
		}
		for(;j<=9;j++)
		{
			for(k=1;k<=9;k++)
			{
				mat_tmp[i][j][k] = mat[i][j][k];
			}
		}
	}
	return 0;

}

int CSudokuEngine::ExpertSolve(int index)
{
	int i,j,k;
	for(i=1;i<=9;i++)	
	{	
		for(j=1;j<=9;j++)
		{
			if(mat[i][j][0] != 0)	//현재칸이 빈칸(0)이 아니면 넘어감
			{

				continue;
			}

			for(k=1;k<=9;k++)
			{
				
				if( mat[i][j][k] == FALSE)	//칸에 숫자가 있거나 빈칸에 후보숫자가 있으면 if를 실행
				{
					
					MatToIdx(index);	//현재의 상태를 백업

					mat[i][j][0] = k; //mat안에 예상 숫자를 입력함
					CheckOutNum(i,j,k);
					//fill_blank();
					
							

					if( ExpertSolve(index+1) == 0)
					{
						//MessageBox("재귀 성공복귀");
						return 0;
					}
					
					mat_idx[index][i][j][k] = TRUE;	//현재 입력된 숫자를 후보에서 지움
					IdxToMat(index);	//입력이 잘못되어 백업한것을 불러옴
				}
			}
			if(k==10)
			{
				mat[i][j][0]=0;

				return -1;
			}
			
		}
	}
	
	//MessageBox("답확인");
	//return 0;
	if(CheckSolution() ==0)		//답이 맞는지 확인함
	{
		//Invalidate();
		return 0;
	}
	
	

	return -1;	//답이 틀림

}

int CSudokuEngine::CheckOutNum(int y, int x, int num)
{
	int i,j,k,l;
	
	
	for(i=1;i<=9;i++)
	{
		if( i !=x )		//자기자신이 지워지는걸 방지
			mat[y][i][num] = TRUE;
		if( i !=y)	//자기자신이 지워지는걸 방지
			mat[i][x][num] = TRUE;
	}
	k= (y-1)%3;
	i= y-k;
	k=i+2;
	for(;i<=k;i++)
	{
		l= (x-1)%3;
		j= x-l;
		l= j+2;
		for(;j<=l;j++)
		{
			if((i!=y)&&(j!=x))
				mat[i][j][num] = TRUE;
		}
	}
	return 0;
	
}

int CSudokuEngine::MatToIdx(int index)
{
	memcpy(mat_idx[index],mat,mat_size);
	/*
	int i,j,k;
	for(i=1;i<=9;i++)	//mat_tmp에 mat를 복사
	{
		for(j=1;j<=9;j++)
		{
			for(k=1;k<=9;k++)
			{
				mat_idx[index][i][j][k] = mat[i][j][k];
			}
		}
	}
	*/
	return 0;
}

int CSudokuEngine::IdxToMat(int index)
{
	memcpy(mat,mat_idx[index],mat_size);
	/*
	int i,j,k;
	for(i=1;i<=9;i++)	//mat_tmp에 mat를 복사
	{
		
		for(j=1;j<=9;j++)
		{
			for(k=1;k<=9;k++)
			{
				mat[i][j][k] = mat_idx[index][i][j][k];
			}
		}
	}
	*/
	return 0;

}



int CSudokuEngine::MakeNewGame(int diff)
{
	int i,j,k;
	int random_num=0;	//랜덤숫자를 사용하여 판을 만듬
	//int out=0;
	srand(time(NULL)); 
	
	random_num=0;

	//EditBox의 내용을 지우고 활성화한다
	for(i=1;i<=9;i++)
	{
		for(j=1;j<=9;j++)
		{
//			mat_ed[i][j]->Clear();
//			mat_ed[i][j]->SetReadOnly(FALSE);
		}
	}

	//mat배열의 내용을 지운다
	for(i=1;i<=9;i++)
	{
		for(j=1;j<=9;j++)
		{
			for(k=0;k<=9;k++)
			{
				mat[i][j][k] = 0;
			}
		}
	}

	//count배열에 랜덤값 입력
	MakeCountRandom(0);
	

	//count에 들어있는 랜덤값을 mat의 가로배열에 넣는 작업
	
	for(i=1;i<=9;i++)	
	{
		mat[1][i][0] = count[i];
	}

	//count배열에 랜덤값 입력
	MakeCountRandom(mat[1][1][0]);

	//count에 들어있는 랜덤값을 mat의 세로배열에 넣는 작업
	for(i=6;i<=9;i++)//3x3배열안의 숫자와 가로배열의 숫자의 충돌방지위해 4부터입력
	{
		mat[i][1][0] = count[i];
	}

	
	OnSolve();	//랜덤값이 주어진 mat배열의 나머지 칸을 풀어서 채움.
	//ExpertSolve(1);
	
	//다만들어진 게임에 빈칸을 만드는 작업
	random_num = rand() % 5;
	for(i=1;i<=9;i++)
	{
		for(j=1;j<=9;j++)
		{
			for(k=0;k<=9;k++)
			{
				if(k==0)
				{
					if(mat_new[diff][random_num][i][j] == '0')
						mat[i][j][0]=0;
				}else{
					mat[i][j][k]=0;
				}
				
			}
		}
	}

	OnStart();	//start버턴을 눌러 숫자가 들어간 칸은 Read-Only로 변환

	return 0;

}

int CSudokuEngine::RandomCheck(char count[],int random_num)
{
	int i;
	for(i=1;i<=9;i++)
	{
		if(count[i]==random_num)
			return -1;	//중복이 있는것으로 리턴
	}
	return 0;	//중복이 없는것으로 리턴

}

int CSudokuEngine::MakeCountRandom(int not_num)
{
	int i=1,random_num;
	//count배열에 랜덤값 입력
	empty_count();
	if(not_num !=0)
	{
		i=4;
		count[1] = not_num;
	}
	while(1)
	{
		
		if(i==10)
			break;
		
		random_num = (rand() % 9) + 1;
		
		
		while(RandomCheck(count,random_num) != 0)
		{
			random_num = (rand() % 9) + 1;
		}
		
		count[i] = random_num;
		
		i++;
		
	}
	return 0;

}

/** Return the tile at the given coordinates */
int CSudokuEngine::GetTile(int x, int y) 
{
	return tiles[x][y];
}
/** Change the tile at the given coordinates */
void CSudokuEngine::SetTile(int x, int y, int value)
{
	tiles[x][y] = value;
	mat[x+1][y+1][0] = value;
}
/** Change the tile only if it's a valid move */
BOOL CSudokuEngine::SetTileIfValid(int x, int y, int value)
{
	if (value < 0)
		return FALSE;
	NSMutableArray* tiles = GetUsedTiles(x, y);
	if (value != 0) {
		for (int i = 0; i < [tiles count]; i ++) {
			int tile = [[tiles objectAtIndex:i] intValue];
			if (tile == value)
				return false;
		}
	}
	SetTile(x, y, value);
	CalculateUsedTiles();
	return YES;
}
/** */
BOOL CSudokuEngine::SetTileIfAnyOne(int x, int y, int value)
{
	SetTile(x, y, value);
	CalculateUsedTiles();
	return YES;
}
BOOL CSudokuEngine::SetSmallNumber(int x, int y, int value)
{
	if (m_arraySmall[x][y] == nil) {
		m_arraySmall[x][y] = [[NSMutableArray alloc] init];
	}
	
	for (int i = 0; i < m_arraySmall[x][y].count; i ++) {
		int nSmall = [[m_arraySmall[x][y] objectAtIndex:i] intValue];
		if (nSmall == value) {
			//[m_arraySmall[x][y] removeObjectAtIndex:i];
			return FALSE;
		}
	}
	[m_arraySmall[x][y] addObject:[NSNumber numberWithInt:value]];
	 return TRUE;
}
void CSudokuEngine::ResetSmallNumber(int x, int y)
{
	if (m_arraySmall[x][y] == nil)
		return;
	[m_arraySmall[x][y] release];
	m_arraySmall[x][y] = nil;
}
BOOL CSudokuEngine::IsSmallNumber(int x, int y)
{
	if (m_arraySmall[x][y] == nil || m_arraySmall[x][y].count <= 0) {
		return FALSE;
	}
	return TRUE;
}
/** Return cached used tiles visible from the given coords */
NSMutableArray* CSudokuEngine::GetUsedTiles(int x, int y)
{
	return m_arrayUsed[x][y];
}
NSMutableArray* CSudokuEngine::GetSmallNumbers(int x, int y) 
{
	return m_arraySmall[x][y];
}
/** Compute the two dimensional array of used tiles */
void CSudokuEngine::CalculateUsedTiles()
{
	for (int x = 0; x < 9; x++) {
		for (int y = 0; y < 9; y++) {
			if (m_arrayUsed[x][y])
				[m_arrayUsed[x][y] release];
			m_arrayUsed[x][y] = [[NSMutableArray alloc] initWithArray:CalculateUsedTiles(x, y)];
		}
	}
}
/** Compute the used tiles visible from this position */
NSMutableArray* CSudokuEngine::CalculateUsedTiles(int x, int y)
{
	int c[9] = {0};
	memset(c, 0, sizeof(c));
	// horizontal
	for (int i = 0; i < 9; i++) {
		if (i == y)
			continue;
		int t = GetTile(x, i);
		if (t != 0)
			c[t - 1] = t;
	}
	// vertical
	for (int i = 0; i < 9; i++) {
		if (i == x)
			continue;
		int t = GetTile(i, y);
		if (t != 0)
			c[t - 1] = t;
	}
	// same cell block
	int startx = (x / 3) * 3;
	int starty = (y / 3) * 3;
	for (int i = startx; i < startx + 3; i++) {
		for (int j = starty; j < starty + 3; j++) {
			if (i == x && j == y)
				continue;
			int t = GetTile(i, j);
			if (t != 0)
				c[t - 1] = t;
		}
	}
	// compress
	NSMutableArray* array = [[[NSMutableArray alloc] init] autorelease];
	for (int i = 0; i < 9; i ++) {
		if (c[i] == 0)
			continue;
		[array addObject:[NSNumber numberWithInt:c[i]]];
	}
	return array;
}

/** Compute the two dimensional array of used tiles */
void CSudokuEngine::CalculateGivenTiles() {
	for (int x = 0; x < 9; x++) {
		for (int y = 0; y < 9; y++) {
			given[x][y] = tiles[x][y] > 0 ? YES : NO;
		}
	}
}

BOOL CSudokuEngine::IsGiven(int x, int y)
{
	return (BOOL)given[x][y];
}
bool CSudokuEngine::IsCompleted()
{
	for (int x = 0; x < 9; x++) {
		for (int y = 0; y < 9; y++) {
			if (tiles[x][y] == 0) {
				return NO;
			}
		}
	}
	return YES;
}

void CSudokuEngine::SetSelectedTile(int tile)
{
//	if (IsGiven:m_nSelX y:m_nSelY] == FALSE) {
//		if ([self setTileIfValid:m_nSelX y:m_nSelY value:tile]) {
//			if ([self isCompleted]) {
//				//kgh
//			}
//		}
//	}
}


