//
//  EditNoteViewController.m
//  Notes
//
//  Created by Dany on 5/21/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "EditNoteViewController.h"

@interface EditNoteViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@property (nonatomic, weak) UIWebView *webView;

- (void)configureView;
@end

@implementation EditNoteViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"timeStamp"] description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}

#pragma mark - Properties

- (UIWebView *)webView
{
    if( _webView )
        return _webView;
    
    UIWebView *webView = [UIWebView new];
    [webView loadData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NoteTemplate" ofType:@"html"]]
             MIMEType:@"text/html"
     textEncodingName:@"utf-8"
              baseURL:[[NSBundle mainBundle] bundleURL]];
    [self.view addSubview:webView];
    _webView = webView;
    
    return _webView;
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews
{
    self.webView.frame = self.view.bounds;
}
							
#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
