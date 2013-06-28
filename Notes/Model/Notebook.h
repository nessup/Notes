//
//  Course.h
//  Notes
//
//  Created by Dany on 5/23/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Notebook : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSArray *notes;
@property (nonatomic, retain) NSString *defaultUserName;
@property (nonatomic, retain) UIColor *color;
@property (nonatomic, retain) NSDate *dateCreated;

@end
