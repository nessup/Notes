//
//  TranscriptViewController.m
//  Notes
//
//  Created by Dany on 5/31/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "TranscriptViewController.h"

#import "SpeechToTextManager.h"
#import "WebViewController.h"
#import "Model.h"
#import "NoteManager.h"
#import "WebViewJavascriptBridge_iOS.h"

#define TopBarHeight    50.f
#define StatusBarHeight 50.f
#define SideMargin      3.f
#define ButtonHeight    44.f

@interface TranscriptViewController () <WebViewControllerDelegate>
@property (nonatomic, strong) WebViewController *webViewController;
@end

@implementation TranscriptViewController {
    UIButton *_toggleRecordButton;
    UIButton *_togglePlaybackButton;
    UIActivityIndicatorView *_activityIndicator;
    UILabel *_activityLabel;
    BOOL _hasRecorded;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if( self ) {
        _webViewController = [[WebViewController alloc] initWithLocalPageNamed:@"TranscriptTemplate"];
        _webViewController.delegate = self;
        _webViewController.view.clipsToBounds = YES;
        [self addChildViewController:_webViewController];
        [self.view addSubview:_webViewController.view];
        [_webViewController didMoveToParentViewController:self];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configureView) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)webViewController:(WebViewController *)webEditViewController didReceiveUnknownEvent:(NSDictionary *)event {
    if( [event[WebViewEventName] isEqualToString:@"playSegmentAtIndex"] ) {
        SpeechToTextManager *manager = [SpeechToTextManager sharedInstance];
        [manager startPlayingSegmentAtIndex:[event[WebViewEventValue] intValue]];
    }
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"Transcript";

    self.view.backgroundColor = [UIColor whiteColor];

    UIButton *(^createButton)(NSString *, SEL) = ^UIButton *(NSString *title, SEL selector) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.titleLabel.font = [FontManager helveticaNeueWithSize:16.f];
        [button setTitle:title forState:UIControlStateNormal];
        [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        return button;
    };

    _toggleRecordButton = createButton(@"Record", @selector(toggleRecording:));
    _togglePlaybackButton = createButton(@"Play", @selector(togglePlayback:));

    _activityIndicator = [UIActivityIndicatorView new];
    [_activityIndicator startAnimating];
    _activityIndicator.hidesWhenStopped = YES;
    _activityIndicator.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_activityIndicator];

    _activityLabel = [UILabel new];
    _activityLabel.font = [FontManager helveticaNeueWithSize:12.f];
    _activityLabel.textAlignment = NSTextAlignmentCenter;
    _activityLabel.contentMode = UIViewContentModeTop;
    _activityLabel.text = @"Transcribing...";
    _activityLabel.alpha = 0.5f;
    _activityLabel.textColor = [UIColor whiteColor];
    _activityLabel.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_activityLabel];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(speechToTextStateChanged:) name:SpeechToTextManagerStateChanged object:nil];

    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Note management

- (void)configureView {
    NSMutableString *text = [NSMutableString new];
    int i = 0;
    for( TranscriptionSegment *transcriptionSegment in self.note.transcriptionSegments ) {
        if( transcriptionSegment.text ) {
            [text appendFormat:@"<a href='javascript:App.playSegmentAtIndex(%d)'>%@</a>", i, transcriptionSegment.text];
        }
        else {
            [text appendFormat:@"<a href='javascript:App.playSegmentAtIndex(%d)'>|untitled segment %d|</a> ", i, i];
        }
        i++;
    }
    //    NSLog(@"%@", text);
    [_webViewController doAfterDOMLoads:^{
        [self.webViewController.bridge send:@{
         @"content" : text
         }];
    }];

    [self speechToTextStateChanged:self];
}

