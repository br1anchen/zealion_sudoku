//
//  PictureViewController.m
//  Sudoku
//
//  Created by Kwang on 11/05/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PictureViewController.h"
#import "StageViewController.h"
#import "GameOptionInfo.h"
#import "ImageManipulator.h"
#import "MKStoreManager.h"
#import "BuyViewController.h"

#define kTagKeyIcon		40
//#define FULL_TEST

@implementation PictureViewController

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
	//	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	// Add the Insert button
//	UIBarButtonItem *menuButton= [[[UIBarButtonItem alloc]
//								   initWithTitle:NSLocalizedString(@"Menu", @"")
//								   style:UIBarButtonItemStyleBordered
//								   target:self
//								   action:@selector(menuAction:)] autorelease];
//	
//	self.navigationItem.rightBarButtonItem = menuButton;
	//	[self.navigationItem.leftBarButtonItem = self.editButtonItem;
	//	self.navigationController.navigationItem
}
- (void)viewWillAppear:(BOOL)animated {
	m_bHideNavBar = TRUE;
    if (g_GameOptionInfo.m_nGameType == GAME_PUZZLE)
        self.title = @"Puzzudoku";
    else
        self.title = @"Picture Puzzle";
    m_btnGetMore.enabled = ([g_GameOptionInfo getBuyPackCount] > 0);//(g_GameOptionInfo.m_nEnablePackCount < PICTURE_COUNT-1);
	[super viewWillAppear:animated];
    [m_viewTable reloadData];
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
}


- (void)dealloc {
    [super dealloc];
}

-(IBAction) onMorePiture:(id)sender {
//	StageViewController* controller = [[StageViewController alloc] init];
//	[self.navigationController pushViewController:controller animated:YES];
//	[controller release];
    self.title = @"Back";
    m_bHideNavBar = NO;
    BuyViewController* controller;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		controller = [[BuyViewController alloc] initWithNibName:@"BuyViewController_iPhone" bundle:nil];
	}
	else {
		controller = [[BuyViewController alloc] initWithNibName:@"BuyViewController_iPad" bundle:nil];
	}
	
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
    
//    if (g_GameOptionInfo.m_nEnablePackCount < PICTURE_COUNT) {
//        int index = g_GameOptionInfo.m_nEnablePackCount;
//        if ([MKStoreManager featurePurchased:index] == FALSE) {
//            [[MKStoreManager sharedManager] buyFeatureWithIndex:index];
//        }
//    }
}

-(void) menuAction:(id)sender {
	[self.navigationController popViewControllerAnimated:TRUE];
}

