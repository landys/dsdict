//
//  ImageCore.m
//  tcidsd
//
//  Created by Jinde Wang on 31/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageCore.h"

@interface ImageCore (Private)

- (Byte*)allocAndGetPixels:(UIImage*)ipImage;

@end

@implementation ImageCore

@synthesize mpPixels, mImgSize;

- (id)initWithUIImage:(UIImage*)ipImage {
    self = [super init];
    if (self) {
        if (ipImage) {
            mImgSize = ipImage.size;
            mpPixels = [self allocAndGetPixels:ipImage];
        }
    }
    return self;
}

- (Byte*)allocAndGetPixels:(UIImage*)ipImage {
    if (!ipImage) return nil;
    
    CGSize lSize = ipImage.size;
    
    CGColorSpaceRef lColorSpace = CGColorSpaceCreateDeviceRGB();
    if (!lColorSpace) return nil;
    
    int lBytesPerRow = lSize.width * 4;
    int lBytes = lBytesPerRow * lSize.height;
    
    void* lpBitmapData = malloc(lBytes);
    if (!lpBitmapData) {
        CGColorSpaceRelease(lColorSpace);
        return nil;
    }
    
    CGContextRef lContext = CGBitmapContextCreate(lpBitmapData, lSize.width, lSize.height, 8, lBytesPerRow, lColorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(lColorSpace);
    
    if (!lColorSpace) {
        free(lpBitmapData);
        return nil;
    }
    
    CGRect lRect = CGRectMake(0, 0, lSize.width, lSize.height);
    CGContextDrawImage(lContext, lRect, ipImage.CGImage);
    
    Byte* lBitsData = (Byte*)CGBitmapContextGetData(lContext);
    CGContextRelease(lContext);
    
    return lBitsData;
}

- (Pixel)getPixelColor:(int)x y:(int)y {
    int lIndex = (mImgSize.width * y + x) * 4;
    Byte* ipPixelData = mpPixels + lIndex;
    return Pixel(*ipPixelData, *(ipPixelData + 1), *(ipPixelData + 2), *(ipPixelData + 3));
}

+ (UIImage*)resizeImage:(UIImage*)iImage newRect:(CGRect)iNewRect {
	// Creates a bitmap-based graphics context and makes it the current context.
	UIGraphicsBeginImageContext(iNewRect.size);
	[iImage drawInRect:iNewRect];
	UIImage* lpImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return lpImage;
}

+ (UIImage*)createGrayScaleImageFromImage:(UIImage*)image {
    // !!! the caller is responsible for releasing the newly created UIImage instance !!!
    
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    
    // accoridng to the requirement from PM, we should set the transparency to be 50%
    CGContextSetAlpha(context, 0.5f); 
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object  
    UIImage* newImage = [[UIImage alloc] initWithCGImage:imageRef];
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    // Return the new grayscale image
    return newImage;
}

- (void)dealloc {
    free(mpPixels);
    [super dealloc];
}

@end
