//
//  NoteListViewController.h
//  Notes
//
//  Created by Dany on 5/21/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@class EditNoteViewController, Notebook;

@interface NoteListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) Notebook *notebook;

@end
