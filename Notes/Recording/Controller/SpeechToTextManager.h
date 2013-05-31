//
//  SpeechToTextManager.h
//  Notes
//
//  Created by Dany on 5/29/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpeechToTextManager : NSObject

+ (SpeechToTextManager *)sharedInstance;

- (void)getText:(void (^)(NSString *))completion;
- (BOOL)convertWAV:(NSString *)wavPath toFLAC:(NSString *)flacPath;

@end
