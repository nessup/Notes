//
//  AROverlayExample
//
//  Created by Jason Job on 11-04-11.
//  Copyright 2011 BitCatapult. All rights reserved.
//
//  This class is adapted from https://github.com/jj0b/AROverlayExample
//
//
//  Modified by Abdallah Elguindy on 8/17/12.
//
//  This is the main UIView displaying avatars, information
//  and other UI elements, for example, distance lines.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

#import "AROverlayViewController.h"

#import "ARCaptureVideoPreviewView.h"
#import "ARDrawingManager.h"
#import "UrlNavigator.h"
#import "AvatarView.h"

#import "CircleServiceCache.h"
#import "SessionManager.h"
#import "ProfileContext.h"
#import "Profile.h"

#import "ARContact+Distance.h"
#import "UIButton+StandardButtons.h"
#import "UIDevice+IdentifierAddition.h"

#define CC_RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) / (float)M_PI * 180.0f)

@interface AROverlayViewController ()

@property (nonatomic, retain) ARCaptureVideoPreviewView *view;
@property (nonatomic, weak) ThriftOperation *thriftOp;
@property (nonatomic, getter = hasLoaded) BOOL loaded;
@property (nonatomic) BOOL rotationListenerEnabled;

@end

@implementation AROverlayViewController {
    CADisplayLink *_displayLink;
    
    CMMotionManager *motionManager_;
    CLLocationManager *locationManager_;
    
    // Keep track of previous location to
    // determine if the change of position is
    // enough to force data update.
    CLLocation *prevLocation_;
    
    // Keep a local cached copy of the data.
    NSMutableArray *storedData_;
    
    // UIView to render the main view.
    ARDrawingManager *drawing_;
    
    NSTimer             *updateTimer;
    
    float               oldHeading;
    float               updatedHeading;
    float               newYaw;
    float               oldYaw;
    float               offsetG;
    float               updateCompass;
    float               newCompassTarget;
    float               currentYaw;
    float               currentHeading;
    float               compassDiff;
    float               northOffest;
    
    UIButton *_exitButton;
    UIView *_loadingView;
    NSTimer *_countdownTimer;
    NSUInteger _countdownCount;
    CALayer *_overlayLayer, *_indicatorLayer;
    BOOL _startAROnRotation;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View lifecycle

- (void)loadView
{
    self.view = [[ARCaptureVideoPreviewView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.opaque = YES;
    self.view.backgroundColor = [UIColor blackColor];
    self.wantsFullScreenLayout = YES;
}

- (void)startAR
{
    CaptureSessionManager *manager = [[CaptureSessionManager alloc] init];
    manager.previewLayer = self.view.layer;
	CGRect layerRect = manager.previewLayer.bounds;
    if( layerRect.size.width < layerRect.size.height ) {
        CGFloat temp = layerRect.size.width;
        layerRect.size.width = layerRect.size.height;
        layerRect.size.height = temp;
    }
    self.view.bounds = layerRect;
    manager.previewLayer.position = CGPointMake(CGRectGetMidX(layerRect),
                                                CGRectGetMidY(layerRect));
    
    [manager addVideoInput];
    self.captureManager = manager;
    
    motionManager_ = [[CMMotionManager alloc] init];
    motionManager_.deviceMotionUpdateInterval = (1/60.0f);
    //
    locationManager_ = [[CLLocationManager alloc] init];
    locationManager_.distanceFilter = kCLLocationAccuracyBest;
    locationManager_.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager_.headingOrientation = CLDeviceOrientationLandscapeLeft;
    locationManager_.delegate = self;
    //
    drawing_ = [[ARDrawingManager alloc] initWithView:self.view];
    drawing_.delegate = self;
    
    // Overlay layer
    {
        UIImage *image = (UsingiPhone5Display() ? [UIImage imageNamed:@"ar_simple_layer-568h"] : [UIImage imageNamed:@"ar_simple_layer"]);
        CALayer *layer = [CALayer layer];
        layer.frame = (CGRect) { CGPointZero, image.size };
        layer.contents = (id)image.CGImage;
        layer.hidden = YES;
        [self.view.layer addSublayer:layer];
        _overlayLayer = layer;
    }
    
    [self createLoadingViewWithLayerRect:layerRect];
    
    _exitButton = [UIButton exitButton];
    _exitButton.center = CGPointMake(layerRect.size.width - StandardButtonLeftPositionCenter, _exitButton.center.y);
    [_exitButton setImage:[UIImage imageNamed:@"ar_button_close"] forState:UIControlStateNormal];
    [_exitButton setImage:nil forState:UIControlStateHighlighted];
    [_exitButton addTarget:self action:@selector(exitButtonDown) forControlEvents:UIControlEventTouchDown];
    [_exitButton addTarget:self action:@selector(exitButtonTouchUp) forControlEvents:UIControlEventTouchUpInside];
    _exitButton.layer.zPosition = 2000.f;
    [self.view addSubview:_exitButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phoneDidRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewDidLoad
{
//    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
    if( UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ) {
        _startAROnRotation = YES;
    }
    else {
        [self startAR];
    }
}

- (void)setRotationListenerEnabled:(BOOL)rotationListenerEnabled
{
    _rotationListenerEnabled = rotationListenerEnabled;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [GAIHelpers sendViewKey:@"GAI_SCREEN_AR"];
    
    [self.captureManager.captureSession startRunning];
    
    if( !self.loaded )
        [self refreshData: nil];
    
    self.rotationListenerEnabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.rotationListenerEnabled = NO;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewDidUnload {
    [motionManager_ stopDeviceMotionUpdates];
    [motionManager_ stopGyroUpdates];
    [locationManager_ stopUpdatingLocation];
}

- (BOOL)shouldAutorotate { return NO; }
- (NSUInteger)supportedInterfaceOrientations { return UIInterfaceOrientationMaskLandscape; }
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation); }

- (void)phoneDidRotate:(NSNotification *)note
{
    if( !self.rotationListenerEnabled )
        return;
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if( orientation == UIDeviceOrientationPortrait  ) {
        [self dismiss];
        return;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    UIInterfaceOrientation currentOrientation = self.interfaceOrientation;
    
    if( _startAROnRotation && UIInterfaceOrientationIsLandscape(currentOrientation) ) {
        [self startAR];
        _startAROnRotation = NO;
    }
    
    if( currentOrientation == UIDeviceOrientationLandscapeLeft ) {
        locationManager_.headingOrientation = CLDeviceOrientationLandscapeLeft;
    }
    else {
        locationManager_.headingOrientation = CLDeviceOrientationLandscapeRight;
    }
    [self updater:nil];
    
    self.captureManager.orientation = (currentOrientation == UIInterfaceOrientationLandscapeLeft ? AVCaptureVideoOrientationLandscapeLeft : AVCaptureVideoOrientationLandscapeRight);
}

#pragma mark - View creation

- (void)createLoadingViewWithLayerRect:(CGRect)layerRect
{
    // Loading view
    {
        UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
        view.backgroundColor = [UIColor blackColor];
        view.layer.zPosition = 1500;
        [self.view addSubview:view];
        _loadingView = view;
    }
    
    // Add progress track
    {
        CALayer *trackLayer = [CALayer layer];
        trackLayer.frame = (CGRect) { CGPointZero, 204.f, 17.f };
        trackLayer.position = CGPointMake(CGRectGetMidX(layerRect), ceilf( CGRectGetMidY(layerRect) ));
        trackLayer.borderWidth = 1.f;
        trackLayer.borderColor = [UIColor whiteColor].CGColor;
        trackLayer.cornerRadius = 9.f;
        [_loadingView.layer addSublayer:trackLayer];
        
        // Progress indicator layer
        {
            CALayer *layer = [CALayer layer];
            layer.frame = (CGRect) { 2.f, 2.f, 14.f, 13.f };
            layer.cornerRadius = 7.f;
            layer.backgroundColor = [UIColor whiteColor].CGColor;
            [trackLayer addSublayer:layer];
            _indicatorLayer = layer;
        }
    }
    
    // Animate progress indicator
    [NSTimer scheduledTimerWithTimeInterval:0.1f repeats:NO usingBlock:^(NSTimer *timer) {
        [CATransaction begin];
        [CATransaction setAnimationDuration:5.f];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        _indicatorLayer.frame = (CGRect) { _indicatorLayer.frame.origin, 180.f, _indicatorLayer.frame.size.height };
        [CATransaction commit];
    }];
    
    {
        UIFont *font = FONT_Aller(16.f);
        UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){ 0.f, CGRectGetMidY(layerRect) + 40.f, layerRect.size.width, font.lineHeight}];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor blackColor];
        label.font = font;
        label.text = [OverrideParams getValue:@"SOCIAL_RADAR_LOADING_TEXT"];
        [_loadingView addSubview:label];
        
        // Pulsing animation for text
        {
            CABasicAnimation *a = [CABasicAnimation animationWithKeyPath:@"opacity"];
            a.fromValue = [NSNumber numberWithFloat:1.0];
            a.toValue = [NSNumber numberWithFloat:0.25];
            a.duration = 1.0;
            a.autoreverses = YES;
            a.repeatCount = CGFLOAT_MAX;
            a.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [label.layer addAnimation:a forKey:@"opacity"];
        }
    }
}

- (void)setLoaded:(BOOL)loaded
{
    _loaded = loaded;
    
    if( _loaded )
        [self dismissLoading];
}

#pragma mark - Location handling

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    // Update variable updateHeading to be used in updater method
    updatedHeading = newHeading.magneticHeading;
}

- (void)updateMotionData:(id)sender
{
    if( !self.loaded ) return;
    
//    static CFAbsoluteTime time;
//    NSLog(@"time=%f", CFAbsoluteTimeGetCurrent() - time);
//    time = CFAbsoluteTimeGetCurrent();

    CMAttitude *currentAttitude = motionManager_.deviceMotion.attitude;
    static float yawValue = 0; // Use the yaw value
    
    yawValue = currentAttitude.yaw;
    
    // Yaw values are in radians (-180 - 180), here we convert to degrees
    static float yawDegrees = 0;
    yawDegrees = CC_RADIANS_TO_DEGREES(yawValue);
    currentYaw = yawDegrees;
    
    // We add new compass value together with new yaw value
    yawDegrees = newCompassTarget + (yawDegrees - offsetG);
    
    // Degrees should always be positive
    if(yawDegrees < 0) {
        yawDegrees = yawDegrees + 360;
    }
    
    // If there is a new compass value the gyro graphic animates to this position
    
    if(updateCompass) {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25f];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [drawing_ updateLines: motionManager_.deviceMotion.attitude.roll / M_PI];
        // TODO: consider disabling animation when the device is not turning.
        [drawing_ updateAvatars:fmod(-yawDegrees, 360)];
        updateCompass = 0;
        [UIView commitAnimations];
        
    } else {
        [drawing_ updateLines: motionManager_.deviceMotion.attitude.roll / M_PI];
        // TODO: consider disabling animation when the device is not turning.
        [drawing_ updateAvatars:fmod(-yawDegrees, 360)];
    }
}

