//
//  Utility.m
//  Notes
//
//  Created by Dany on 5/31/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "Utility.h"

NSURL *
ApplicationDocumentsDirectory()
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
