//
//  ComposeViewController.h
//  GroupManagement
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <UIKit/UIKit.h>

@class ComposeViewController;
//@class Message;

#import <MASFoundation/MASFoundation.h>
#import <MASConnecta/MASConnecta.h>

// The delegate protocol for the Compose screen
@protocol ComposeDelegate <NSObject>
- (void)didSaveMessage:(MASMessage*)message atIndex:(int)index;
@end

// The Compose screen lets the user write a new message
@interface ComposeViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, assign) id<ComposeDelegate> delegate;
@property (nonatomic, assign) NSMutableArray* dataModel;
@property (nonatomic, strong) MASUser *user;
@property (nonatomic, strong) MASUser *selectedUser;
@property (nonatomic, strong) NSString *userName;
@end
