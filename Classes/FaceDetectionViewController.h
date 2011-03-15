//
//  FaceDetectionViewController.h
//  FaceDetection
//
//  Created by Brendan Gaynor on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaptureSessionManager.h"


@interface FaceDetectionViewController : UIViewController {
	CaptureSessionManager *captureManager;
	CALayer *overlayLayer;
	
	CALayer *imageLayer;

}

@property (retain) CaptureSessionManager *captureManager;
@property (nonatomic, retain) IBOutlet CALayer *overlayLayer;


@end

