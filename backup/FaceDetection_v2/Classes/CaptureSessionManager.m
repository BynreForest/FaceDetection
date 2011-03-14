/*
    File: CaptureSessionManager.m
Abstract: Configuration and control of video capture.
 Version: 1.0

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
Inc. ("Apple") in consideration of your agreement to the following
terms, and your use, installation, modification or redistribution of
this Apple software constitutes acceptance of these terms.  If you do
not agree with these terms, please do not use, install, modify or
redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may
be used to endorse or promote products derived from the Apple Software
without specific prior written permission from Apple.  Except as
expressly stated in this notice, no other rights or licenses, express or
implied, are granted by Apple herein, including but not limited to any
patent rights that may be infringed by your derivative works or by other
works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2010 Apple Inc. All Rights Reserved.

*/

#import "CaptureSessionManager.h"




@implementation CaptureSessionManager

@synthesize captureSession;
@synthesize previewLayer;
@synthesize recognizedRect;


// Perform face detection on the input image, using the given Haar Cascade.
// Returns a rectangle for the detected region in the given image.
/*- (CvRect *)detectFaceInImage:(IplImage *)inputImg haarCasc:(CvHaarClassifierCascade *) cascade
{
	// Smallest face size.
	CvSize minFeatureSize = cvSize(20, 20);
	// Only search for 1 face.
	int flags = CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_DO_ROUGH_SEARCH;
	// How detailed should the search be.
	float search_scale_factor = 1.1f;
	IplImage *detectImg;
	IplImage *greyImg = 0;
	CvMemStorage* storage;
	CvRect rc;
	double t;
	CvSeq* rects;
	CvSize size;
	int i, ms, nFaces;
	
	storage = cvCreateMemStorage(0);
	cvClearMemStorage( storage );
	
	
	// If the image is color, use a greyscale copy of the image.
	detectImg = (IplImage*)inputImg;
	if (inputImg->nChannels > 1) {
		size = cvSize(inputImg->width, inputImg->height);
		greyImg = cvCreateImage(size, IPL_DEPTH_8U, 1 );
		cvCvtColor( inputImg, greyImg, CV_BGR2GRAY );
		detectImg = greyImg;	// Use the greyscale image.
	}
	
	// Detect all the faces in the greyscale image.
	t = (double)cvGetTickCount();
	rects = cvHaarDetectObjects( detectImg, cascade, storage,
								search_scale_factor, 3, flags, minFeatureSize);
	t = (double)cvGetTickCount() - t;
	ms = cvRound( t / ((double)cvGetTickFrequency() * 1000.0) );
	nFaces = rects->total;
	printf("Face Detection took %d ms and found %d objects\n", ms, nFaces);
	
	// Get the first detected face (the biggest).
	if (nFaces > 0)
		rc = *(CvRect*)cvGetSeqElem( rects, 0 );
	else
		rc = cvRect(-1,-1,-1,-1);	// Couldn't find the face.
	
	if (greyImg)
		cvReleaseImage( &greyImg );
	cvReleaseMemStorage( &storage );
	//cvReleaseHaarClassifierCascade( &cascade );
	
	return rc;	// Return the biggest face found, or (-1,-1,-1,-1).
}
*/



#pragma mark SampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
	/**
	 CMSampleBuffer is a Core Foundation object containing zero or more compressed 
	 (or uncompressed) samples of a particular media type (audio, video, muxed, and 
	 so on).
	 **/
	
	// Create a UIImage from the sample buffer data
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
	[self opencvFaceDetect:image];
	NSLog(@"captureOutput");
	//IplImage *iplImage = [self CreateIplImageFromUIImage:image];
	
	//dispatch_queue_t my_queue = dispatch_queue_create("com.example.subsystem.taskABC", NULL);
	//[self opencvFaceDetect:image queue:my_queue];

	
	
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer 
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0); 
	
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer); 
	
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer); 
    size_t height = CVPixelBufferGetHeight(imageBuffer); 
	
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
	
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, 
												 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst); 
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context); 
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
	
    // Free up the context and color space
    CGContextRelease(context); 
    CGColorSpaceRelease(colorSpace);
	
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
	
    // Release the Quartz image
    CGImageRelease(quartzImage);
	
    return (image);
}

