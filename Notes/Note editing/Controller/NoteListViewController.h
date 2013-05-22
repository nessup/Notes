//
//  NoteListViewController.h
//  Notes
//
//  Created by Dany on 5/21/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditNoteViewController;

#import <CoreData/CoreData.h>

@interface NoteListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) EditNoteViewController *editNoteViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
