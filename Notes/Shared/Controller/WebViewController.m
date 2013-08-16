//
//  WebViewController.m
//  Notes
//
//  Created by Dany on 7/9/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "WebViewController.h"

#import "Model.h"
#import "WebViewJavascriptBridge_iOS.h"
#import "NoteManager.h"
#import "RTEGestureRecognizer.h"

NSString *const WebViewEventName = @"eventName";
NSString *const WebViewEventValue = @"value";

@interface WebViewController () <UINavigationControllerDelegate, UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation WebViewController {
    NSMutableArray *_afterDOMLoadsBlocks;
    BOOL _DOMLoaded;
    NSInteger loadCount;
}

- (id)initWithLocalPageNamed:(NSString *)pageName subdirectory:(NSString *)subdirectory {
    self = [super initWithNibName:nil bundle:nil];
    
    if( self ) {
        _afterDOMLoadsBlocks = [NSMutableArray array];
        
        _webView = [UIWebView new];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _webView.keyboardDisplayRequiresUserAction = NO;
        _webView.delegate = self;
        _webView.clipsToBounds = YES;
        self.webView.frame = self.view.bounds;
        
        self.bridge = [WebViewJavascriptBridge
                       bridgeForWebView:_webView
                       handler:^(id data, WVJBResponseCallback responseCallback) {
                           if( [data isKindOfClass:[NSDictionary class]] ) {
                               
                               if( [data[WebViewEventName] isEqualToString:@"logToConsole"] ) {
                                   NSLog(@"console.log: %@", data[WebViewEventValue]);
                               }
                               
                               if( ![self handleWebViewEvent:data] ) {
                                   [self.delegate webViewController:self didReceiveUnknownEvent:data];
                               }
                           }
                       }];
        
        [_webView loadRequest:[NSURLRequest requestWithURL:[[NSBundle mainBundle] URLForResource:pageName withExtension:@"html" subdirectory:subdirectory]]];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.webView];
}

#pragma mark - Web view event handling

- (BOOL)handleWebViewEvent:(NSDictionary *)event {
    return NO;
}

#pragma mark - Utility

- (void)doAfterDOMLoads:(void (^)())completion {
//    if( _DOMLoaded ) {
        if( completion ) {
            completion();
        }
//    }
//    else {
//        [_afterDOMLoadsBlocks addObject:[completion copy]];
//    }
}

- (BOOL)resignFirstResponder {
    BOOL resign = [super resignFirstResponder];
    if( resign ) {
        self.webView.userInteractionEnabled = NO;
        self.webView.userInteractionEnabled = YES;
    }
    return resign;
}

@end
