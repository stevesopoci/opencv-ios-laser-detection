//
//  ViewController.m
//  OpenCViOSLaserDetection
//
//  Created by Steve Sopoci on 12/8/20.
//

#import "ViewController.h"

// Allow mixing of C++ code.
#include <stdlib.h>
using namespace std;
using namespace cv;

@interface ViewController () {
    
    IBOutlet UIImageView *cameraView;
    
    // Use OpenCV wrapper class to get camera access through AVFoundation.
    CvVideoCamera *videoCamera;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Initialize camera parameters.
    videoCamera = [[CvVideoCamera alloc] initWithParentView:cameraView];
    videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1280x720;
    videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    videoCamera.defaultFPS = 100;
    videoCamera.delegate = self;

    self->videoCamera.rotateVideo = YES;

    [videoCamera start];
}

- (void)processImage:(cv::Mat &)image;{

    // Convert frame from camera to HSV.
    Mat hsvImage;
    cvtColor(image, hsvImage, COLOR_BGR2HSV);

    // Threshold the HSV image and keep only the red pixels.
    Mat lowerRedHueRange;
    Mat upperRedHueRange;
    inRange(hsvImage, Scalar(0, 100, 100), Scalar(0, 255, 255), lowerRedHueRange);
    inRange(hsvImage, Scalar(150, 100, 100), Scalar(180, 255, 255), upperRedHueRange);

    // Combine the two threshold images.
    Mat redHueImage;
    addWeighted(lowerRedHueRange, 1.0, upperRedHueRange, 1.0, 0.0, redHueImage);

    // Smooth threshold image by reducing the noise.
    GaussianBlur(redHueImage, redHueImage, cv::Size(9, 9), 2, 2);
    dilate(redHueImage, redHueImage, 0);
    erode(redHueImage, redHueImage, 0);

    // Detect circles in the combined threshold image.
    vector<Vec3f> circles;
    HoughCircles(redHueImage, circles, CV_HOUGH_GRADIENT, 1, redHueImage.rows/8, 100, 20, 0, 0);

    // Loop over all detected circles and outline them on the original image.
    for(size_t current_circle = 0; current_circle < circles.size(); ++current_circle) {

        cv::Point center(round(circles[current_circle][0]), round(circles[current_circle][1]));

        int radius = round(circles[current_circle][2]);

        circle(image, center, radius, cv::Scalar(255, 0, 100), 5);

        cout<< "SS: [" << center.x << " , " << center.y << "] ";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
