//
//  BoardView.m
//  Sudoku
//
//  Created by  on 11/12/02.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BoardView.h"
#import "GameOptionInfo.h"

@implementation BoardView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        //---pinch gesture--- 
        UIPinchGestureRecognizer *pinchGesture =
        [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
        [self addGestureRecognizer:pinchGesture]; 
        [pinchGesture release];
        
        // Create gesture recognizer 
        UITapGestureRecognizer *oneFingerTwoTaps = 
        [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerTwoTaps:)] autorelease]; 
        
        // Set required taps and number of touches 
        [oneFingerTwoTaps setNumberOfTapsRequired:2]; 
        [oneFingerTwoTaps setNumberOfTouchesRequired:1]; 
        
        // Add the gesture to the view 
        [self addGestureRecognizer:oneFingerTwoTaps]; 
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (id) initWithRect:(CGRect)frame {
    [self initWithFrame:frame];
#if 0
	NSString* strLine;
    
    strLine =[NSString stringWithFormat:@"line gamebg%d_dark", g_GameOptionInfo.m_nGameType];
    
	UIImage* imgLine = [[UIImage imageNamed:SHImageString(strLine, @"png")] retain];
    CGSize size = imgLine.size;
	UIImageView* imgBoardLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [imgBoardLine setImage:imgLine];
    [self addSubview:imgBoardLine];
    self.autoresizesSubviews = YES;
#endif
    return self;
}
- (void) setResize:(CGRect)rect {
    
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    UILongPressGestureRecognizer
    NSLog(@"board touch begin");
    UITouch* touch = [touches anyObject];
    if ([touches count] == 1) {
        if (self.delegate) {
            CGPoint pos = [touch locationInView:self];
//            if ([touch tapCount] == 2)
//                [delegate onDoubleTouch:pos];
//            else if ([touch tapCount] == 1)
                [delegate onSingleTouch:pos];
        }
    }
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"board touch end");
}
//---handle pinch gesture--- 
-(IBAction) handlePinchGesture:(UIGestureRecognizer *) sender {
//    NSLog(@"Pinch");
    CGFloat factor = [(UIPinchGestureRecognizer *) sender scale];
//    UIPinchGestureRecognizer* pinch = (UIPinchGestureRecognizer*)sender;
    CGPoint pos = [sender locationInView:self];
    if (factor > 1) { 
        NSLog(@"zooming in");
        //---zooming in--- 
//        UITouch* touch = [pinch touch];
        CGPoint pos = [sender locationInView:self];
        if (self.delegate)
            [delegate onZoomin:pos];
//        sender.view.transform = CGAffineTransformMakeScale(
//                                                           lastScaleFactor + (factor-1),
//                                                           lastScaleFactor + (factor-1)); 
    } 
    else {
        //---zooming out--- 
        NSLog(@"zooming out");
        if (self.delegate)
            [delegate onZoomout:pos];
//        sender.view.transform = CGAffineTransformMakeScale(lastScaleFactor * factor, lastScaleFactor * factor);
    }
//    if (sender.state == UIGestureRecognizerStateEnded) { 
//        if (factor > 1) {
//            lastScaleFactor += (factor-1); 
//        } else {
//            lastScaleFactor *= factor;
//        }
//    }
}

- (IBAction) oneFingerTwoTaps:(id)sender {
    CGPoint pos = [sender locationInView:self];
    if (self.delegate)
        [delegate onDoubleTouch:pos];
    
}
@end
