//
//  SpeechToTextManager.h
//  Notes
//
//  Created by Dany on 5/29/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const SpeechToTextManagerStateChanged;

typedef enum {
        SpeechToTextManagerStateIdle = 1 << 0,
        SpeechToTextManagerStateRecording = 1 << 1,
        SpeechToTextManagerStateTranscribing = 1 << 2,
        SpeechToTextManagerStatePlaying = 1 << 3,
        SpeechToTextManagerStateInterrupted = 1 << 4,
        SpeechToTextManagerStateError = 1 << 5
} SpeechToTextManagerState;

@class Note;

@interface SpeechToTextManager : NSObject

@property (nonatomic, readonly) SpeechToTextManagerState state;
@property (nonatomic, strong) Note *note;

+ (SpeechToTextManager *)sharedInstance;

- (void)startRecording;
- (void)startPlaying;
- (void)stop;

- (void)getText:(void(^) (NSString *, NSData *))completion;

@end
