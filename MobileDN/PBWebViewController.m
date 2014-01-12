//
//  PBWebViewController.m
//  Pinbrowser
//
//  Created by Mikael Konutgan on 11/02/2013.
//  Copyright (c) 2013 Mikael Konutgan. All rights reserved.
//

#import "PBWebViewController.h"
#import "OvershareKit.h"

@interface PBWebViewController () <UIPopoverControllerDelegate, OSKPresentationViewControllers, OSKPresentationStyle,OSKPresentationColor>

@property (strong, nonatomic) UIWebView *webView;

@property (strong, nonatomic) UIBarButtonItem *stopLoadingButton;
@property (strong, nonatomic) UIBarButtonItem *reloadButton;
@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) UIBarButtonItem *forwardButton;

@property (strong, nonatomic) UIPopoverController *activitiyPopoverController;

@property (assign, nonatomic) BOOL toolbarPreviouslyHidden;

@property (assign, nonatomic) OSKActivitySheetViewControllerStyle sheetStyle;

@end



@implementation PBWebViewController

- (id)init
{
    self = [super init];
    if (self) {
        _showsNavigationToolbar = YES;
        [[OSKPresentationManager sharedInstance] setViewControllerDelegate:self];
        [[OSKPresentationManager sharedInstance] setColorDelegate:self];
        [[OSKPresentationManager sharedInstance] setStyleDelegate:self];
    }
    return self;
}

- (void)load
{
    NSURLRequest *request = [NSURLRequest requestWithURL:self.URL];
    [self.webView loadRequest:request];
    
    if (self.navigationController.toolbarHidden) {
        self.toolbarPreviouslyHidden = YES;
        if (self.showsNavigationToolbar) {
            [self.navigationController setToolbarHidden:NO animated:YES];
        }
    }
}

- (void)clear
{
    [self.webView loadHTMLString:@"" baseURL:nil];
    self.title = @"";
}

#pragma mark - View controller lifecycle

- (void)loadView
{
    self.webView = [[UIWebView alloc] init];
    self.webView.scalesPageToFit = YES;
    self.view = self.webView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupToolBarItems];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.webView.delegate = self;
    if (self.URL) {
        [self load];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.webView stopLoading];
    self.webView.delegate = nil;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (self.toolbarPreviouslyHidden && self.showsNavigationToolbar) {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

#pragma mark - Helpers

- (UIImage *)backButtonImage
{
    static UIImage *image;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        CGSize size = CGSizeMake(12.0, 21.0);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        path.lineWidth = 1.5;
        path.lineCapStyle = kCGLineCapButt;
        path.lineJoinStyle = kCGLineJoinMiter;
        [path moveToPoint:CGPointMake(11.0, 1.0)];
        [path addLineToPoint:CGPointMake(1.0, 11.0)];
        [path addLineToPoint:CGPointMake(11.0, 20.0)];
        [path stroke];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    return image;
}

- (UIImage *)forwardButtonImage
{
    static UIImage *image;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        UIImage *backButtonImage = [self backButtonImage];
        
        CGSize size = backButtonImage.size;
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGFloat x_mid = size.width / 2.0;
        CGFloat y_mid = size.height / 2.0;
        
        CGContextTranslateCTM(context, x_mid, y_mid);
        CGContextRotateCTM(context, M_PI);
        
        [backButtonImage drawAtPoint:CGPointMake(-x_mid, -y_mid)];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    return image;
}

- (void)setupToolBarItems
{
    self.stopLoadingButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                           target:self.webView
                                                                           action:@selector(stopLoading)];
    
    self.reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                      target:self.webView
                                                                      action:@selector(reload)];
    
    self.backButton = [[UIBarButtonItem alloc] initWithImage:[self backButtonImage]
                                                       style:UIBarButtonItemStylePlain
                                                      target:self.webView
                                                      action:@selector(goBack)];
    
    self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[self forwardButtonImage]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self.webView
                                                         action:@selector(goForward)];
    
    self.backButton.enabled = NO;
    self.forwardButton.enabled = NO;
    
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                  target:self
                                                                                  action:@selector(action:)];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil];
    
    UIBarButtonItem *space_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                            target:nil
                                                                            action:nil];
    space_.width = 60.0f;
    
    self.toolbarItems = @[self.stopLoadingButton, space, self.backButton, space_, self.forwardButton, space, actionButton];
}

