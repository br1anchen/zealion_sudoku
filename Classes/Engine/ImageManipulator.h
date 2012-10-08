//
//  ImageManipulator.h
//  Sudoku
//
//  Created by Kwang on 11/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImageManipulator : NSObject {

}
+(UIImage *)makeRoundCornerImage:(UIImage*)img :(int) cornerWidth :(int) cornerHeight;

@end
