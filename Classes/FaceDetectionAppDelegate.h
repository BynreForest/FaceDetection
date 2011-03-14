//
//  FaceDetectionAppDelegate.h
//  FaceDetection
//
//  Created by Brendan Gaynor on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FaceDetectionViewController;

@interface FaceDetectionAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    FaceDetectionViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet FaceDetectionViewController *viewController;

@end

