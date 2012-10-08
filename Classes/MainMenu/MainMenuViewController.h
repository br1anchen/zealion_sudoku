//
//  MainMenuViewController.h
//  Sudoku
//
//  Created by Kwang on 11/05/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MainMenuViewController : UIViewController {
	IBOutlet UIButton* m_btnResume;
    UIAlertView*            m_alertMain;
    UIActivityIndicatorView *m_activityIndicator;
}

-(IBAction) onPlay:(id)sender;
-(IBAction) onResumeGame:(id)sender;
-(IBAction) onClassicSudoku:(id)sender;
-(IBAction) onPictureSudoku:(id)sender;
-(IBAction) onOption:(id)sender;
-(IBAction) onHelp:(id)sender;

-(BOOL) isMustDownload;
-(void) downloadPack;
-(void) startDownloadPack;
-(void) endDownloadPack;

@end
