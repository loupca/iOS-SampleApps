//
//  AppDelegate.m
//  GroupManagement
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "AppDelegate.h"
#import <MASFoundation/MASFoundation.h>
#import <MASConnecta/MASConnecta.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageReceivedNotification:)
                                                 name:MASConnectaMessageReceivedNotification
                                               object:nil];

    return YES;
    

}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    //
    //  Handle incoming authorization code response from SFSafariViewController
    //
    [[MASAuthorizationResponse sharedInstance] application:app openURL:url options:options];
    return YES;
}

- (void)sendMessage
{
    MASUser *myUser = [MASUser currentUser];
    
    [myUser sendMessage:@"Hello" toUser:myUser completion:nil];
}


- (void)messageReceivedNotification:(NSNotification *)notification
{
    MASMessage *myMessage = notification.userInfo[MASConnectaMessageKey];
    
}

@end
