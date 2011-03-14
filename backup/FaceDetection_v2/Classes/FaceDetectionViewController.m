//
//  FaceDetectionViewController.m
//  FaceDetection
//
//  Created by Brendan Gaynor on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FaceDetectionViewController.h"

@implementation FaceDetectionViewController

@synthesize captureManager;
@synthesize overlayLayer;


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	captureManager = [[CaptureSessionManager alloc] init];
	
	// Configure capture session
	[captureManager addVideoInput];
	[captureManager addVideoDataOutput];
	
	// Set up video preview layer
	[captureManager addVideoPreviewLayer];
	CGRect layerRect = self.view.layer.bounds;
	captureManager.previewLayer.bounds = layerRect;
	captureManager.previewLayer.position = CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect));
	[self.view.layer addSublayer:captureManager.previewLayer];
	
	[captureManager.captureSession startRunning];
	captureManager.captureSession = captureManager.captureSession;
	
	
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
