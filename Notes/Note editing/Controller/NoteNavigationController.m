//
//  NoteNavigationPopoverController.m
//  Notes
//
//  Created by Dany on 5/25/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "NoteNavigationController.h"

#import "NotebookListViewController.h"
#import "NoteListViewController.h"

@interface NoteNavigationController ()

@property (nonatomic, strong) UINavigationController *childNavigationController;
@property (nonatomic, strong) NotebookListViewController *notebookListController;
@property (nonatomic, strong) NoteListViewController *noteListViewController;

@end

@implementation NoteNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if( self ) {
        _notebookListController = [NotebookListViewController new];
        
        _noteListViewController = [NoteListViewController new];
        
        _childNavigationController = [UINavigationController new];
        
        [self pushViewController:_noteListViewController animated:NO];
    }
    return self;
}

#pragma mark - View controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}

@end
