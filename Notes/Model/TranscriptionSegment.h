//
//  TranscriptionSegment.h
//  Notes
//
//  Created by Dany on 7/3/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Note;

@interface TranscriptionSegment : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * absoluteStartTime;
@property (nonatomic, retain) NSNumber * absoluteEndTime;
@property (nonatomic, retain) Note *note;
@property (nonatomic, retain) NSString * soundFilePath;

@end