#pragma mark IplImage conversion
// NOTE you SHOULD cvReleaseImage() for the return value when end of the code.
- (IplImage *)CreateIplImageFromUIImage:(UIImage *)image {
	// Getting CGImage from UIImage
	CGImageRef imageRef = image.CGImage;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	// Creating temporal IplImage for drawing
	IplImage *iplimage = cvCreateImage(
									   cvSize(image.size.width,image.size.height), IPL_DEPTH_8U, 4
									   );
	// Creating CGContext for temporal IplImage
	CGContextRef contextRef = CGBitmapContextCreate(
													iplimage->imageData, iplimage->width, iplimage->height,
													iplimage->depth, iplimage->widthStep,
													colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault
													);
	// Drawing CGImage to CGContext
	CGContextDrawImage(
					   contextRef,
					   CGRectMake(0, 0, image.size.width, image.size.height),
					   imageRef
					   );
	CGContextRelease(contextRef);
	CGColorSpaceRelease(colorSpace);
	
	// Creating result IplImage
	IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
	cvCvtColor(iplimage, ret, CV_RGBA2BGR);
	cvReleaseImage(&iplimage);
	
	return ret;
}

#pragma mark Face Detection OpenCV
- (void) opencvFaceDetect:(UIImage *)testImage  {
		
				
	
		// Load XML
		NSString *path = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_default" ofType:@"xml"];
		CvHaarClassifierCascade* cascade = (CvHaarClassifierCascade*)cvLoad([path cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, NULL);
		CvMemStorage* storage = cvCreateMemStorage(0);
	
		cvSetErrMode(CV_ErrModeParent);
		IplImage *image = [self CreateIplImageFromUIImage:testImage];
	
		
		// Scaling down
		IplImage *small_image = cvCreateImage(cvSize(image->width/2,image->height/2), IPL_DEPTH_8U, 3);
		cvPyrDown(image, small_image, CV_GAUSSIAN_5x5);
		int scale = 2;
	
		
	
		// Detect faces and draw rectangle on them
		CvSeq* faces = cvHaarDetectObjects(small_image, cascade, storage, 1.2f, 2, CV_HAAR_DO_CANNY_PRUNING, cvSize(20, 20));
		cvReleaseImage(&small_image);
	
	NSLog(@"testImage.size.width: %i", testImage.size.width);
	NSLog(@"testImage.size.height: %i", testImage.size.height);
	
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextRef contextRef = CGBitmapContextCreate(NULL, testImage.size.width, testImage.size.height,
													8, testImage.size.width * 4,
													colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);	
	
	// Draw results on the iamge
	for(int i = 0; i < faces->total; i++) {
				
		// Calc the rect of faces
		CvRect cvrect = *(CvRect*)cvGetSeqElem(faces, i);
		CGRect face_rect = CGContextConvertRectToDeviceSpace(contextRef, CGRectMake(cvrect.x * scale, cvrect.y * scale, cvrect.width * scale, cvrect.height * scale));
		
		NSLog(@"faces: %d", face_rect);
		
	}	
		
	/*
		// Create canvas to show the results
		CGImageRef imageRef = imageView.image.CGImage;
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextRef contextRef = CGBitmapContextCreate(NULL, imageView.image.size.width, imageView.image.size.height,
														8, imageView.image.size.width * 4,
														colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
		CGContextDrawImage(contextRef, CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height), imageRef);
		
		CGContextSetLineWidth(contextRef, 4);
		CGContextSetRGBStrokeColor(contextRef, 0.0, 0.0, 1.0, 0.5);
		
		// Draw results on the iamge
		for(int i = 0; i < faces->total; i++) {
			NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
			
			// Calc the rect of faces
			CvRect cvrect = *(CvRect*)cvGetSeqElem(faces, i);
			CGRect face_rect = CGContextConvertRectToDeviceSpace(contextRef, CGRectMake(cvrect.x * scale, cvrect.y * scale, cvrect.width * scale, cvrect.height * scale));
			
			if(overlayImage) {
				CGContextDrawImage(contextRef, face_rect, overlayImage.CGImage);
			} else {
				CGContextStrokeRect(contextRef, face_rect);
			}
			
			[pool release];
		}
		
		imageView.image = [UIImage imageWithCGImage:CGBitmapContextCreateImage(contextRef)];
		CGContextRelease(contextRef);
		CGColorSpaceRelease(colorSpace);
		
		cvReleaseMemStorage(&storage);
		cvReleaseHaarClassifierCascade(&cascade);
		
		[self hideProgressIndicator];
	}
	 */
}


#pragma mark Capture Session Configuration

- (void) addVideoPreviewLayer {
	/**
	 AVCaptureVideoPreviewLayer is a subclass of CALayer that allows you use 
	 to display video as it is being captured by an input device.
	 **/
	self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
	self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
}


- (void) addVideoInput {
	
	/**
	 video device will be the back facing camera
	 **/
	AVCaptureDevice *videoDevice = [self frontFacingCameraIfAvailable];	
	
	if ( videoDevice ) {

		NSError *error;
		/**
		 AVCaptureDeviceInput is a concrete sub-class of AVCaptureInput you use to 
		 capture data from an AVCaptureDevice object.
		 **/
		AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
	
		if ( !error ) {
			/**
			 Returns a Boolean value that indicates whether a given input can be 
			 added to the session.
			 - (BOOL)canAddInput:(AVCaptureInput *)input
			 **/
			/**
			 Adds a given input to the session.
			 - (void)addInput:(AVCaptureInput *)input
			 **/
			
			if ([self.captureSession canAddInput:videoIn])
				[self.captureSession addInput:videoIn];
			else
				NSLog(@"Couldn't add video input");		
		}
		else
			NSLog(@"Couldn't create video input");
	}
	else
		NSLog(@"Couldn't create video capture device");
}

- (AVCaptureDevice *)frontFacingCameraIfAvailable
{
    //  look at all the video devices and get the first one that's on the front
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionFront)
        {
            captureDevice = device;
            break;
        }
    }
	
    //  couldn't find one on the front, so just get the default video device.
    if ( ! captureDevice)
    {
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
	
    return captureDevice;
}


