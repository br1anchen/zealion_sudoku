//
//  HelpViewController.h
//  Sudoku
//
//  Created by  on 11/11/17.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpViewController : UIViewController {
    IBOutlet UIScrollView*  m_scrollView;
    IBOutlet UIView*        m_viewText;
}

- (void) setTextView;
- (IBAction)addressClick:(UIButton*)sender;

@end