- (void)dismissLoading
{
    if( _loadingView.superview ) {
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.3f];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        
        UIView *loadingView = _loadingView;
        CALayer *overlayLayer = _overlayLayer;
        [CATransaction setCompletionBlock:^{
            loadingView.layer.shouldRasterize = YES;
            loadingView.layer.rasterizationScale = [UIScreen mainScreen].scale;
            
            [UIView animateWithDuration:1.f animations:^{
                loadingView.alpha = 0.f;
            } completion:^(BOOL finished) {
                
                [loadingView removeFromSuperview];
                
                CABasicAnimation *a1 = [CABasicAnimation animationWithKeyPath:@"opacity"];
                a1.fromValue = [NSNumber numberWithFloat:0.0];
                a1.toValue = [NSNumber numberWithFloat:1.0];
                
                CABasicAnimation *a2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                a2.fromValue = [NSNumber numberWithFloat:1.25];
                a2.toValue = [NSNumber numberWithFloat:1.0];
                
                CAAnimationGroup *g = [CAAnimationGroup animation];
                g.animations = [NSArray arrayWithObjects:a1, a2, nil];
                g.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                g.duration = 2.f;
                
                overlayLayer.hidden = NO;
                [overlayLayer addAnimation:g forKey:@"fade"];
            }];
        }];
        _indicatorLayer.frame = (CGRect) { _indicatorLayer.frame.origin, 200.f, _indicatorLayer.frame.size.height };
        [CATransaction commit];
    }
}

