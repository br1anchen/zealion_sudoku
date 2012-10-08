//
//  OptionViewController.m
//  Sudoku
//
//  Created by Kwang on 11/05/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OptionViewController.h"
#import "GameOptionInfo.h"


@implementation OptionViewController

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
	m_nToggleIcon = -1;
	[self changeToggleIcon:g_GameOptionInfo.m_nToggleIconType];
	m_nBgType = -1;
	[self changeBgType:g_GameOptionInfo.m_nBgType];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
    [super dealloc];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch* touch = [touches anyObject];
	if(1 == touches.count && 1 == [touch tapCount]) {
		//Add Code
		CGPoint point = [touch locationInView:self.view];
		CGRect rt;
		CGFloat x = 30*SCALE_SCREEN_WIDTH, y = 310*SCALE_SCREEN_HEIGHT, offsetY = 134*SCALE_SCREEN_HEIGHT; 
		CGFloat width = 710*SCALE_SCREEN_WIDTH, height = 70*SCALE_SCREEN_HEIGHT;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			
		}
		for (int i = 0; i < TOGGLE_COUNT; i ++) {
			rt = CGRectMake(x, y, width, height);
			if (CGRectContainsPoint(rt, point)) {
				[self changeToggleIcon:i];
				return;
			}
			y += offsetY;
		}
		x = 92*SCALE_SCREEN_WIDTH;
		y = 750*SCALE_SCREEN_HEIGHT;
		width = 260*SCALE_SCREEN_WIDTH;
		height = 90*SCALE_SCREEN_HEIGHT;
		CGFloat offsetX = 330*SCALE_SCREEN_WIDTH;
		for (int i = 0; i < 2; i ++) {
			rt = CGRectMake(x, y, width, height);
			if (CGRectContainsPoint(rt, point)) {
				[self changeBgType:i];
				return;
			}
			x += offsetX;
		}
	}
}

-(void) changeToggleIcon:(int)toggle {
	if (m_nToggleIcon == toggle)
		return;
	m_imgSymbals.hidden = YES;
	m_imgColors.hidden = YES;
	m_imgNumbers.hidden = YES;
	switch (toggle) {
		case TOGGLE_SYMBOLS:
			m_imgSymbals.hidden = NO;
			break;
		case TOGGLE_COLORS:
			m_imgColors.hidden = NO;
			break;
		case TOGGLE_NUMBERS:
			m_imgNumbers.hidden = NO;
			break;
		default:
			break;
	}
	m_nToggleIcon = toggle;
}

-(void) changeBgType:(int)bgtype {
	if (m_nBgType == bgtype)
		return;
	m_imgBgLight.hidden = YES;
	m_imgBgDark.hidden = YES;
	switch (bgtype) {
		case BG_LIGHT:
			m_imgBgLight.hidden = NO;
			break;
		case BG_DARK:
			m_imgBgDark.hidden = NO;
			break;
		default:
			break;
	}
	m_nBgType = bgtype;
}

-(IBAction) onDone:(id)sender {
	g_GameOptionInfo.m_nToggleIconType = m_nToggleIcon;
	g_GameOptionInfo.m_nBgType = m_nBgType;
	[self.navigationController popViewControllerAnimated:YES];
}

@end
