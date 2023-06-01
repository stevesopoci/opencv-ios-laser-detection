//
//  ViewController.h
//  OpenCViOSLaserDetection
//
//  Created by Steve Sopoci on 12/8/20.
//

#import <UIKit/UIKit.h>

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#import "opencv2/highgui/ios.h"
#endif

@interface ViewController : UIViewController<CvVideoCameraDelegate>

@end

