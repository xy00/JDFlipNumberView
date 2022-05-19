//
//  FVEDetailViewController.m
//  FlipNumberViewExample
//
//  Created by Markus Emrich on 07.08.12.
//  Copyright (c) 2012 markusemrich. All rights reserved.
//

#import <WebKit/WebKit.h>

#import "JDFlipNumberView.h"
#import "JDFlipClockView.h"
#import "JDFlipImageView.h"
#import "JDDateCountdownFlipView.h"
#import "UIView+JDFlipImageView.h"

#import "FVEDetailViewController.h"

@interface FVEDetailViewController () <JDFlipNumberViewDelegate>
@property (nonatomic) UIView *flipView;
@property (nonatomic) UIView *colorView;
@property (nonatomic) NSArray *webviews;
@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) UILabel *infoLabel;
@property (nonatomic) NSString *imageBundleName;
@property (nonatomic) UISlider *distanceSlider;
@property (nonatomic) NSInteger imageIndex;
@end

@implementation FVEDetailViewController

- (id)initWithIndexPath:(NSIndexPath*)indexPath
{
    self = [super init];
    if (self) {
        _indexPath = indexPath;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.systemGray6Color;

    // add info label
    CGRect frame = CGRectInset(self.view.bounds, 10, 10);
    frame.size.height = 20;
    frame.origin.y = self.view.frame.size.height - frame.size.height - 40;
    self.infoLabel = [[UILabel alloc] initWithFrame: frame];
    self.infoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.infoLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    self.infoLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    self.infoLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    self.infoLabel.shadowOffset = CGSizeMake(0, 1);
    self.infoLabel.backgroundColor = [UIColor clearColor];
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    self.infoLabel.text = @"Tap anywhere to change the value!";
    [self.view addSubview: self.infoLabel];
    
    // setup flip number view style
    self.imageBundleName = self.useModernAssets ? @"JDFlipNumberViewModernAssets" : nil;
    
    // show flipNumberView
    BOOL addGestureRecognizer = YES;
    NSInteger section = self.indexPath.section;
    NSInteger row = self.indexPath.row;
    if (section == 0) {
        if (row == 0) {
            [self showSingleDigit];
        } else if (row == 1) {
            [self showMultipleDigits];
        }  else if (row == 2) {
            [self showTargetedAnimation];
        }  else if (row == 3) {
            [self showTime];
            addGestureRecognizer = NO;
            self.infoLabel.text = @"The current time.";
        }  else if (row == 4) {
            [self showDateCountdown];
            addGestureRecognizer = NO;
            self.infoLabel.text = @"Counting the days/hours/min/sec";
        }
    } else {
        if (row == 0) {
            [self showFlipImage];
        }  else if (row == 1) {
            [self showColouredView];
            self.infoLabel.text = @"Click to flip to a new color!";
        }  else if (row == 2) {
            [self showWebView];
            self.infoLabel.text = @"Click outside of webview to flip it!";
        }
    }
    
    // add gesture recognizer
    if (addGestureRecognizer) {
        [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(viewTapped:)]];
    }
}

- (void)showSingleDigit;
{
    JDFlipNumberView *flipView = [[JDFlipNumberView alloc] initWithDigitCount:1 imageBundleName:self.imageBundleName];
    flipView.value = arc4random() % 10;
    flipView.delegate = self;
    flipView.reverseFlippingDisabled = [self isReverseFlippingDisabled];
    [self.view addSubview: flipView];
    self.flipView = flipView;
}

- (void)showMultipleDigits;
{
    JDFlipNumberView *flipView = [[JDFlipNumberView alloc] initWithDigitCount:3 imageBundleName:self.imageBundleName];
    flipView.value = 32;
    flipView.maximumValue = 128;
    flipView.reverseFlippingDisabled = [self isReverseFlippingDisabled];
    [self.view addSubview: flipView];
    self.flipView = flipView;
    
    [flipView animateDownWithTimeInterval:0.3];
}

- (void)showTargetedAnimation;
{
    JDFlipNumberView *flipView  = [[JDFlipNumberView alloc] initWithDigitCount:5 imageBundleName:self.imageBundleName];
    flipView.value = 2300;
    flipView.delegate = self;
    flipView.reverseFlippingDisabled = [self isReverseFlippingDisabled];
    [self.view addSubview: flipView];
    self.flipView = flipView;
    
    [self animateToTargetValue:9250];
}

- (void)showTime;
{
    JDFlipClockView *flipView  = [[JDFlipClockView alloc] initWithImageBundleName:self.imageBundleName];
    flipView.showsSeconds = YES;
    [self.view addSubview: flipView];
    self.flipView = flipView;
}

- (void)showDateCountdown;
{
    // setup flipview
    JDDateCountdownFlipView *flipView = [[JDDateCountdownFlipView alloc] initWithDayDigitCount:3 imageBundleName:self.imageBundleName];
    [self.view addSubview: flipView];
    
    // countdown to new years
    NSDateComponents *currentComps = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"dd.MM.yy HH:mm"];
    flipView.targetDate = [dateFormatter dateFromString:[NSString stringWithFormat: @"01.01.%ld 00:00", (long)currentComps.year+1]];
    
    self.flipView = flipView;
}

- (void)showFlipImage;
{
    self.distanceSlider = [[UISlider alloc] init];
    self.distanceSlider.minimumValue = 100;
    self.distanceSlider.maximumValue = 1500;
    [self.distanceSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.distanceSlider];
    
    JDFlipImageView *flipImageView  = [[JDFlipImageView alloc] initWithImage:[UIImage imageNamed:@"example01.jpg"]];
    [self.view addSubview: flipImageView];
    self.flipView = flipImageView;
}

