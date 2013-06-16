//
//  NoteSearchViewController.m
//  Notes
//
//  Created by Dany on 6/15/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "NoteSearchViewController.h"

#import "EditNoteViewController.h"
#import "EditRichTextViewController.h"

#define CollapsedHeight 64.f
#define ExpandedHeight  832.f

@interface NoteSearchViewController () <UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@end

@implementation NoteSearchViewController {
    
}

- (id)init
{
    self = [super initWithNibName:@"NoteSearchViewController" bundle:nil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentSizeForViewInPopover = (CGSize) {
        self.view.frame.size.width,
        CollapsedHeight
    };
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self updateSearchWithText:searchText];
}

- (void)updateSearchWithText:(NSString *)searchText
{
    EditRichTextViewController *editTextController = [[EditNoteViewController sharedInstance] editTextController];
//    NSString *plainTextContent = [editTextController plainTextContent];
//    [plainTextContent enumer]
    
    editTextController.searchTerm = searchText;
}

@end
