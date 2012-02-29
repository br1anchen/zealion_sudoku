//
//  BuyViewController.m
//  Sudoku
//
//  Created by Kwang on 11/10/04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BuyViewController.h"
#import "GameOptionInfo.h"
#import "ImageManipulator.h"
#import "MKStoreManager.h"


#define kTagKeyIcon		40
#define kTagKeyButton	50

@implementation BuyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        m_arrayButtons = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [m_arrayButtons release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewWillAppear:(BOOL)animated {
//	m_bHideNavBar = TRUE;
    self.title = @"Buy Pack";
	[super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
//	if (m_bHideNavBar)
//		[self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	//	[self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(CGFloat) getCellHeight {
	CGFloat height = 57;
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)
		height = 140;
	return height;	
}

-(UIButton*) getButton:(int)tag {
    if ([m_arrayButtons count] > tag)
        return [m_arrayButtons objectAtIndex:tag];
    else {
        UIButton* btn = [self createButton:tag];
        [m_arrayButtons addObject:btn];
        return btn;
    }
}
-(UIButton*) createButton:(int)tag {    
	CGRect rt;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		rt = CGRectMake(422.0, 30.0, 134.0, 66.0);
	}
	else {
		rt = CGRectMake(174.0, 16.0, 60.0, 24.0);
	}
	UIButton *button = [[[UIButton alloc] initWithFrame:rt] autorelease];
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setBackgroundImage:[UIImage imageNamed:@"buy_nor.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"bay_pre.png"] forState:UIControlStateHighlighted];
    
	[button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
	button.tag = tag;	// tag this view for later so we can remove it from recycled table cells
	button.backgroundColor = [UIColor clearColor];
//    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
//    [button setTitle:@"Buy" forState:UIControlStateNormal];
    //	CGRect frame = CGRectMake(168.0, 10.0, 176.0, 30.0);
    //	UISegmentedControl* switchCtl = [[[UISegmentedControl alloc] initWithFrame:frame] autorelease];
    //	[switchCtl addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventValueChanged];
    //	
    //	// in case the parent view draws with a custom color or gradient, use a transparent color
    //	switchCtl.backgroundColor = [UIColor clearColor];
    //	
    //	//[switchCtl setAccessibilityLabel:NSLocalizedString(@"StandardSwitch", @"")];
    //	
	return button;
}

-(void) buttonAction:(id)sender {
    UIButton* btn = (UIButton*)sender;
    int tag = btn.tag-kTagKeyButton;
    int index = [g_GameOptionInfo getBuyPackIndex:tag];
    if ([MKStoreManager featurePurchased:index] == FALSE) {
        [[MKStoreManager sharedManager] buyFeatureWithIndex:index];
    }
}
#pragma mark -
#pragma mark UITableViewDelegate Protocol
//
//  The table view's delegate is notified of runtime events, such as when
//  the user taps on a given row, or attempts to add, remove or reorder rows.

//  Notifies the delegate when the user selects a row.
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
}

#pragma mark -
#pragma mark UITableViewDataSource Protocol
//
//  By default, UITableViewController makes itself the delegate of its own
//  UITableView instance, so we can implement data source protocol methods here.
//  You can move these methods to another class if you prefer -- just be sure 
//  to send a -setDelegate: message to the table view if you do.


//  Returns the number of rows in the current section.
//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [g_GameOptionInfo getBuyPackCount];//g_GameOptionInfo.m_nEnablePackCount;
}

// to determine specific row height for each cell, override this.
// In this example, each row is determined by its subviews that are embedded.
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self getCellHeight];
}

// Return a cell containing the text to display at the provided row index.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"MyCell"];
        
        //[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		CGFloat titleFontSize, detailFontSize;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			titleFontSize = 12.0;
			detailFontSize = 10.0;
		}
		else {
			titleFontSize = 28.0;
			detailFontSize = 28.0;
		}
        
        UIFont *titleFont = [UIFont fontWithName:@"Georgia-BoldItalic" size:titleFontSize];
        [[cell textLabel] setFont:titleFont];
        
//        UIFont *detailFont = [UIFont fontWithName:@"Georgia" size:detailFontSize];
//        [[cell detailTextLabel] setFont:detailFont];
        
        [cell autorelease];
    }
	else
	{
		// the cell is being recycled, remove old embedded controls
		UIView *viewToRemove = nil;
		viewToRemove = [cell.contentView viewWithTag:kTagKeyButton+indexPath.row];
		if (viewToRemove)
			[viewToRemove removeFromSuperview];
	}
    
    NSUInteger index = [g_GameOptionInfo getBuyPackIndex:indexPath.row];
	NSDictionary* data;
	if (g_GameOptionInfo.m_nGameType == GAME_PUZZLE)
		data = [g_GameOptionInfo.m_arrayPuzzlePackInfo objectAtIndex:index];
	else
		data = [g_GameOptionInfo.m_arrayPicturePackInfo objectAtIndex:index];
    
	NSString* strName = (NSString*)[data objectForKey:@"Name"];
    [[cell textLabel] setText:strName];
        
    [cell.contentView addSubview:[self getButton:kTagKeyButton+indexPath.row]];
	
	NSString* strImg = [NSString stringWithFormat:@"Choose_pic%02d", index];
    UIImage* img = [[UIImage imageNamed:SHImageString(strImg, @"png")] retain];
    [[cell imageView] setImage:[self getPackImage:index]];
	[img release];
    
    return cell;
}

-(UIImage*) getPackImage:(int)pack {
	UIImage* img;
	NSString* strImg;
	if (pack < PICTURE_COUNT) {
        strImg = [NSString stringWithFormat:@"%@01.jpg", [g_GameOptionInfo getPackName:pack]];
//        strImg = [g_GameOptionInfo getPackImageFilePath:pack stage:0];
		UIImage* imgOrg = [[UIImage imageNamed:strImg] retain];
		img = [ImageManipulator makeRoundCornerImage:imgOrg :100 :100];
		[imgOrg release];
	}
	else {
		NSString* strImg = [NSString stringWithFormat:@"Choose_pic%02d", pack];
		img = [[UIImage imageNamed:SHImageString(strImg, @"png")] retain];
	}
	return [img autorelease];
}

@end