- (void)showColouredView;
{
    self.colorView = [[UIView alloc] initWithFrame:CGRectInset(self.view.bounds, 20.0, 80.0)];
    self.colorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.colorView.backgroundColor = [UIColor colorWithHue:0.6 saturation:0.85 brightness:0.9 alpha:1.0];
    [self.view addSubview:self.colorView];
}

- (void)showWebView;
{
    WKWebView *webview1 = [[WKWebView alloc] initWithFrame:CGRectInset(self.view.bounds, 20.0, 80.0) configuration:[WKWebViewConfiguration new]];
    webview1.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [webview1 loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://duckduckgo.com/"]]];
    [self.view addSubview:webview1];
    
    WKWebView *webview2 = [[WKWebView alloc] initWithFrame:CGRectInset(self.view.bounds, 20.0, 80.0) configuration:[WKWebViewConfiguration new]];
    webview2.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [webview2 loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.com/"]]];
    
    self.webviews = @[webview1, webview2];
}

#pragma mark helper

- (BOOL)isReverseFlippingDisabled;
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"reverseFlippingDisabled"];
}

#pragma mark interaction

- (void)sliderValueChanged:(UISlider*)slider;
{
    [(JDFlipNumberView*)self.flipView setZDistance:slider.value];
    self.infoLabel.text = [NSString stringWithFormat: @"zDistance: %.0f", slider.value];
}

- (void)viewTapped:(UITapGestureRecognizer*)recognizer
{
    if ([self.flipView isKindOfClass:[JDFlipImageView class]])
    {
        JDFlipImageView *flipImageView = (JDFlipImageView*)self.flipView;
        
        self.imageIndex = (self.imageIndex+1)%3;
        [flipImageView setImageAnimated:[UIImage imageNamed:[NSString stringWithFormat: @"example%02ld.jpg", (long)self.imageIndex+1]]];
    }
    else if (self.colorView != nil)
    {
        __weak typeof(self) blockSelf = self;
        [self.colorView updateWithFlipAnimationUpdates:^{
            blockSelf.colorView.backgroundColor = [UIColor colorWithHue:arc4random()%256/256.0 saturation:0.85 brightness:0.9 alpha:1.0];
        }];
    }
    else if (self.webviews != nil) {
        if ([self.webviews[0] superview] != nil) {
            [self.webviews[0] flipToView:self.webviews[1]];
        } else {
            [self.webviews[1] flipToView:self.webviews[0]];
        }
    }
    else if (self.flipView != nil)
    {
        JDFlipNumberView *flipView = (JDFlipNumberView*)self.flipView;
        
        // set delegate after first touch
        if (self.indexPath.row == 1) {
            flipView.delegate = self;
        }

        NSInteger randomNumber = arc4random()%(int)floor(flipView.maximumValue/3.0) - floor(flipView.maximumValue/6.0);
        if (randomNumber == 0) randomNumber = 1;
        NSInteger newValue = ABS(flipView.value+randomNumber);
        
        if (self.indexPath.row < 2) {
            [flipView setValue:newValue animated:YES];
        } else {
            [self animateToTargetValue:newValue];
        }
    }
}

- (void)animateToTargetValue:(NSInteger)targetValue;
{
    JDFlipNumberView *flipView = (JDFlipNumberView*)self.flipView;
    
    NSDate *startDate = [NSDate date];
    [flipView animateToValue:targetValue duration:2.50 completion:^(BOOL finished) {
        if (finished) {
            NSLog(@"Animation needed: %.2f seconds", [[NSDate date] timeIntervalSinceDate:startDate]);
        } else {
            NSLog(@"Animation canceled after: %.2f seconds", [[NSDate date] timeIntervalSinceDate:startDate]);
        }
    }];
}

#pragma mark layout

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (!self.flipView) {
        return;
    }
    
    CGFloat multiplier = 1.0;
    CGRect frame = self.view.bounds;
    if (self.distanceSlider) {
        self.distanceSlider.frame = CGRectMake(10,
                                               self.infoLabel.frame.origin.y - 44 - 10,
                                               frame.size.width-20,
                                               44);
    }
    
    self.flipView.frame = CGRectInset(frame,
                                      MAX(MAX(self.view.safeAreaInsets.left, self.view.safeAreaInsets.right), 20),
                                      MAX(MAX(self.view.safeAreaInsets.top, self.view.safeAreaInsets.bottom), 20));
    [self.flipView sizeToFit];
    self.flipView.center = CGPointMake(floor(self.view.frame.size.width/2.0),
                                       floor((self.view.frame.size.height/2.0)*multiplier));
    
    // update zDistance
    if (self.distanceSlider) {
        self.distanceSlider.value = [(JDFlipNumberView*)self.flipView zDistance];
        self.infoLabel.text = @"Tap to flip to next image!";
    }
}

#pragma mark rotation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight | UIInterfaceOrientationPortrait;
}

#pragma mark delegate

- (void)flipNumberView:(JDFlipNumberView*)flipNumberView willChangeToValue:(NSUInteger)newValue;
{
    self.infoLabel.text = [NSString stringWithFormat: @"Will animate to %lu", (unsigned long)newValue];
}

- (void)flipNumberView:(JDFlipNumberView*)flipNumberView didChangeValueAnimated:(BOOL)animated;
{
    self.infoLabel.text = [NSString stringWithFormat: @"Finished animation to %ld.", (long)flipNumberView.value];
}

@end
