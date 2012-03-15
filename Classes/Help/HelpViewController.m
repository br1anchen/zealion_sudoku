//
//  HelpViewController.m
//  Sudoku
//
//  Created by  on 11/11/17.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HelpViewController.h"

@implementation HelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    [self setTextView];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.backBarButtonItem =
	[[[UIBarButtonItem alloc] initWithTitle:@"Back"
									  style: UIBarButtonItemStylePlain
									 target:nil
									 action:nil] autorelease];
}
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self setTitle:@"How to Play"];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
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

- (void) setTextView {
    [m_scrollView addSubview:m_viewText];
    [m_scrollView setContentSize:m_viewText.bounds.size];
}

- (IBAction)addressClick:(UIButton *)sender
{
    if(sender.tag==0)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:info@youarebacon.com"]];
    }
    else if(sender.tag==1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://YouAreBacon.com"]];
    }
}
@end