- (void)toggleState
{
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
    
    NSMutableArray *toolbarItems = [self.toolbarItems mutableCopy];
    if (self.webView.loading) {
        toolbarItems[0] = self.stopLoadingButton;
    } else {
        toolbarItems[0] = self.reloadButton;
    }
    self.toolbarItems = [toolbarItems copy];
}

- (void)finishLoad
{
    [self toggleState];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - Button actions

- (void)action:(id)sender
{
//    if (self.activitiyPopoverController.popoverVisible) {
//        [self.activitiyPopoverController dismissPopoverAnimated:YES];
//        return;
//    }
//    
//    NSArray *activityItems;
//    if (self.activityItems) {
//        activityItems = [self.activityItems arrayByAddingObject:self.URL];
//    } else {
//        activityItems = @[self.URL];
//    }
//    
//    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:activityItems
//                                                                     applicationActivities:self.applicationActivities];
//    if (self.excludedActivityTypes) {
//        vc.excludedActivityTypes = self.excludedActivityTypes;
//    }
//    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
//        [self presentViewController:vc animated:YES completion:NULL];
//    } else {
//        if (!self.activitiyPopoverController) {
//            self.activitiyPopoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
//        }
//        self.activitiyPopoverController.delegate = self;
//        [self.activitiyPopoverController presentPopoverFromBarButtonItem:[self.toolbarItems lastObject]
//                                                permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//    }
    
    NSString *saveUrl = [self.URL absoluteString];
    
    // 1) Create the shareable content from the user's source content.
    OSKShareableContent *content = [OSKShareableContent contentFromMicroblogPost:@"Test"
                                                                      authorName:nil
                                                                    canonicalURL:saveUrl
                                                                          images:nil];
    
    OSKActivityCompletionHandler completionHandler = [self activityCompletionHandler];
    OSKPresentationEndingHandler dismissalHandler = [self dismissalHandler];
    
    NSDictionary *options = @{    OSKPresentationOption_ActivityCompletionHandler : completionHandler,
                                  OSKPresentationOption_PresentationEndingHandler : dismissalHandler};
    
    // 4) Present the activity sheet via the presentation manager.
    [[OSKPresentationManager sharedInstance] presentActivitySheetForContent:content
                                                   presentingViewController:self
                                                                    options:options];
}

- (OSKActivityCompletionHandler)activityCompletionHandler {
    OSKActivityCompletionHandler activityCompletionHandler = ^(OSKActivity *activity, BOOL successful, NSError *error){
        if (successful) {
        } else {
        }
    };
    return activityCompletionHandler;
}

- (OSKPresentationEndingHandler)dismissalHandler {
    OSKPresentationEndingHandler dismissalHandler = ^(OSKPresentationEnding ending, OSKActivity *activityOrNil){
        OSKLog(@"Sheet dismissed.");
    };
    return dismissalHandler;
}

#pragma mark - Web view delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self toggleState];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self finishLoad];
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.URL = self.webView.request.URL;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self finishLoad];
}

#pragma mark - Popover controller delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.activitiyPopoverController = nil;
}


- (OSKActivitySheetViewControllerStyle)osk_activitySheetStyle {
    return self.sheetStyle;
}

- (BOOL)osk_toolbarsUseUnjustifiablyBorderlessButtons {
    BOOL hellNo = NO;
    return hellNo;
}



#pragma mark - OSKPresentationManager Color Delegate

- (UIColor *)osk_color_action {
    UIColor *color = nil;
    color = [UIColor colorWithRed:0.00 green:0.48 blue:1.00 alpha:1.0];
    return color;
}



#pragma mark - OSKPresentationManager View Controller Delegate

- (void)presentationManager:(OSKPresentationManager *)manager willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView *__autoreleasing *)view {
    *rect = self.view.bounds;
}


- (UIViewController <OSKPurchasingViewController> *)osk_purchasingViewControllerForActivity:(OSKActivity *)activity {
    return NO;
}



@end
