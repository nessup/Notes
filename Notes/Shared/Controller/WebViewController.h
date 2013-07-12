//
//  WebEditViewController.h
//  Notes
//
//  Created by Dany on 7/9/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const WebViewEventName;
extern NSString *const WebViewEventValue;

@class WebViewController;

@protocol WebViewControllerDelegate <NSObject>
- (void)webViewController:(WebViewController *)webEditViewController didReceiveUnknownEvent:(NSDictionary *)event;
@end

@class WebViewJavascriptBridge;

@interface WebViewController : UIViewController
@property (nonatomic, strong, readonly) UIWebView *webView;
@property (nonatomic, weak) id<WebViewControllerDelegate> delegate;
@property (nonatomic, strong) WebViewJavascriptBridge *bridge;

- (id)initWithLocalPageNamed:(NSString *)pageName;

- (void)doAfterDOMLoads:(void (^)())completion;
- (BOOL)handleWebViewEvent:(NSDictionary *)event;

@end
