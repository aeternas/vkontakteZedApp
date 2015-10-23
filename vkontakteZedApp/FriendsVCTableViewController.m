//
//  FriendsVCTableViewController.m
//  vkontakteZedApp
//
//  Created by AIR on 22.10.15.
//  Copyright © 2015 Ivan Golikov. All rights reserved.
//

#import "FriendsVCTableViewController.h"
#import <VKSdk.h>
#import "Friend.h"

@interface FriendsVCTableViewController ()

@property (strong, nonatomic) NSArray *loadedFriends;

@end

@implementation FriendsVCTableViewController

static NSString *const ALL_USER_FIELDS = @"first_name, last_name, sex, bdate, photo_50";

-(NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES];
    [self fetchFriends];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchFriends {
    self.friendsRequest = [[VKApi friends] get:@{VK_API_FIELDS : ALL_USER_FIELDS}];
    [self.friendsRequest executeWithResultBlock: ^(VKResponse *response) {
        Friend *friendCD = [NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:self.managedObjectContext];
        NSInteger count = ((NSString *) response.json[@"count"]).intValue;
        NSMutableArray *firstNameArray = [NSMutableArray new];
        NSMutableArray *lastNameArray = [NSMutableArray new];
        NSMutableArray *sexArray = [NSMutableArray new];
        NSMutableArray *bdateArray = [NSMutableArray new];
        NSMutableArray *avatarArray = [NSMutableArray new];
        for (int i = 0; i < count; i++) {
            [firstNameArray addObject:response.json[@"items"][i][@"first_name"]];
            [lastNameArray addObject:response.json[@"items"][i][@"last_name"]];
//            [sexArray addObject:response.json[@"items"][i][@"sex"]];
//            [bdateArray addObject:response.json[@"items"][i][@"bdate"]];
//            [avatarArray addObject:response.json[@"items"][i][@"photo_50"]];
//            friendCD.firstName = [firstNameArray objectAtIndex:i];
//            friendCD.lastName = [lastNameArray objectAtIndex:i];
//            friendCD.sex = [sexArray objectAtIndex:i];
//            friendCD.bdate = [bdateArray objectAtIndex:i];
//            friendCD.avatar = [avatarArray objectAtIndex:i];
        }
        self.friendsRequest = nil;
        NSLog(@"%@", response.request.requestTiming);
    } errorBlock: ^(NSError *error) {
        self.friendsRequest = nil;
    }];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