#pragma mark - Data handling

- (void)refreshData: (NSTimer *) timer {
    double lat = locationManager_.location.coordinate.latitude;
    double lon = locationManager_.location.coordinate.longitude;
    
    __weak AROverlayViewController *weakSelf = self;
    weakSelf.thriftOp = [[CircleServiceCache sharedService]
                         getARContacts:[SessionManager sharedSession]
                         latitude:lat longitude:lon
                         onSuccess:^(NSMutableArray *arContacts) {
                             [weakSelf handleData:arContacts];
                             weakSelf.thriftOp = nil;
                         }
                         onError:^(NSError *error) {
                             [GAIHelpers sendAPIError:error];
                             ShowConnectionFailure(error, NO, [AROverlayViewController class], _cmd);
                             weakSelf.thriftOp = nil;
                         }];
    [weakSelf.thriftOp execute];
}

- (float)smallestDifferenceBetweenAngle:(float)a andAngle:(float)b
{
    float diff = fmodf(a - b, 360.0f);
    
    if( diff > 180.f )
        diff = 360.0 - diff;
    
    return diff;
}

- (void)handleData:(NSMutableArray *)data {
    storedData_ = data;
    
    // Sometimes the server likes to send no contacts. When this happens, bail out and avoid a crash.
    if( !storedData_.count ) {
        ShowError([NSError errorWithDomain:@"Server did not send a populated array of contacts." code:-1 userInfo:nil]);
        [self dismiss];
        return;
    }

    self.loaded = YES;
    
    // The code below separates ARContacts into
    // 3 circles (<2km, <10km and the rest).
    
    NSMutableArray *circleARContacts[3];
    
    for (int i = 0; i < 3; ++i)
        circleARContacts[i] = [[NSMutableArray alloc] init];
    for (int i = 0; i < [storedData_ count]; ++i) {
        ARContact *contact = [storedData_ objectAtIndex:i];
        [contact calculateData:locationManager_.location];
        if (contact.distance < 2) {
            [circleARContacts[2] addObject:contact];
        } else if (contact.distance < 10) {
            [circleARContacts[1] addObject:contact];
        } else {
            [circleARContacts[0] addObject:contact];
        }
    }
    
    int randomHeadingRange = [OverrideParams getIntegerValue:@"AR_RANDOM_HEADING_RANGE"];
    double randomHeadingMin = [OverrideParams getIntegerValue:@"AR_RANDOM_HEADING_MIN"];
    
    // Ensure that contacts don't overlap
    for( int i = 0; i < 3; i++ ) {
        NSArray *sortedArray;
        sortedArray = [circleARContacts[i] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            double first = [(ARContact *)a direction];
            double second = [(ARContact *)b direction];
            
            return first > second;
        }];
        for( int j = 1; j <= sortedArray.count; j++ ) {
                ARContact *contactA = [sortedArray objectAtIndex:j % sortedArray.count];
                ARContact *contactB = [sortedArray objectAtIndex:j - 1];
            float
            a = [(ARContact *)[sortedArray objectAtIndex:j % sortedArray.count] direction],
            b = [(ARContact *)[sortedArray objectAtIndex:j - 1] direction];
            
            float randomHeadingOffset = (arc4random() % randomHeadingRange) + randomHeadingMin;
            
            if( [self smallestDifferenceBetweenAngle:a andAngle:b]  <= 7.f ) {
                switch (i) {
                    case 0:
                        contactA.direction = contactB.direction + 7.f;
                        break;
                        
                    case 1:
                        contactA.direction = contactB.direction + 7.f;
                        break;
                        
                    case 2:
                        contactA.direction = contactB.direction + 10.f;
                        break;
                        
                    default:
                        break;
                }
                contactA.direction += randomHeadingOffset;
            }
        }
//        for( int j = 1; j <= sortedArray.count; j++ ) {
//            float
//            a = [(ARContact *)[sortedArray objectAtIndex:j % sortedArray.count] direction],
//            b = [(ARContact *)[sortedArray objectAtIndex:j - 1] direction];
//            
//            if( [self smallestDifferenceBetweenAngle:a andAngle:b]  <= 10.f ) {
//                ARContact *contactA = [sortedArray objectAtIndex:j % sortedArray.count];
//                ARContact *contactB = [sortedArray objectAtIndex:j - 1];
//                break;
//            }
//        }
        circleARContacts[i] = [NSMutableArray arrayWithArray:sortedArray];
    }
    
    // Render ARContacts on their circles.
    
    for (int i = 0; i < 3; ++i)
        [drawing_ setIcons:circleARContacts[i] circle:i];
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMotionData:)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [motionManager_ startDeviceMotionUpdates];
    [locationManager_ startUpdatingLocation];
    [locationManager_ startUpdatingHeading];
    
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updater:) userInfo:nil repeats:YES];
    
}

