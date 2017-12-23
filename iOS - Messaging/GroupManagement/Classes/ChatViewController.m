//
//  ChatViewController.m
//  GroupManagement
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "ChatViewController.h"
#import "MessageTableViewCell.h"
#import "SpeechBubbleView.h"

@interface ChatViewController ()

@property (nonatomic) NSMutableArray *chatHistory;

@end

@implementation ChatViewController

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self) {

        self.dataModel = [[NSMutableArray alloc] init];
        self.chatHistory = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.selectedUser.formattedName;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageReceivedNotification:)
                                                 name:MASConnectaMessageReceivedNotification
                                               object:nil];
    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reconnect:)
                                                 name:MASGatewayMonitorStatusUpdateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reconnect:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    __weak typeof(self) weakSelf = self;
    NSString *tag = [NSString stringWithFormat:@"%@%@",self.selectedUser.userName,self.user.userName];
//    [MASSecureStorage findObjectsFromLocalStorageUsingTag:tag completion:^(NSArray *objects, NSError *error) {
//       
//        for (NSDictionary *dic in objects) {
//            
//            Message *message = [dic objectForKey:@"MESSAGE"];
//            [weakSelf.dataModel addObject:message];
//        }
//        
//    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Show a label in the table's footer if there are no messages
    if (self.dataModel.count == 0)
    {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
        label.text = NSLocalizedString(@"You have no messages", nil);
        label.font = [UIFont boldSystemFontOfSize:16.0f];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithRed:76.0f/255.0f green:86.0f/255.0f blue:108.0f/255.0f alpha:1.0f];
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0.0f, 1.0f);
        label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        self.tableView.tableFooterView = label;
    }
    else
    {
        [self scrollToNewestMessage];
    }
}

- (void)scrollToNewestMessage
{
    // The newest message is at the bottom of the table
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(self.dataModel.count - 1) inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark ComposeDelegate

- (void)didSaveMessage:(MASMessage *)message atIndex:(int)index
{
    if ([self isViewLoaded])
    {
        self.tableView.tableFooterView = nil;
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self scrollToNewestMessage];
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataModel.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"MessageCellIdentifier";
    
    MessageTableViewCell* cell = (MessageTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
     
        cell = [[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    MASMessage* message = (self.dataModel)[indexPath.row];
    [cell setMessage:message];
    return cell;
}

#pragma mark -
#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    MASMessage* message = (self.dataModel)[indexPath.row];
    self.bubbleSize = [SpeechBubbleView sizeForText:message.payloadTypeAsString];
    return self.bubbleSize.height + 16;
}

#pragma mark - UI Events

- (IBAction)backButton:(id)sender
{
    [self performSegueWithIdentifier:@"UnWindToContactsViewControllerSegue" sender:self];
}

- (IBAction)composeAction
{
    [self performSegueWithIdentifier:@"ComposeSegueIdentifier" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ComposeSegueIdentifier"])
    {
        UINavigationController *navigationVC = [segue destinationViewController];
        ComposeViewController *composeVC = navigationVC.viewControllers[0];
        composeVC.delegate = self;
        composeVC.user = self.user;
        composeVC.selectedUser = self.selectedUser;
        composeVC.dataModel = self.dataModel;
    }
}

#pragma mark - Notifications

- (void)reconnect:(NSNotification *)notification
{
    [self.user startListeningToMyMessages:nil];
}

- (void)messageReceivedNotification:(NSNotification *)notification
{
    //
    //Get the Message Object from the notification
    //
    __block typeof(self) blockSelf = self;
    MASMQTTMessage *myMessage;
    if ([notification.object isKindOfClass:[MASMQTTMessage class]]) {
        
        myMessage = notification.object;
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            MASMessage *myMessage = notification.userInfo[MASConnectaMessageKey];
            
            if ([myMessage.senderObjectId isEqualToString:blockSelf.selectedUser.objectId]) {

                [blockSelf.dataModel addObject:myMessage];
                int index = (int)(blockSelf.dataModel.count -1);
                
                [blockSelf didSaveMessage:myMessage atIndex:index];
            }
        });
    }
}


@end
