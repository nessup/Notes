//
//  AVAudioRecorder+SpeechToTextManager.m
//  Notes
//
//  Created by Dany on 7/3/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "AVAudioRecorder+SpeechToTextManager.h"

#import <objc/runtime.h>

@implementation AVAudioRecorder (SpeechToTextManager)

- (NSString *)prefix {
    return objc_getAssociatedObject(self, @selector(prefix));
}

- (void)setPrefix:(NSString *)prefix {
    objc_setAssociatedObject(self, @selector(prefix), prefix, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSUInteger)fileIndex {
    return [objc_getAssociatedObject(self, @selector(fileIndex)) integerValue];
}

- (void)setFileIndex:(NSUInteger)fileIndex {
    objc_setAssociatedObject(self, @selector(fileIndex), @(fileIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
