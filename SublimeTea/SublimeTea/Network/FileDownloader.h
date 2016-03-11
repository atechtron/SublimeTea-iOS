//
//  FileDownloader.h
// 
//
//  Created by Arpit Mishra on 29/04/14.
//  Copyright (c) 2014 Parlore. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^completeBlock_t)(NSData *data,NSURL *imgURL, UIView *imgView);
typedef void (^errorBlock_t)(NSError *error);

@interface FileDownloader : NSObject
{
    completeBlock_t completeBlock_;
    errorBlock_t errorBlock_;
}
-(void)asynchronousFiledownload:(NSURLSessionDataTask *)imageDownloadTask
         serviceUrlMethodString:(NSURL *)_fileURL
                     urlSession:(NSURLSession *)session
                      imageView:(UIImageView *)imgView
        displayLoadingIndicator:(BOOL)isLoadingIndicatorRequired
                  completeBlock:(completeBlock_t)completeBlock
                     errorBlock:(errorBlock_t)errorBlock;

@end
