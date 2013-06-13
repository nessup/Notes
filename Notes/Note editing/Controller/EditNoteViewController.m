//
//  EditNoteViewController.m
//  Notes
//
//  Created by Dany on 5/21/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "EditNoteViewController.h"

#import "EditRichTextViewController.h"
#import "MGSplitViewController.h"

@interface EditNoteViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) UIPopoverController *transcriptPopoverController;
@property (nonatomic, strong) EditRichTextViewController *editTextController;

- (void)configureView;
@end

@implementation EditNoteViewController

+ (EditNoteViewController *)sharedInstance
{
    static EditNoteViewController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}

#pragma mark - Managing the detail item

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.editTextController loadLocalPageNamed:@"NoteTemplate"];
}

- (void)configureView
{
    if (self.note) {
//        self.detailDescriptionLabel.text =
        self.editTextController.note = self.note;
    }
}

#pragma mark - Properties

- (EditRichTextViewController *)editTextController
{
    if( _editTextController )
        return _editTextController;
    
    _editTextController = [EditRichTextViewController new];
    _editTextController.wantsFullScreenLayout = YES;
    [self addChildViewController:_editTextController];
    [self.view addSubview:_editTextController.view];
    [_editTextController didMoveToParentViewController:self];
    
    return _editTextController;
}

- (void)setNote:(Note *)note
{
    if (_note != note) {
        _note = note;
        
        [self configureView];
    }
    
    [self.masterPopoverController dismissPopoverAnimated:YES];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    if( [splitController isKindOfClass:[MGSplitViewController class]] ) {
        barButtonItem.title = NSLocalizedString(@"Right", @"Right");
        [self.navigationItem setRightBarButtonItem:barButtonItem animated:YES];
        self.transcriptPopoverController = popoverController;
    }
    else {
        barButtonItem.title = NSLocalizedString(@"Master", @"Master");
        [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
        self.masterPopoverController = popoverController;
    }
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if( [splitController isKindOfClass:[MGSplitViewController class]] ) {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
        self.transcriptPopoverController = nil;
    }
    else {
        // Called when the view is shown again in the split view, invalidating the button and popover controller.
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
        self.masterPopoverController = nil;
    }
}

- (void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController
{
    if( [svc isKindOfClass:[MGSplitViewController class]] ) {
        
    }
    else {
        [self.editTextController commitChangesToNote];
    }
}

#pragma mark - Actions

- (void)toggleTranscript:(id)sender
{
    
}

@end
