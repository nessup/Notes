//
//  NoteListViewController.h
//  Notes
//
//  Created by Dany on 5/21/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NoteListViewController;

@protocol NoteListViewControllerDelegate <NSObject>
- (void)noteListViewControllerDidFinish:(NoteListViewController *)noteListViewController;
@end

@class EditNoteViewController, EditNotebookViewController, Notebook, TableView;

@interface NoteListViewController : UIViewController <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) TableView *tableView;
@property (nonatomic, strong) Notebook *notebook;
@property (nonatomic, weak) UIPopoverController *parentPopoverController;
@property (nonatomic) BOOL showsTableHeaverViewOnly;
@property (nonatomic, strong) EditNotebookViewController *editNotebookViewController;
@property (nonatomic, weak) id<NoteListViewControllerDelegate> delegate;
@end
