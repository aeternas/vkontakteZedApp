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
#import "Friend.h"
#import "InternetChecker.h"

@interface FriendsVCTableViewController () <FriendsLoaderDelegate>

@property (strong, nonatomic) FriendsLoader *loader;
@property (strong, nonatomic) NSArray *loadedFriends;

@end

@implementation FriendsVCTableViewController

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
    if ([InternetChecker isConnection])
    {
        [self loadFriends];
    } else {
        [self loadSavedFriends];
    }
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (IBAction) loadFriendsOnline {
    
    if ([InternetChecker isConnection]) {
        
        [self.refreshControl beginRefreshing];
        [self loadFriends];
        
    } else {
        UIAlertController* offline = [UIAlertController alertControllerWithTitle:@"Please check internet connection." message:@"Can't update data" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [offline addAction:action];
        [self presentViewController:offline animated:YES completion:^{
            [UIView transitionWithView:offline.view duration:1.0 options:UIViewAnimationOptionTransitionFlipFromTop animations:nil completion:nil];
        }];

        [self.refreshControl endRefreshing];
    }
    
//    [self loadSavedFriends];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
//            NSLog(@"TEST MSG: New friend has been added");
            Friend *friendCD   = [NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:self.managedObjectContext];
            friendCD.firstName = [friend objectForKey:@"first_name"];
            friendCD.lastName = [friend objectForKey:@"last_name"];
            friendCD.uid = [friend objectForKey:@"uid"];
            friendCD.sex = [friend objectForKey:@"sex"];
            friendCD.avatar = [friend objectForKey:@"photo_100"];
            friendCD.bdate = [friend objectForKey:@"bdate"];
            friendCD.avatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[friend objectForKey:@"photo_100"]]]];
        }
    }
    //}
    // Saving Context
    NSError *errorForSave = nil;
    if (![self.managedObjectContext save:&errorForSave]) {
        NSLog(@"Friends have not been saved");
        NSLog(@"%@", errorForSave);
    }
    
}

- (void) loadFriends {
    NSString *friendsRequest = [[NSString alloc] initWithString:[NSString stringWithFormat:@"https://api.vk.com/method/friends.get?user_id=%@&fields=photo_100,sex,bdate", [[VKSdk getAccessToken] userId]]];
    NSURL *friendsURL = [[NSURL alloc] initWithString:friendsRequest];
    self.loader = [[FriendsLoader alloc]initWithURL:friendsURL andKey:@"Friends"];
}


- (void)loadSavedFriends
{
    __weak FriendsVCTableViewController *weakSelf = self;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Friend"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]];
    NSAsynchronousFetchRequest *asyncFetchRequest = [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:fetchRequest completionBlock:^(NSAsynchronousFetchResult *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf processAsyncFetchRequest:result];
        });
    }];
    [self.managedObjectContext performBlock:^{
        NSError *error = nil;
        NSAsynchronousFetchResult *asyncFetchResult = (NSAsynchronousFetchResult *)[weakSelf.managedObjectContext executeRequest:asyncFetchRequest error:&error];
        if (error) {
            NSLog(@"Unable to execute asynchronous fetch result.");
            NSLog(@"%@", error);
        }
    }];
}

- (void)processAsyncFetchRequest:(NSAsynchronousFetchResult *)result
{
    if (result.finalResult) {
        self.loadedFriends = result.finalResult;
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self.loader.friends count]) {
        
       return [self.loader.friends count];
        
    } else if ([self.loadedFriends count]) {
        
        return [self.loadedFriends count];
        
    } else {
        
        return  1;
        
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"friendsCell" forIndexPath:indexPath];
    
    NSDictionary *sexDict = @{@0: @"Unknown", @1 : @"Female", @2 : @"Male"};
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"friendsCell"];
    }
    
    if ([self.loader.friends count]) {
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",[[self.loader.friends objectAtIndex:indexPath.row] objectForKey:@"first_name"], [[self.loader.friends objectAtIndex:indexPath.row] objectForKey:@"last_name"]];
    
    NSString *dateString = [[self.loader.friends objectAtIndex:indexPath.row] objectForKey:@"bdate"];
        
    if (!dateString) {
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [sexDict objectForKey:[[self.loader.friends objectAtIndex:indexPath.row] objectForKey:@"sex"]]];
        
    } else {
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, DOB: %@", [sexDict objectForKey:[[self.loader.friends objectAtIndex:indexPath.row] objectForKey:@"sex"]], [[self.loader.friends objectAtIndex:indexPath.row] objectForKey:@"bdate"]];
        
    }
    
    cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[self.loader.friends objectAtIndex:indexPath.row] objectForKey:@"photo_100"]]]]];
        
    } else if ([self.loadedFriends count]) {
        
        Friend *friend = [self.loadedFriends objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", friend.firstName, friend.lastName];
        
        NSString *dateString = friend.bdate;
        
        if (!dateString) {
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [sexDict objectForKey:friend.sex]];
            
        } else {
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, DOB: %@", [sexDict objectForKey:friend.sex], friend.bdate];
            
        }
        
        cell.imageView.image = friend.avatar;
        
    } else {
        cell.textLabel.text = @"No data";
    }
//     Configure the cell...
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

@end
