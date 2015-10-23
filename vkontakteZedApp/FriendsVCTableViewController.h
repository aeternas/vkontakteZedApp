//
//  FriendsVCTableViewController.h
//  vkontakteZedApp
//
//  Created by AIR on 22.10.15.
//  Copyright © 2015 Ivan Golikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VKSdk.h>

@interface FriendsVCTableViewController : UITableViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) VKRequest * friendsRequest;

@end