- (void)setNote:(Note *)note {
    if( _note == note )
        return;
    
    _note = note;
    
    _hasRecorded = !!note.transcriptionSegments.count;
    
    [[SpeechToTextManager sharedInstance] setNote:note];
    [self configureView];
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews {
    if( _hasRecorded ) {
        _toggleRecordButton.frame = (CGRect) {
            SideMargin,
            ceilf(TopBarHeight / 2.f - ButtonHeight / 2.f),
            ceilf((self.view.frame.size.width - 3 * SideMargin) / 2.f),
            ButtonHeight
        };
        _togglePlaybackButton.frame = (CGRect) {
            SideMargin + CGRectGetMaxX(_toggleRecordButton.frame),
            ceilf(TopBarHeight / 2.f - ButtonHeight / 2.f),
            ceilf((self.view.frame.size.width - 3 * SideMargin) / 2.f),
            ButtonHeight
        };
    }
    else {
        _toggleRecordButton.frame = (CGRect) {
            SideMargin,
            ceilf(TopBarHeight / 2.f - ButtonHeight / 2.f),
            self.view.frame.size.width - 2.f * SideMargin,
            ButtonHeight
        };
    }

    _activityIndicator.frame = (CGRect) {
        SideMargin,
        ceilf(StatusBarHeight / 2.f - _activityIndicator.frame.size.height / 2.f) + TopBarHeight,
        _activityIndicator.frame.size
    };
    _activityLabel.frame = (CGRect) {
        0.f,
        TopBarHeight,
        self.view.frame.size.width,
        StatusBarHeight
    };

    _webViewController.view.frame = (CGRect) {
        0.f,
        CGRectGetMaxY(_activityLabel.frame),
        self.view.frame.size.width,
        self.view.frame.size.height - CGRectGetMaxY(_activityLabel.frame)
    };
//    _transcriptLabel.frame = (CGRect) {
//        0.f,
//        CGRectGetMaxY(_activityLabel.frame),
//        self.view.frame.size.width,
//        100.f
//    };
}

#pragma mark - Actions

- (void)speechToTextStateChanged:(id)sender {
    SpeechToTextManagerState state = [[SpeechToTextManager sharedInstance] state];

    if( state & SpeechToTextManagerStateInterrupted ) {
        _toggleRecordButton.enabled = NO;
        _togglePlaybackButton.enabled = NO;
    }
    else {
        if( state & SpeechToTextManagerStateRecording ) {
            [_toggleRecordButton setTitle:@"Stop Recording" forState:UIControlStateNormal];
            _toggleRecordButton.enabled = YES;

            [_togglePlaybackButton setTitle:@"Play" forState:UIControlStateNormal];
            _togglePlaybackButton.enabled = NO;

            _hasRecorded = YES;
        }
        else if( state & SpeechToTextManagerStatePlaying ) {
            [_toggleRecordButton setTitle:@"Record" forState:UIControlStateNormal];
            _toggleRecordButton.enabled = NO;

            [_togglePlaybackButton setTitle:@"Stop Playing" forState:UIControlStateNormal];
            _togglePlaybackButton.enabled = YES;
        }
        else {
            [_toggleRecordButton setTitle:@"Record" forState:UIControlStateNormal];
            _toggleRecordButton.enabled = YES;

            [_togglePlaybackButton setTitle:@"Play" forState:UIControlStateNormal];
            _togglePlaybackButton.enabled = YES;
        }
    }

    if( state & SpeechToTextManagerStateError ) {
        [_activityIndicator stopAnimating];
        _activityLabel.hidden = NO;
        _activityLabel.text = @"Couldn't Transcribe";
    }

    if( state & SpeechToTextManagerStateTranscribing ) {
        [_activityIndicator startAnimating];
        _activityLabel.hidden = NO;
    }
    else {
        [_activityIndicator stopAnimating];
        _activityLabel.hidden = YES;
    }

    [self.view setNeedsLayout];
}

- (void)toggleRecording:(id)sender {
    SpeechToTextManagerState state = [[SpeechToTextManager sharedInstance] state];

    if( state & SpeechToTextManagerStateRecording ) {
        [[SpeechToTextManager sharedInstance] stop];
    }
    else {
        [[SpeechToTextManager sharedInstance] startRecording];
    }
}

- (void)togglePlayback:(id)sender {
    SpeechToTextManagerState state = [[SpeechToTextManager sharedInstance] state];

    if( state & SpeechToTextManagerStatePlaying ) {
        [[SpeechToTextManager sharedInstance] stop];
    }
    else {
//        [self.note.transcriptionAudio writeToFile:[[[SpeechToTextManager sharedInstance] soundFileURL] path] atomically:NO];
        [[SpeechToTextManager sharedInstance] startPlaying];
    }
}

- (void)addTranscriptionToCurrentNote:(NSString *)transcription audio:(NSData *)audio {
#warning TODO(DJ): Make this method add instead of overwrite transcriptions.
//    self.note.transcription = transcription;
//    self.note.transcriptionAudio = audio;

//    [self configureView];
    [[[NoteManager sharedInstance] context] refreshObject:self.note mergeChanges:YES];
    [[NoteManager sharedInstance] saveToDisk];
}

@end
