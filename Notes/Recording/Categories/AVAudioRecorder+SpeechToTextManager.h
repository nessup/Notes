//
//  AVAudioRecorder+SpeechToTextManager.h
//  Notes
//
//  Created by Dany on 7/3/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVAudioRecorder (SpeechToTextManager)
@property (nonatomic, copy) NSString *prefix;
@property (nonatomic) NSUInteger fileIndex;
@end
