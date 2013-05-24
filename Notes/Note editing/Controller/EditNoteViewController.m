//
//  EditNoteViewController.m
//  Notes
//
//  Created by Dany on 5/21/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "EditNoteViewController.h"

#import "EditRichTextViewController.h"

@interface EditNoteViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) EditRichTextViewController *editTextController;

- (void)configureView;
@end

@implementation EditNoteViewController

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

    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    [self.editTextController loadLocalPageNamed:@"NoteTemplate"];
}

- (void)configureView
{
    if (self.detailItem) {
//        self.detailDescriptionLabel.text =
        self.editTextController.note = self.detailItem;
    }
}

#pragma mark - Actions

- (void)save
{
    
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

- (void)setDetailItem:(Note *)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
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
