//
//  MessageTableViewCell.h
//  GroupManagement
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@import UIKit;
#import <MASConnecta/MASConnecta.h>


// Table view cell that displays a Message. The message text appears in a
// speech bubble; the sender name and date are shown in a UILabel below that.
@interface MessageTableViewCell : UITableViewCell

@property (nonatomic, assign) CGSize bubbleSize;

- (void)setMessage:(MASMessage *)message;

@end
