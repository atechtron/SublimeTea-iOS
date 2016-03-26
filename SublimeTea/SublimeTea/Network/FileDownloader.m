//
//  FileDownloader.m
//
//
//  Created by Arpit Mishra on 25/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "FileDownloader.h"
#import "STUtility.h"
#import "STMacros.h"

@implementation FileDownloader

-(void)asynchronousFiledownload:(NSURLSessionDataTask *)imageDownloadTask
         serviceUrlMethodString:(NSURL *)_fileURL
                     urlSession:(NSURLSession *)session
                      imageView:(UIImageView *)imgView
        displayLoadingIndicator:(BOOL)isLoadingIndicatorRequired
                  completeBlock:(completeBlock_t)completeBlock
                     errorBlock:(errorBlock_t)errorBlock


{
    @try {
        if (imageDownloadTask) {
            [imageDownloadTask cancel];
        }
        UIActivityIndicatorView *activityIndicator;
        if (isLoadingIndicatorRequired) {
            //Create and add the Activity Indicator to splashView
            activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityIndicator.tag = 1919;
            activityIndicator.alpha = 1.0;
            activityIndicator.center = CGPointMake(imgView.frame.size.width/2, imgView.frame.size.height/2);
            activityIndicator.hidesWhenStopped = NO;
            [imgView addSubview:activityIndicator];
            [activityIndicator startAnimating];
            [imgView bringSubviewToFront:activityIndicator];
        }
        
//        [AppDelegate didStartNetworking];
        NSURL *imageURL = _fileURL;
        if (imageURL) {
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: imageURL
                                                                   cachePolicy: NSURLRequestUseProtocolCachePolicy
                                                               timeoutInterval: 60.0];
            request.cachePolicy = NSURLRequestReturnCacheDataElseLoad; // this will make sure the request always returns the cached image
           
            [request setHTTPMethod: @"GET"];
            
            completeBlock_ = [completeBlock copy];
            errorBlock_ = [errorBlock copy];
            
            
            imageDownloadTask = [session dataTaskWithRequest:request
                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//                                          [AppDelegate didStopNetworking];
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              if (isLoadingIndicatorRequired) {
                                                  [activityIndicator stopAnimating];
                                                  
                                                  UIView *activityIndicator = [imgView viewWithTag:1919];
                                                  if(activityIndicator.superview) {
                                                      [activityIndicator removeFromSuperview];
                                                  }
                                              }
                                          });
                                          
                                          if (error) {
                                              dbLog(@"File Download ERROR: %@", error);
                                              errorBlock_(error);
                                              errorBlock_ = nil;
                                          } else {
                                              
                                              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                              if (httpResponse.statusCode == 200) {
                                                  completeBlock_(data,_fileURL,imgView);
                                                  completeBlock_ = nil;
                                              } else {
                                                  dbLog(@"Couldn't Download Files at URL: %@", _fileURL);
                                                  dbLog(@"HTTP %ld", (long)httpResponse.statusCode);
                                                  errorBlock_(error);
                                                  errorBlock_ = nil;
                                              }
                                          }
                                      }];
            [imageDownloadTask resume];
        }
    }
    @catch (NSException *exception) {
        dbLog(@"SublimeTea-FileDownloader-asynchronousFiledownload:- %@",exception);
//        [AppDelegate didStopNetworking];
    }
}

@end
