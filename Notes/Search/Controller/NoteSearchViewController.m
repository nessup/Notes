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
#import "MainSplitViewController.h"

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
    EditRichTextViewController *editTextController = [[[MainSplitViewController sharedInstance] editNoteViewController] editTextController];
    editTextController.searchTerm = searchText;
    
//    NSString *plainTextContent = [editTextController plainTextContent];
//    int occurence = 0;
//    NSRange range;
//    while(YES) {
//        range = [self rangeOfString:searchText inString:plainTextContent atOccurence:occurence];
//        if( range.location == NSNotFound ) {
//            return;
//        }
//        
//        
//        occurence++;
//    }
}

- (NSRange)rangeOfString:(NSString *)substring
                inString:(NSString *)string
             atOccurence:(int)occurence
{
    int currentOccurence = 0;
    NSRange rangeToSearchWithin = NSMakeRange(0, string.length);
    
    while (YES)
    {
        currentOccurence++;
        NSRange searchResult = [string rangeOfString: substring
                                             options: NULL
                                               range: rangeToSearchWithin];
        
        if (searchResult.location == NSNotFound)
        {
            return searchResult;
        }
        if (currentOccurence == occurence)
        {
            return searchResult;
        }
        
        int newLocationToStartAt = searchResult.location + searchResult.length;
        rangeToSearchWithin = NSMakeRange(newLocationToStartAt, string.length - newLocationToStartAt);
    }
}

@end
