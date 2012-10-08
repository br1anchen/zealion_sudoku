//
//  BoardView.h
//  Sudoku
//
//  Created by  on 11/12/02.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BoardViewDelegate

- (void) onSingleTouch:(CGPoint) pos;
- (void) onDoubleTouch:(CGPoint) pos;
- (void) onZoomin:(CGPoint) pos;
- (void) onZoomout:(CGPoint)pos;

@end
@interface BoardView : UIView {
    id<BoardViewDelegate> delegate;
}

@property (nonatomic, assign) id<BoardViewDelegate> delegate;

- (id) initWithRect:(CGRect)frame;
- (void) setResize:(CGRect)rect;
@end
