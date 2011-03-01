//
//  BMW_iOSViewController.h
//  BMW_iOS
//
//  Created by Rob Balian on 2/21/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CMMotionManager.h>
#include "CaptureSessionManager.h"

@interface BMW_iOSViewController : UIViewController {
	CaptureSessionManager *captureManager;
	float v[3];
}
-(void)signalStart;
-(void)signalStop;

@end

