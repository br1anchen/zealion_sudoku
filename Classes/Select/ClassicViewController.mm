//
//  ClassicViewController.m
//  Sudoku
//
//  Created by Kwang on 11/05/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ClassicViewController.h"
#import "GameViewController.h"
#import "GameOptionInfo.h"


@implementation ClassicViewController

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
	self.title = @"Classic Sudoku";
//	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	// Add the Insert button
//	UIBarButtonItem *menuButton= [[[UIBarButtonItem alloc]
//								  initWithTitle:NSLocalizedString(@"Menu", @"")
//								  style:UIBarButtonItemStylePlain
//								  target:self
//								  action:@selector(menuAction:)] autorelease];
//	
//	self.navigationItem.rightBarButtonItem = menuButton;
	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.backBarButtonItem =
	[[[UIBarButtonItem alloc] initWithTitle:@"Back"
									  style: UIBarButtonItemStylePlain
									 target:nil
									 action:nil] autorelease];
	
//	[self.navigationItem.leftBarButtonItem = self.editButtonItem;
//	self.navigationController.navigationItem
}
- (void)viewWillAppear:(BOOL)animated {
	m_bHideNavBar = YES;
	g_GameOptionInfo.m_bGameState = FALSE;
    [self setCompleteLabel];
    [self setRankLabel];
	[super viewWillAppear:animated];
	[self setTitle:@"Classic Sudoku"];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if (m_bHideNavBar)
		[self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
//	[self.navigationController setNavigationBarHidden:YES animated:YES];
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
	[self.navigationController setNavigationBarHidden:YES animated:NO];
}


- (void)dealloc {
    [super dealloc];
}

-(void) setCompleteLabel {
	m_labelEasy.text = [NSString stringWithFormat:@"Completed : %d", [g_GameOptionInfo getClassicCompletedCount:LEVEL_EASY]];
	m_labelMedium.text = [NSString stringWithFormat:@"Completed : %d", [g_GameOptionInfo getClassicCompletedCount:LEVEL_MEDIUM]];
	m_labelHard.text = [NSString stringWithFormat:@"Completed : %d", [g_GameOptionInfo getClassicCompletedCount:LEVEL_HARD]];
}
-(void) setRankLabel {
    int index = [g_GameOptionInfo getClassicCompletedCount:LEVEL_EASY];
    m_labelEasyRank.text = [NSString stringWithFormat:@"Rank:%@", [self getRankString:index]];
    index = [g_GameOptionInfo getClassicCompletedCount:LEVEL_MEDIUM];
    m_labelMediumRank.text = [NSString stringWithFormat:@"Rank:%@", [self getRankString:index]];
    index = [g_GameOptionInfo getClassicCompletedCount:LEVEL_HARD];
    m_labelHardRank.text = [NSString stringWithFormat:@"Rank:%@", [self getRankString:index]];
}
-(NSString*) getRankString:(int)index {
    if (index >= 500)
        return @"Played too much";
    else if (index >= 300)
        return @"Ultimate Omnipotence";
    else if (index >= 275)
        return @"God Grand Master";
    else if (index >= 250)
        return @"God Master";
    else if (index >= 225)
        return @"Sudoku God";
    else if (index >= 200)
        return @"Super Genius";
    else if (index >= 175)
        return @"Ludicrously talented";
    else if (index >= 150)
        return @"Ultimate Player";
    else if (index >= 125)
        return @"Grand Master";
    else if (index >= 100)
        return @"Master";
    else if (index >= 75)
        return @"Expert";
    else if (index >= 50)
        return @"Professional";
    else if (index >= 35)
        return @"Adept";
    else if (index >= 25)
        return @"Experienced";
    else if (index >= 20)
        return @"Intermediate";
    else if (index >= 15)
        return @"Amateur";
    else if (index >= 10)
        return @"Novice";
    else if (index >= 5)
        return @"Beginner";
    else
        return @"Newbie";
}
-(IBAction) onEasy:(id)sender {
	g_GameOptionInfo.m_nLevel = LEVEL_EASY;
	g_GameOptionInfo.m_nSelectedStage = [g_GameOptionInfo getClassicCompletedCount:LEVEL_EASY];
	[self pushGameView];
}
-(IBAction) onMedium:(id)sender {
	g_GameOptionInfo.m_nLevel = LEVEL_MEDIUM;
	g_GameOptionInfo.m_nSelectedStage = [g_GameOptionInfo getClassicCompletedCount:LEVEL_MEDIUM];
	[self pushGameView];
}
-(IBAction) onHard:(id)sender {
	g_GameOptionInfo.m_nLevel = LEVEL_HARD;
	g_GameOptionInfo.m_nSelectedStage = [g_GameOptionInfo getClassicCompletedCount:LEVEL_HARD];
	[self pushGameView];
}

-(void) pushGameView {
	[self setTitle:@"Back"];
	m_bHideNavBar = FALSE;
	[g_GameOptionInfo createProblem:GAME_CLASSIC param:g_GameOptionInfo.m_nLevel];
	GameViewController* controller = [[GameViewController alloc] init];
//	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
//		controller = [[GameViewController alloc] initWithNibName:@"GameViewController_iPhone" bundle:nil];
//	}
//	else {
//		return;
//	}
	
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}
-(void) menuAction:(id)sender {
	[self.navigationController popViewControllerAnimated:TRUE];
}

@end
