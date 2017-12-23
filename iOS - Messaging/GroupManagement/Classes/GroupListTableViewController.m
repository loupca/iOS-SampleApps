//
//  GroupListTableViewController.m
//  GroupManagement
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "GroupListTableViewController.h"
#import <MASFoundation/MASFoundation.h>
#import <MASIdentityManagement/MASIdentityManagement.h>
#import "GroupDetailTableViewController.h"
#import "ListMessagesTableTableViewController.h"
#import <MASConnecta/MASConnecta.h>

static NSString *SampleUser = @"YOUR USERNAME";
static NSString *SampleUserPassword = @"YOUR PASSWORD";

@interface GroupListTableViewController ()

@property (nonatomic) NSMutableArray *groupList;
@property (nonatomic) UILabel *messageLabel;
@end

@implementation GroupListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addGroup)];

    self.navigationItem.rightBarButtonItem = addButton;

    self.navigationItem.title = @"Groups";
    
    self.groupList = [NSMutableArray array];
    
//    UIBarButtonItem *messageListButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(listMessages)];
//    
//    self.navigationItem.leftBarButtonItem = messageListButton;

    
    //
    // Initialize the refresh control.
    //
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor lightGrayColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshGroupList)
                  forControlEvents:UIControlEventValueChanged];
    
    
    //
    //Start the SDK
    //
    __block typeof(self) blockSelf = self;
    [MAS startWithDefaultConfiguration:YES completion:^(BOOL completed, NSError *error) {
        
        if (completed) {
            
            //
            // Login User
            //
            [MASUser loginWithUserName:SampleUser password:SampleUserPassword completion:^(BOOL completed, NSError *error) {
                
                [[MASUser currentUser] startListeningToMyMessages:nil];
                
                [self refreshGroupList];
                
            }];
        }
        else {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"MAS.start Error"
                                                                                     message:[error localizedDescription]
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:nil];
            [alertController addAction:defaultAction];
            
            
            UIAlertAction *wipeAction = [UIAlertAction actionWithTitle:@"Wipe local cache"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action)
                                         {
                                             [[MASDevice currentDevice] resetLocally];
                                         }];
            
            [alertController addAction:wipeAction];
            
            [blockSelf presentViewController:alertController animated:YES completion:nil];
        }
    }];


}


- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //
    // Validate if there is any group in the array
    //
    if ([self.groupList count] > 0) {
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
        
    } else {
      
        //
        // Display a message when the table is empty
        //
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        self.messageLabel.text = @"No data is currently available. Please pull down to refresh.";
        self.messageLabel.textColor = [UIColor blackColor];
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        self.messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [self.messageLabel sizeToFit];
        [self.messageLabel setHidden:NO];
        self.tableView.backgroundView = self.messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.groupList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"GROUP_IDENTIFIER";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [[self.groupList objectAtIndex:indexPath.row] groupName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - ID (%@)",[[self.groupList objectAtIndex:indexPath.row] owner], [[self.groupList objectAtIndex:indexPath.row] objectId]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

//
// Override to support conditional editing of the table view.
//
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


//
// Override to support editing the table view.
//
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        MASGroup *selectedGroup = [self.groupList objectAtIndex:indexPath.row];
        __block typeof(self) blockSelf = self;
        [selectedGroup deleteInBackgroundWithCompletion:^(BOOL success, NSError *error) {
            
            if (!error) {
                
                [blockSelf.groupList removeObjectAtIndex:indexPath.row];
                
                if ([blockSelf.groupList count] == 0) {
                    
                    [tableView reloadData];
                }
                else {
                    
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                }
            }

            else {
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Failure"
                                                                               message:[error localizedDescription]
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {}];
                
                [alert addAction:defaultAction];
                
                [blockSelf presentViewController:alert animated:YES completion:nil];
            }

        }];        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"GroupDetailSegue" sender:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ListMessagesSegue"])
    {
//        NSIndexPath *index = [self.tableView indexPathForSelectedRow];
        UINavigationController *navigationVC = [segue destinationViewController];
        ListMessagesTableTableViewController *listMessagesTVC = navigationVC.viewControllers[0];
//        composeVC.selectedUser = [self.membersList objectAtIndex:index.row];
    }
    else if ([segue.identifier isEqualToString:@"GroupDetailSegue"]) {
        
        NSIndexPath *index = [self.tableView indexPathForSelectedRow];
        GroupDetailTableViewController *groupDetailViewController = [segue destinationViewController];
        groupDetailViewController.selectedGroup = self.groupList[index.row];
    }
}


#pragma mark - Methods

- (void)addGroup
{
    __block typeof(self) blockSelf = self;

    MASGroup *newGroup = [MASGroup group];

    if ([self.groupList count] > 0) {
        
        newGroup.groupName = [NSString stringWithFormat:@"New Group #%d",(int)[self.groupList count] +1];
        
        newGroup.owner = SampleUser;
        
        [newGroup saveInBackgroundWithCompletion:^(MASGroup *group, NSError *error) {
            
            if (!error) {
                
                [blockSelf refreshGroupList];
            }
            else {
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Failure"
                                                                               message:[error localizedDescription]
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {}];
                
                [alert addAction:defaultAction];
                
                [blockSelf presentViewController:alert animated:YES completion:nil];
            }
        }];
    }
    else {
        
        newGroup.groupName = @"New Group #1";
        
        newGroup.owner = SampleUser;
        
        [newGroup saveInBackgroundWithCompletion:^(MASGroup *group, NSError *error) {
            
            if (!error) {
                
                [blockSelf refreshGroupList];
            }
            else {
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Failure"
                                                                               message:[error localizedDescription]
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {}];
                
                [alert addAction:defaultAction];
                
                [blockSelf presentViewController:alert animated:YES completion:nil];
            }
        }];
        
    }
}

- (void)listMessages
{
    [self performSegueWithIdentifier:@"ListMessagesSegue" sender:self];
}

- (void)refreshGroupList
{
    __block typeof(self) blockSelf = self;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
    
//    MASFilteredRequest *request = [MASFilteredRequest filteredRequest];
//    [request setSortOrder:MASFilteredRequestSortOrderAscending];
//    [request setSortByAttribute:@"displayName"];
//    MASFilter *myFilter = [MASFilter filterByAttribute:@"owner.value" equalTo:@"awilliams"];
//    [request setFilter:myFilter];
//    
//    [MASGroup getGroupsByFilteredRequest:request completion:^(NSArray *groupList, NSError *error, NSUInteger totalResults) {

    
    //
    //List all Groups
    //
    [MASGroup getAllGroupsWithCompletion:^(NSArray *groupList, NSError *error, NSUInteger totalResults) {
    
        if (!error) {
            
            NSMutableArray *newGroupList = [[NSMutableArray alloc] initWithArray:groupList];
            
            [blockSelf setGroupList:newGroupList];
            
            [blockSelf.messageLabel setHidden:YES];
            
            [blockSelf.tableView reloadData];
            
            // End the refreshing
            if (blockSelf.refreshControl) {
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"MMM d, h:mm a"];
                NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
                NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                            forKey:NSForegroundColorAttributeName];
                NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
                blockSelf.refreshControl.attributedTitle = attributedTitle;
            }
        }
        else {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Failure"
                                                                           message:[error localizedDescription]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            
            [blockSelf presentViewController:alert animated:YES completion:nil];
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
        
        [blockSelf.refreshControl endRefreshing];
    }];
}


- (void)listAllGroups
{
    [MASGroup getAllGroupsWithCompletion:^(NSArray *groupList, NSError *error, NSUInteger totalResults) {
       
    }];
}



@end