-(CGFloat) getCellHeight {
	CGFloat height = 57;
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)
		height = 140;
	return height;	
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
//    MyDetailController *controller = [[MyDetailController alloc]
//                                      initWithStyle:UITableViewStyleGrouped];
//    
//    NSUInteger index = [indexPath row];
//    id book = [[self displayedObjects] objectAtIndex:index];
//    
//    [controller setBook:book];
//    [controller setTitle:[book title]];
//    
//    [[self navigationController] pushViewController:controller
//                                           animated:YES];
//	[controller release];
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
//#ifndef FULL_TEST
//    if (indexPath.row >= DEFAULT_PICCOUNT) 
//    {
//        if ([MKStoreManager featureAPurchased] == FALSE) {
//            [[MKStoreManager sharedManager] buyFeatureA];
//        }
//    }
//#endif
    
	NSUInteger index = [indexPath row];
    if(indexPath.row == g_GameOptionInfo.m_nEnablePackCount)
    {
        [[MKStoreManager sharedManager] buyFeatureWithIndex:7];
    }else{
        NSDictionary* data;
    
        if (g_GameOptionInfo.m_nGameType == GAME_PUZZLE){
            if(index < 4){
                data = [g_GameOptionInfo.m_arrayPuzzlePackInfo objectAtIndex:indexPath.row];
            }else{
                data = [g_GameOptionInfo.m_arrayPuzzlePackInfo objectAtIndex:[g_GameOptionInfo getBuyPackIndexByListId:index]];
            }
        }else{
            if(index < 4){
                data = [g_GameOptionInfo.m_arrayPicturePackInfo objectAtIndex:indexPath.row];
            }else{
                data = [g_GameOptionInfo.m_arrayPicturePackInfo objectAtIndex:[g_GameOptionInfo getBuyPackIndexByListId:index]];
            }
        }    
#ifndef FULL_TEST
        if ([[data objectForKey:@"Lock"] boolValue] == FALSE) 
#endif
        {
            self.title = @"Back";
            m_bHideNavBar = NO;
            g_GameOptionInfo.m_nSelectedPack = index;
            StageViewController* controller = [[StageViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];	
        }
    }
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
#ifdef FULL_TEST
    return PICTURE_COUNT;
#else
    return g_GameOptionInfo.m_nEnablePackCount + 1;//g_GameOptionInfo.m_nEnablePackCount;
#endif
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
		CGFloat titleFontSize, detailFontSize;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			titleFontSize = 12.0;
			detailFontSize = 10.0;
		}
		else {
			titleFontSize = 31.0;
			detailFontSize = 28.0;
		}
        
        UIFont *titleFont = [UIFont fontWithName:@"Georgia-BoldItalic" size:titleFontSize];
        [[cell textLabel] setFont:titleFont];
        
        UIFont *detailFont = [UIFont fontWithName:@"Georgia" size:detailFontSize];
        [[cell detailTextLabel] setFont:detailFont];
        
        [cell autorelease];
    }
	else
	{
		// the cell is being recycled, remove old embedded controls
		UIView *viewToRemove = nil;
		viewToRemove = [cell.contentView viewWithTag:kTagKeyIcon];
		if (viewToRemove)
			[viewToRemove removeFromSuperview];
	}
    
    NSUInteger index = [indexPath row];
    if(indexPath.row == g_GameOptionInfo.m_nEnablePackCount)
    {
        [[cell textLabel] setText:@"UnlockAllPacks"];
        
        NSString* strImg = @"unlock.jpg";
        UIImage* img = [[UIImage imageNamed:strImg] retain];
        [[cell imageView] setImage:[ImageManipulator makeRoundCornerImage:img :40 :40]];
        [img release];
        NSString *detailText = @"To unlock all stages in your packs.";
        [[cell detailTextLabel] setText:detailText];
        return cell;
    }
	NSDictionary* data;
    if (g_GameOptionInfo.m_nGameType == GAME_PUZZLE){
        if(index < 4){
            data = [g_GameOptionInfo.m_arrayPuzzlePackInfo objectAtIndex:indexPath.row];
        }else{
            data = [g_GameOptionInfo.m_arrayPuzzlePackInfo objectAtIndex:[g_GameOptionInfo getBuyPackIndexByListId:index]];
            index = [g_GameOptionInfo getBuyPackIndexByListId:index];
        }
    }else{
        if(index < 4){
            data = [g_GameOptionInfo.m_arrayPicturePackInfo objectAtIndex:indexPath.row];
        }else{
            data = [g_GameOptionInfo.m_arrayPicturePackInfo objectAtIndex:[g_GameOptionInfo getBuyPackIndexByListId:index]];
            index = [g_GameOptionInfo getBuyPackIndexByListId:index];
        }
    }    
	NSString* strName = (NSString*)[data objectForKey:@"Name"];
    [[cell textLabel] setText:strName];
    
	int nProblem = [[data objectForKey:@"Problem"] intValue];
	int nSolve = [[data objectForKey:@"Solve"] intValue];
    NSString *detailText = [NSString stringWithFormat:@"Completed:%d/%d",nSolve,nProblem];
    [[cell detailTextLabel] setText:detailText];

	UIImage* img;
	UIImageView* imgView = nil;
	CGFloat cellW = m_viewTable.bounds.size.width;
	CGFloat cellH = [self getCellHeight];
	CGFloat offsetX = 10;
	if (nSolve >= nProblem) {
		img = [[UIImage imageNamed:SHImageString(@"Star", @"png")] retain];
		imgView = [[UIImageView alloc] initWithFrame:CGRectMake(cellW-img.size.width-offsetX, (cellH-img.size.height)/2, img.size.width, img.size.height)];
		imgView.image = img;
		[img release];
	}
	else if ([[data objectForKey:@"Lock"] boolValue]) {
		img = [[UIImage imageNamed:SHImageString(@"key", @"png")] retain];
		imgView = [[UIImageView alloc] initWithFrame:CGRectMake(cellW-img.size.width-offsetX, (cellH-img.size.height)/2, img.size.width, img.size.height)];
		imgView.image = img;
		[img release];
	}
    
	if (imgView) {
		imgView.tag = kTagKeyIcon;
		[cell.contentView addSubview:imgView];
        [imgView release];
	}		
	
	//NSString* strImg = [NSString stringWithFormat:@"Choose_pic%02d", index];
    NSString* strImg = [NSString stringWithFormat:@"thumb_%02d", index];
    //img = [[UIImage imageNamed:SHImageString(strImg, @"png")] retain];
    img = [[UIImage imageNamed:strImg] retain];
    //[[cell imageView] setImage:[self getPackImage:index]];
    [[cell imageView] setImage:[ImageManipulator makeRoundCornerImage:img :40 :40]];
	[img release];
    
    return cell;
}

-(UIImage*) getPackImage:(int)pack {
	UIImage* img;
	NSString* strImg;
	if (pack < PICTURE_COUNT) {
//        strImg = [NSString stringWithFormat:@"%@01.jpg", [g_GameOptionInfo getPackName:pack]];
        strImg = [g_GameOptionInfo getPackImageFilePath:pack stage:0];
//		switch (pack) {
//			case PICTURE_CITY:
//				strImg = @"city21.png";
//				break;
//			case PICTURE_NATURE:
//				strImg = @"Nature01.png";
//				break;
//			case PICTURE_ART:
//				strImg = @"art01.png";
//				break;
//			default:
//				break;
//		}
//		UIImage* imgOrg = [[UIImage imageNamed:strImg] retain];
        UIImage* imgOrg = [[UIImage alloc] initWithContentsOfFile:strImg];
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
