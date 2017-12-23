//
//  ViewController.m
//  GroupManagement
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "ViewController.h"
#import <MASFoundation/MASFoundation.h>
#import <MASIdentityManagement/MASIdentityManagement.h>

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIButton *findButton;
@property (nonatomic, weak) IBOutlet UIImageView *userPhoto;
@property (nonatomic, weak) IBOutlet UITextField *searchText;
@property (nonatomic) MASUser *selectedUser;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Search User";
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButton:)];
    
    self.navigationItem.rightBarButtonItem = addButton;

}


#pragma mark - IBActions

- (IBAction)doneButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)findUser:(id)sender
{
    [self.searchText resignFirstResponder];
    
    //
    //Paging Range
    //
    NSRange range = NSMakeRange(1, 15);
    
    if ([MASUser resolveClassMethod:@selector(getUsersWithUsername:range:completion:)]) {
        
        NSLog(@"MASUser class has method getUsersWithUsername");
    }
    
    
    //
    //Find the User in LDAP
    //
//    [MASUser getUsersByFilteredRequest:MASFilteredRequestSortOrderAscending completion:^(NSArray *userList, NSError *error, NSUInteger totalResults) {
//        
//        if (!error) {
//            
//            NSLog(@"%@",userList);
//        }
//    }];
    
    [MASUser getUserByUserName:self.searchText.text completion:^(MASUser *user, NSError *error) {

//    }]
//    [MASUser getUsersWithUsername:self.searchText.text range:range completion:^(NSArray *userList, NSError *error, NSUInteger totalResults) {
//        
//        if ([userList count] > 0) {
//            
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //Get only the first item from the search result array
                weakSelf.selectedUser = user; //userList[0];
                
                //Display the user Photo on screen
                [weakSelf.userPhoto setImage:weakSelf.selectedUser.photos[@"thumbnail"]];
            });
//        }
    }];
}

- (IBAction)addMember:(id)sender
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
     __weak typeof(self) weakSelf = self;
    [self.selectedGroup addMember:self.selectedUser completion:^(MASGroup *group, NSError *error) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_MEMBER" object:weakSelf.selectedUser];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        
    }];
}

- (IBAction)getGroupByID:(id)sender
{
    [self.searchText resignFirstResponder];
    
    [MASGroup getGroupByObjectId:self.searchText.text completion:^(MASGroup *group, NSError *error) {
       
        if (!error) {
            
            NSLog(@"%@",group);
        }
    }];

//    [MASUser getAllUsersSortedByAttribute:@"username" sortOrder:MASFilteredRequestSortOrderAscending pageRange:NSMakeRange(1, 30) includedAttributes:nil excludedAttributes:nil completion:^(NSArray *userList, NSError *error, NSUInteger totalResults) {
//
//        if (!error) {
//
//            NSLog(@"%@",userList);
//        }
//
//    }];
    
}

- (IBAction)getGroupByName:(id)sender
{
    [self.searchText resignFirstResponder];

    NSRange defaultRange = NSMakeRange(1, 10);
    
//    [MASUser getAllUsersWithUsernameContaining:@"S" sortByAttribute:nil sortOrder:MASFilteredRequestSortOrderAscending pageRange:defaultRange includedAttributes:nil excludedAttributes:nil completion:^(NSArray *userList, NSError *error, NSUInteger totalResults) {
//
//        if (!error) {
//
//            NSLog(@"%@",userList);
//        }
//    }];
    
    [MASGroup getGroupByGroupName:self.searchText.text completion:^(MASGroup *group, NSError *error) {
        
        if (!error) {
            
            NSLog(@"%@",group);
        }
    }];
    
    
}
#pragma mark - DeRegister Device Method

- (IBAction)deRegisterDevice:(id)sender
{
    //
    //DeRegister Device. This is only used when the device needs to be registered under a different user.
    //
//    [MAS deregisterWithCompletion:^(BOOL completed, NSError *error) {
//        
//        NSLog(@"Device DeRegistered Successfully!");
//        __weak typeof(self) weakSelf = self;
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            UIAlertController * alert=   [UIAlertController
//                                          alertControllerWithTitle:@"Alert"
//                                          message:@"Device DeRegistered Successfully! \n Please relaunch the app!"
//                                          preferredStyle:UIAlertControllerStyleAlert];
//            
//            UIAlertAction* ok = [UIAlertAction
//                                 actionWithTitle:@"OK"
//                                 style:UIAlertActionStyleDefault
//                                 handler:^(UIAlertAction * action)
//                                 {
//                                     //Do some thing here
//                                     [alert dismissViewControllerAnimated:YES completion:nil];
//                                     
//                                 }];
//            
//            [alert addAction:ok]; // add action to uialertcontroller
//            
//            [weakSelf presentViewController:alert animated:YES completion:nil];
//        });
//        
//    }];
    
}


@end
