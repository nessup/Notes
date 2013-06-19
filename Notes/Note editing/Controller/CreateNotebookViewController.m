//
//  CreateNotebookViewController.m
//  Notes
//
//  Created by Dany on 5/25/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "CreateNotebookViewController.h"

#import "EditRichTextViewController.h"
#import "NoteManager.h"
#import "ColorPickerView.h"

#define ModalWidth              485.f
#define ModalHeight             485.f
#define ColorPickerViewWidth    100.f
#define TopMargin               10.f
#define VerticalPadding         10.f

@interface CreateNotebookViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *notebookNameField;
@property (nonatomic, strong) UITextField *userNameField;
@property (nonatomic, strong) ColorPickerView *colorPickerView;

@end

@implementation CreateNotebookViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark - View creation

- (void)loadView
{
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
            [label sizeThatFits:(CGSize){CGFLOAT_MAX,CGFLOAT_MAX}].width + 10.f,
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
        separator.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
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
    [self.view addSubview:_colorPickerView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Create New Notebook";
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Create Notebook" style:UIBarButtonItemStyleDone target:self action:@selector(createNotebook:)];
    doneButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = doneButton;
    
    NSString *lastUserName = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastUserName"];
    if( lastUserName ) {
        self.userNameField.text = lastUserName;
    }
    else {
        self.userNameField.placeholder = @"Your Name";
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews
{
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
        roundf(self.view.frame.size.width/2.f - self.colorPickerView.frame.size.width/2.f),
        CGRectGetMaxY(self.userNameField.frame) + TopMargin,
        self.colorPickerView.frame.size
    };
}

- (void)sizeToFitForModalController:(UIViewController *)controller
{
    [self.view layoutIfNeeded];

    CGFloat offset = 0.f;
    
    if( controller ) {
        offset += [self.view convertRect:self.view.frame toView:controller.view].origin.y;
    }
    else {
        controller = self;
    }
    
    controller.view.superview.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    controller.view.superview.bounds = (CGRect) {
        CGPointZero,
        500.f,
        CGRectGetMaxY(self.colorPickerView.frame) + offset + VerticalPadding
    };
}

#pragma mark - Data

- (void)configureView
{
    
}

#pragma mark - Actions

- (void)cancel:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)createNotebook:(id)sender
{
    Notebook *notebook = [[NoteManager sharedInstance] createNewNotebookNamed:self.notebookNameField.text];
    notebook.defaultUserName = self.notebookNameField.text;
    notebook.color = self.colorPickerView.selectedColor;
    [[NoteManager sharedInstance] saveToDisk];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)textFieldTextDidChange:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)notification.object;
    if( textField == _notebookNameField ) {
        self.navigationItem.rightBarButtonItem.enabled = textField.text.length > 0;
    }
}

#pragma mark - Text field delegate

-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    NSInteger nextTag = textField.tag + 1;

    UIResponder * nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        [nextResponder becomeFirstResponder];
    } else {
        if( self.navigationItem.rightBarButtonItem.enabled ) {
            [self createNotebook:self];
        }
        else {
            [_notebookNameField becomeFirstResponder];
        }
    }
    
    return NO;
}

@end
