//
//  ChatViewController.h
//  GroupManagement
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@import UIKit;

#import <MASConnecta/MASConnecta.h>
#import "ComposeViewController.h"

@interface ChatViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, ComposeDelegate>

@property (nonatomic, strong) NSMutableArray* dataModel;
@property (nonatomic, strong) MASUser *user;
@property (nonatomic, strong) MASUser *selectedUser;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, assign) CGSize bubbleSize;

@end
