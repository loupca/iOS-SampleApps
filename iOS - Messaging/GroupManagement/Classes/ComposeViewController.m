//
//  ComposeViewController.m
//  GroupManagement
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "ComposeViewController.h"

@interface ComposeViewController ()

@property (nonatomic, retain) IBOutlet UITextView* messageTextView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* saveItem;
@property (nonatomic, retain) IBOutlet UINavigationBar* navigationBar;

@end

@implementation ComposeViewController
@synthesize selectedUser,user;

- (void)viewDidLoad
{
	[super viewDidLoad];
    
//    //
//    //Receive Messages' Notifications from SDK
//    //
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(didReceiveMessageNotification:)
//                                                 name:MASConnectaMessageReceivedNotification
//                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
	[_messageTextView becomeFirstResponder];
    

}

#pragma mark - UI Events

- (IBAction)cancelAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveAction
{
    [self postMessageRequest];
}

#pragma mark - Post message methods

- (void)userDidCompose:(NSString*)text
{
    //
	// Create a new Message object
    //
    __block MASMessage *message = [[MASMessage alloc] initWithPayloadString:text contentType:@"text/plain"];
    __block typeof(self) blockSelf = self;
    
    [[MASUser currentUser] sendMessage:message toUser:self.selectedUser completion:^(BOOL success, NSError * _Nullable error) {
       
        //
        // Add the Message to the data model's list of messages
        //
        [blockSelf.dataModel addObject:message];
        int index = (int)(blockSelf.dataModel.count -1);
        
        //
        // Add a row for the Message to ChatViewController's table view.
        //
        [blockSelf.delegate didSaveMessage:message atIndex:index];
        
        //
        // Close the Compose screen
        //
        [blockSelf dismissViewControllerAnimated:YES completion:nil];

    }];
}

- (void)postMessageRequest
{
    [_messageTextView resignFirstResponder];
    
    NSString* text = self.messageTextView.text;

//    [self.user sendMessage:text toUser:self.selectedUser completion:nil];
    
    [self userDidCompose:text];
}

//- (void)saveToLocalStorageMessage:(MASMessage *)message
//{
//    //
//    //Save the message in the LocalStorage
//    //
////    [MASSecureStorage saveToLocalStorageObject:message withKey:self.user.userName andType:[NSString stringWithFormat:@"%@%@",self.selectedUser.userName,self.user.userName] completion:^(BOOL success, NSError *error) {
////        
////        
////    }];
//}


//#pragma mark - Notifications
//
//- (void)didReceiveMessageNotification:(NSNotification *)notification
//{
//    //
//    //Get the Message Object from the notification
//    //
//    __weak typeof(self) weakSelf = self;
//    MASMQTTMessage *myMessage;
//    if ([notification.object isKindOfClass:[MASMQTTMessage class]]) {
//        
//        myMessage = notification.object;
//    }
//    else {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            MASMessage *myMessage = notification.userInfo[MASConnectaMessageKey];
//            NSLog(@"here");
////            [weakSelf.profileImage setImage:myMessage.payloadTypeAsImage];
////            [weakSelf.messagePayload setText:myMessage.payloadTypeAsString];
//        });
//    }
//}


@end
