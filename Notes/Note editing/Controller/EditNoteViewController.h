//
//  EditNoteViewController.h
//  Notes
//
//  Created by Dany on 5/21/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MGSplitViewController.h"

@class Note, EditRichTextViewController;

@interface EditNoteViewController : UIViewController <UISplitViewControllerDelegate, MGSplitViewControllerDelegate>

+ (EditNoteViewController *)sharedInstance;

@property (strong, nonatomic) Note *note;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic, strong) EditRichTextViewController *editTextController;

@end
