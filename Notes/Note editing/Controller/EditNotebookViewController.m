//
//  EditNotebookViewController.m
//  Notes
//
//  Created by Dany on 5/25/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "EditNotebookViewController.h"

#import "EditRichTextViewController.h"
#import "NoteManager.h"
#import "ColorPickerView.h"

#define PopoverWidth            498.f
#define ColorPickerViewWidth    100.f
#define TopMargin               10.f
#define VerticalPadding         10.f
#define SideMargin              10.f

@interface EditNotebookViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *notebookNameField;
@property (nonatomic, strong) UITextField *userNameField;
@property (nonatomic, strong) ColorPickerView *colorPickerView;
@end

@implementation EditNotebookViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if( self ) {
        _rightBarButtonTitle = @"Done";
    }   

    return self;
}

#pragma mark - View creation

- (void)loadView {
    [super loadView];

    self.view.backgroundColor = [UIColor whiteColor];

    UILabel *(^createSideLabel)(NSString *) = ^UILabel *(NSString *title) {
        UILabel *label = [UILabel new];
        label.font = [FontManager helveticaNeueWithSize:16.f];
        label.textColor = [UIColor grayColor];
        label.text = title;
        label.textAlignment = NSTextAlignmentCenter;
        label.frame = (CGRect) {
            CGPointZero,
            [label sizeThatFits:(CGSize) {CGFLOAT_MAX, CGFLOAT_MAX }].width + 10.f,
            label.font.lineHeight
        };
        return label;
    };

    UITextField *(^createTextField)(NSString *) = ^UITextField *(NSString *title) {
        static NSInteger tag = 0;

        UITextField *textField = [UITextField new];
        textField.leftView = createSideLabel(title);
        textField.leftViewMode = UITextFieldViewModeAlways;
        textField.font = [FontManager helveticaNeueWithSize:16.f];
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.backgroundColor = [UIColor whiteColor];
        textField.delegate = self;
        textField.tag = tag++;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:textField];

        UIView *separator = [UIView new];
        separator.backgroundColor = [UIColor colorWithHexString:@"ccc"];
        separator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        separator.frame = (CGRect) {
            0.f,
            textField.frame.size.height - 1.f,
            0.f,
            1.f
        };
        [textField addSubview:separator];

        return textField;
    };

    _notebookNameField = createTextField(@"notebook name:");
    [self.view addSubview:_notebookNameField];

    _userNameField = createTextField(@"name on assignments:");
    [self.view addSubview:_userNameField];

    _colorPickerView = [ColorPickerView new];
    [_colorPickerView addTarget:self action:@selector(colorPicked:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_colorPickerView];
    
    [self viewWillLayoutSubviews];
    self.contentSizeForViewInPopover = (CGSize) {
        PopoverWidth,
        CGRectGetMaxY(self.colorPickerView.frame) + VerticalPadding
    };
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;

    NSString *lastUserName = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastUserName"];

    if( lastUserName ) {
        self.userNameField.text = lastUserName;
    }
    else {
        self.userNameField.placeholder = @"Your Name";
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureView];
    [self.notebookNameField becomeFirstResponder];
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    self.notebookNameField.frame = (CGRect) {
        CGPointZero,
        self.view.frame.size.width,
        45.f
    };

    self.userNameField.frame = (CGRect) {
        0.f,
        CGRectGetMaxY(_notebookNameField.frame),
        self.view.frame.size.width,
        45.f
    };

    [self.colorPickerView sizeToFit];
    self.colorPickerView.frame = (CGRect) {
        SideMargin,
        CGRectGetMaxY(self.userNameField.frame) + TopMargin,
        self.colorPickerView.frame.size
    };
}

#pragma mark - Data

- (void)configureView {
    self.notebookNameField.text = self.notebook.name;
    self.userNameField.text = self.notebook.defaultUserName;
    [self updateToolbar];
}

- (void)updateToolbar {
    if( !self.navigationItem.rightBarButtonItem ) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:self.rightBarButtonTitle style:UIBarButtonItemStyleDone target:self action:@selector(finishEditing:)];
        doneButton.enabled = NO;
        self.navigationItem.rightBarButtonItem = doneButton;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = self.notebookNameField.text.length > 0;
}

- (void)commitChangesToNotebookObject {
    self.notebook.name = self.notebookNameField.text;
    self.notebook.defaultUserName = self.userNameField.text;
    self.notebook.color = self.colorPickerView.selectedColor;
}

#pragma mark - Actions

- (void)cancel:(id)sender {
    [self.delegate editNotebookViewControllerDidFinishEditing:self];
}

- (void)finishEditing:(id)sender {
    [self commitChangesToNotebookObject];
    [[NoteManager sharedInstance] saveToDisk];
    [self.delegate editNotebookViewControllerDidFinishEditing:self];
}

- (void)textFieldTextDidChange:(NSNotification *)notification {
    UITextField *textField = (UITextField *)notification.object;

    if( textField == _notebookNameField ) {
        [self updateToolbar];
    }
    
    [self commitChangesToNotebookObject];
}

- (void)colorPicked:(ColorPickerView *)colorPickerView {
    [self commitChangesToNotebookObject];
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    NSInteger nextTag = textField.tag + 1;

    UIResponder *nextResponder = [textField.superview viewWithTag:nextTag];

    if( nextResponder ) {
        [nextResponder becomeFirstResponder];
    }
    else {
        if( self.navigationItem.rightBarButtonItem.enabled ) {
            [self finishEditing:self];
        }
        else {
            [_notebookNameField becomeFirstResponder];
        }
    }

    return NO;
}

@end
