//
//  TranscriptViewController.m
//  Notes
//
//  Created by Dany on 5/31/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "TranscriptViewController.h"

#import "SpeechToTextManager.h"
#import "EditRichTextViewController.h"
#import "Model.h"
#import "NoteManager.h"

#define TopBarHeight    50.f
#define StatusBarHeight 50.f
#define SideMargin      3.f
#define ButtonHeight    44.f

@interface TranscriptViewController ()

@end

@implementation TranscriptViewController {
    UIButton *_toggleRecordButton;
    UIButton *_togglePlaybackButton;
    UIActivityIndicatorView *_activityIndicator;
    UILabel *_activityLabel;
    BOOL _hasRecorded;
//    EditRichTextViewController *_webViewController;
    UILabel *_transcriptLabel;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if( self ) {
//        _webViewController = [EditRichTextViewController new];
//        [self addChildViewController:_webViewController];
//        [self.view addSubview:_webViewController.view];
//        [_webViewController didMoveToParentViewController:self];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configureView) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"Transcript";

    self.view.backgroundColor = [UIColor redColor];

//    [_webViewController view];
//
//    [_webViewController loadLocalPageNamed:@"TranscriptTemplate"];

    _transcriptLabel = [UILabel new];
//    _transcriptLabel.font = [FontManager helveticaNeueWithSize:16.f];
    _transcriptLabel.text = @"lol";
    _transcriptLabel.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_transcriptLabel];

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
    _activityLabel.backgroundColor = [UIColor blackColor];
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
//    [_webViewController doAfterDOMLoads:^{
//        [_webViewController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setContent('%@')", @"omgomg"]];
//    }];
    _transcriptLabel.text = self.note.transcription;

    [self speechToTextStateChanged:self];
}

- (void)setNote:(Note *)note {
    _note = note;

    _hasRecorded = !!note.transcriptionAudio;

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

    //    _webViewController.view.frame = (CGRect) {
    //        0.f,
    //        CGRectGetMaxY(_activityLabel.frame),
    //        self.view.frame.size.width,
    //        self.view.frame.size.height - TopBarHeight - StatusBarHeight
    //    };
    _transcriptLabel.frame = (CGRect) {
        0.f,
        CGRectGetMaxY(_activityLabel.frame),
        self.view.frame.size.width,
        100.f
    };
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

        [[SpeechToTextManager sharedInstance] getText:^(NSString *transcription, NSData *transcriptionAudio) {
                                                if( transcription && transcriptionAudio ) {
                                                [self                                 addTranscriptionToCurrentNote:transcription
                                                                              audio:transcriptionAudio];
                                                }
                                              }];
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
        [self.note.transcriptionAudio writeToFile:[[[SpeechToTextManager sharedInstance] soundFileURL] path] atomically:NO];
        [[SpeechToTextManager sharedInstance] startPlaying];
    }
}

- (void)addTranscriptionToCurrentNote:(NSString *)transcription audio:(NSData *)audio {
#warning TODO(DJ): Make this method add instead of overwrite transcriptions.
    self.note.transcription = transcription;
    self.note.transcriptionAudio = audio;

//    [self configureView];
    [[[NoteManager sharedInstance] context] refreshObject:self.note mergeChanges:YES];
    [[NoteManager sharedInstance] saveToDisk];
}

@end
