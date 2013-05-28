//
//  EditNoteViewController.h
//  Notes
//
//  Created by Dany on 5/21/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Note;

@interface EditNoteViewController : UIViewController <UISplitViewControllerDelegate>

+ (EditNoteViewController *)sharedInstance;

@property (strong, nonatomic) Note *note;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
