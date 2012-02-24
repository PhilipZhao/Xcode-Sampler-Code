//
//  UIImage+imageUtil.h
//  Passim
//
//  Created by Philip Zhao on 2/24/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (imageUtil)

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;
@end
