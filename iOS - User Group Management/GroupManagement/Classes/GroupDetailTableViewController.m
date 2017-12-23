//
//  GroupDetailTableViewController.m
//  GroupManagement
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "GroupDetailTableViewController.h"
#import <MASIdentityManagement/MASIdentityManagement.h>
#import "ViewController.h"

@interface GroupDetailTableViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *ownerPhoto;
@property (nonatomic) NSMutableArray *membersList;
@property (nonatomic) MASUser *groupOwner;


@end

@implementation GroupDetailTableViewController
@synthesize selectedGroup;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMember)];
    
    self.navigationItem.rightBarButtonItem = addButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshMembers:)
                                                 name:@"NEW_MEMBER"
                                               object:nil];

    self.membersList = [[NSMutableArray alloc] init];
    
    self.navigationItem.title = self.selectedGroup.groupName;
    
    if ([self.selectedGroup.members count] > 0) {
        
        [self fetchGroupMembers];
    }
    
    [self fetchGroupOwner];
    
    [self getGroupByName];
    
    NSLog(@"%@",self.selectedGroup);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.membersList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MEMBER_IDENTIFIER";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    MASUser *user = [self.membersList objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [user objectForKey:@"displayName"]; //[NSString stringWithFormat:@"%@ %@",user.givenName, user.familyName];
    cell.imageView.image = user.photos[@"thumbnail"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        MASUser *selectedMember = [self.membersList objectAtIndex:indexPath.row];
        __block typeof(self) blockSelf = self;
        [self.selectedGroup removeMember:selectedMember completion:^(MASGroup *group, NSError *error) {

            if (!error) {
                
                [blockSelf.membersList removeObjectAtIndex:indexPath.row];

                if ([blockSelf.membersList count] == 0) {
                    
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


#pragma mark - Methods

- (IBAction)updateGroupName:(id)sender
{
    __block typeof(self) blockSelf = self;
    
    self.selectedGroup.groupName = [NSString stringWithFormat:@"%@-OK",self.selectedGroup.groupName];
    
    [self.selectedGroup saveInBackgroundWithCompletion:^(MASGroup *group, NSError *error) {

        if (!error) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                           message:@"Group Name updated. Go back and refresh"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            
            [blockSelf presentViewController:alert animated:YES completion:nil];
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

- (void)addMember
{
    [self performSegueWithIdentifier:@"FindUserSegue" sender:self];
    
//    if ([self.selectedGroup.owner isEqualToString:[MASUser currentUser].objectId]) {
//        
//        [self performSegueWithIdentifier:@"FindUserSegue" sender:self];
//    }
//    else {
//        
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Failure"
//                                                                       message:@"Restrict to Group Owner only!"
//                                                                preferredStyle:UIAlertControllerStyleAlert];
//                                    
//        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
//                                                                style:UIAlertActionStyleDefault
//                                                              handler:^(UIAlertAction * action) {}];
//        
//        [alert addAction:defaultAction];
//        
//        [self presentViewController:alert animated:YES completion:nil];
//    }
}

- (void)fetchGroupMembers
{
    
    for (NSDictionary *userDic in self.selectedGroup.members) {
        
        //
        //Find the User in LDAP
        //
        __weak typeof(self) weakSelf = self;
        [MASUser getUserByObjectId:[userDic valueForKey:@"value"] completion:^(MASUser *user, NSError *error) {
            
            if (!error) {

                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

                [weakSelf.tableView beginUpdates];
                [weakSelf.membersList insertObject:user atIndex:0];
                [weakSelf.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [weakSelf.tableView endUpdates];
            }
        }];
    }
    
}

- (void)fetchGroupOwner
{
    //
    //Find the User in LDAP
    //
    __weak typeof(self) weakSelf = self;
//    [MASUser getUserByObjectId:self.selectedGroup.owner completion:^(MASUser *user, NSError *error) {
//        
//        if (!error) {
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                //Display the user Photo on screen
//                [weakSelf.ownerPhoto setImage:user.photos[@"thumbnail"]];
//                weakSelf.ownerPhoto.layer.cornerRadius = weakSelf.ownerPhoto.frame.size.width/2;
//                weakSelf.ownerPhoto.layer.masksToBounds = YES;
//
//            });
//        }
//    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UINavigationController *navigation = [segue destinationViewController];
    ViewController *findUserViewController = navigation.viewControllers[0];
    findUserViewController.selectedGroup = self.selectedGroup;
}


#pragma mark - Notifications

- (void)refreshMembers:(NSNotification *)notification
{
    __weak typeof(self) weakSelf = self;
    
    MASUser *addedUser = [notification valueForKey:@"object"];
    for (MASUser *user in self.membersList) {
        
        if ([user.userName isEqualToString:addedUser.userName] ) {

            return;
            break;
        }
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    int64_t delayInSeconds = 1.4;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        
        [weakSelf.tableView beginUpdates];
        [weakSelf.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [weakSelf.membersList insertObject:[notification valueForKey:@"object"] atIndex:0];
        [weakSelf.tableView endUpdates];
    });
}

- (void)getGroupByName
{
    NSRange range = NSMakeRange(NSNotFound, NSNotFound);
    [MASGroup getGroupByObjectId:self.selectedGroup.objectId completion:^(MASGroup *group, NSError *error) {

        NSLog(@"Testing ByID");
    }];
    
//    [MASGroup getGroupsWithMember:[MASUser currentUser] range:range completion:^(NSArray *groupList, NSError *error, NSUInteger totalResults) {
//        
//        NSLog(@"testing");
//
//    }];
}


- (void)groupDetails
{
    [MASGroup getGroupByObjectId:self.selectedGroup.objectId completion:^(MASGroup *group, NSError *error) {
        
    }];
}

- (void)ownerGroup
{
    [MASUser getUserByUserName:self.selectedGroup.owner completion:^(MASUser *user, NSError *error) {
        
        [self.selectedGroup addMember:user completion:^(MASGroup *group, NSError *error) {
           
        }];
        
        
    }];
}

@end