- (void) addVideoDataOutput {
	/**
	 AVCaptureVideoDataOutput is a concrete sub-class of AVCaptureOutput you use, 
	 via its delegate, to process uncompressed frames from the video being captured, 
	 or to access compressed frames.
	 
	 An instance of AVCaptureVideoDataOutput produces video frames you can process 
	 using other media APIs. It passes the frames to its delegate using the 
	 captureOutput:didOutputSampleBuffer:fromConnection: method. To get the frames, 
	 you implement captureOutput:didOutputSampleBuffer:fromConnection: in the delegate 
	 object.
	 **/
	AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
	//  we don't need a high frame rate. this limits the capture to 5 frames per second.
    videoOut.minFrameDuration = CMTimeMake(1, 30);
	/**
	 indicates whether video frames are dropped if they arrive late.
	 **/
	[videoOut setAlwaysDiscardsLateVideoFrames:YES];
	[videoOut setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]]; // BGRA is necessary for manual preview
	dispatch_queue_t my_queue = dispatch_queue_create("com.example.subsystem.taskXYZ", NULL);
	/**
	 Associate a GCD queue with your delegate
	 gives you control over priority/thread
	 helps you manage the performance of video frames
	 ~must be a serial ordered queue to ensure properly oredered buffer callbacks
	 **/
	[videoOut setSampleBufferDelegate:self queue:my_queue];
//	[videoOut setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
	
	if ([self.captureSession canAddOutput:videoOut])
		[self.captureSession addOutput:videoOut];
	else
		NSLog(@"Couldn't add video output");
	[videoOut release];
}


- (id) init {
	
	if (self = [super init]) {
		
		/**
		 AVCaptureSession object to coordinate the flow of data 
		 from AV input devices to outputs
		 **/
		self.captureSession = [[AVCaptureSession alloc] init];
		self.captureSession.sessionPreset = AVCaptureSessionPreset640x480;
		self.recognizedRect = CGRectMake(0.0, 0.0, 100.0, 100.0);
	}
	
	return self;
}


- (void)dealloc {

	[self.captureSession stopRunning];

	[self.previewLayer release];
	[self.captureSession release];

	[super dealloc];
}

@end