- (void)updater:(NSTimer *)timer
{
    // If the compass hasn't moved in a while we can calibrate the gyro
    if(updatedHeading == oldHeading) {
        // Populate newCompassTarget with new compass value and the offset we set in calibrate
        newCompassTarget = (0 - updatedHeading) + northOffest;
        //        compassFault.text = [NSString stringWithFormat:@"newCompassTarget: %f",newCompassTarget]; // Debug
        offsetG = currentYaw;
        updateCompass = 1;
    } else {
        updateCompass = 0;
    }
    
    oldHeading = updatedHeading;
}

#pragma mark - Actions

- (void)exitButtonDown
{
    _exitButton.alpha = 0.7f;
}

- (void)exitButtonTouchUp
{
    _exitButton.alpha = 1.f;
    
    [self dismiss];
}

- (void)dismiss
{
    [self dismissAnimated:YES];
}

- (void)dismissAnimated:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self.captureManager.captureSession stopRunning];
    self.captureManager = nil;
    
    [motionManager_ stopDeviceMotionUpdates];
    [locationManager_ stopUpdatingLocation];
    locationManager_.delegate = nil;
    
    [updateTimer invalidate];
    
    [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_displayLink invalidate];
    _displayLink = nil;

    [self.thriftOp cancel];
    self.thriftOp = nil;
    
    [[UrlNavigator sharedNavigator] goBackAnimated:animated];
}

- (void)avatarViewTapped:(AvatarView *)view contact:(ARContact *)contact
{
    [self dismissAnimated:NO];
    
    [GAIHelpers sendEventWithActionKey:@"GAI_EVENT_ACTION_AR_AVATAR"];
    
    dispatch_async(dispatch_get_current_queue(), ^{
        [[UrlNavigator sharedNavigator] openUrl:[UrlNavigator concat:NAVIGATOR_FullProfileList :contact.profileContext.sessionId] withCustomParams:contact.profileContext animated:YES];
    });
}

@end
