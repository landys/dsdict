//
//  ImageRecognizer.h
//  tcidsd
//
//  Created by Jinde Wang on 31/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageCore.h"

@interface ImageRecognizer : NSObject {
    ImageCore* mpChars;
}

// return the length of guessing word.
- (int)recognizeImage:(UIImage*)ipImage oCharts:(NSMutableString*)opChars;

@end
