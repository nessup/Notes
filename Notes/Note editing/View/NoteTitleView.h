//
//  NoteTitleView.h
//  Notes
//
//  Created by Dany on 6/19/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteTitleView : UIControl
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, weak) UINavigationItem *navigationItem;
@end
