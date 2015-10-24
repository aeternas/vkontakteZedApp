//
//  FriendsVCTableViewController.m
//  vkontakteZedApp
//
//  Created by AIR on 22.10.15.
//  Copyright © 2015 Ivan Golikov. All rights reserved.
//

#import "FriendsVCTableViewController.h"
#import <VKSdk.h>
#import "FriendsLoader.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Friend.h"

@interface FriendsVCTableViewController () <FriendsLoaderDelegate>

@property (strong, nonatomic) FriendsLoader *loader;

@property (strong, nonatomic) NSMutableArray *loadedFriends;

@end

@implementation FriendsVCTableViewController

static NSString *const ALL_USER_FIELDS = @"first_name, last_name, sex, bdate, photo_50";

-(void)setLoader:(FriendsLoader *)loader {
    _loader = loader;
    _loader.delegate = self;
}

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
    [self loadFriends];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (IBAction) loadFriendsOnline {
    
    [self.refreshControl beginRefreshing];
    [self loadFriends];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadFriends {
    NSString *friendsRequest = [[NSString alloc] initWithString:[NSString stringWithFormat:@"https://api.vk.com/method/friends.get?user_id=%@&fields=photo_100", [[VKSdk getAccessToken] userId]]];
    NSURL *friendsURL = [[NSURL alloc] initWithString:friendsRequest];
    self.loader = [[FriendsLoader alloc]initWithURL:friendsURL andKey:@"Friends"];
}

- (void)fetchFriends {

    if (self.refreshControl.refreshing) {
        [self.refreshControl endRefreshing];
    }
    // Because of NSURLSession
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
    // Saving CoreData
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Friend"];
    NSError *error = nil;
    //@autoreleasepool {
    for (id friend in self.loader.friends) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"uid = %@",[friend objectForKey:@"uid"]];
        NSArray *matches = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (![matches count]) {
            NSLog(@"TEST MSG: New friend has been added");
            Friend *friendCD   = [NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:self.managedObjectContext];
            friendCD.firstName = [friend objectForKey:@"first_name"];
            friendCD.lastName = [friend objectForKey:@"last_name"];
            friendCD.uid = [friend objectForKey:@"uid"];
            friendCD.sex = [friend objectForKey:@"sex"];
            friendCD.avatar = [friend objectForKey:@"photo_100"];
            NSLog(@"%@", friendCD.sex);
//            friendCD.avatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[friend objectForKey:@"photo_100"]]]];
        }
    }
    //}
    // Saving Context
    NSError *errorForSave = nil;
    if (![self.managedObjectContext save:&errorForSave]) {
        NSLog(@"Unable to save Friends.");
        NSLog(@"%@", errorForSave);
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.loader.friends count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendsCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"friendsCell"];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",[[self.loader.friends objectAtIndex:indexPath.row] objectForKey:@"first_name"], [[self.loader.friends objectAtIndex:indexPath.row] objectForKey:@"last_name"]];
    
    
    
    cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[self.loader.friends objectAtIndex:indexPath.row] objectForKey:@"photo_100"]]]]];
    
    // Configure the cell...
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}


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
