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

//инициализируем объект для управления получаемыми данными API, а также для взаимодействия с Core Data в оффлайне

@property (strong, nonatomic) FriendsLoader *loader;
@property (strong, nonatomic) NSArray *loadedFriends;

@end

@implementation FriendsVCTableViewController

-(void)setLoader:(FriendsLoader *)loader {
    _loader = loader;
    _loader.delegate = self;
}

//Core Data

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
    //как действовать – в онлайн или оффлайн-режиме
    if ([InternetChecker isConnection])
    {
        [self loadFriends];
    } else {
        [self loadSavedFriends];
    }
}

//действие по "потянуть вниз"

- (IBAction) loadFriendsOnline {
    
    if ([InternetChecker isConnection]) {
        
        [self.refreshControl beginRefreshing];
        [self loadFriends];
        
    } else {
        
        //алерт на случай, если нет подключения
        
        UIAlertController* offline = [UIAlertController alertControllerWithTitle:@"Please check internet connection." message:@"Can't update data" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [offline addAction:action];
        [self presentViewController:offline animated:YES completion:^{
            [UIView transitionWithView:offline.view duration:1.0 options:UIViewAnimationOptionTransitionNone animations:nil completion:nil];
        }];

        [self.refreshControl endRefreshing];
    }
}

- (void)fetchFriends {

    if (self.refreshControl.refreshing) {
        [self.refreshControl endRefreshing];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
    // Сохраняем CoreData для использования в оффлайне
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Friend"];
    NSError *error = nil;
    for (id friend in self.loader.friends) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"uid = %@",[friend objectForKey:@"uid"]];
        NSArray *matches = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (![matches count]) {
            Friend *friendCoreData = [NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:self.managedObjectContext];
            friendCoreData.firstName  = [friend objectForKey:@"first_name"];
            friendCoreData.lastName   = [friend objectForKey:@"last_name"];
            friendCoreData.uid        = [friend objectForKey:@"uid"];
            friendCoreData.sex        = [friend objectForKey:@"sex"];
            friendCoreData.avatar     = [friend objectForKey:@"photo_100"];
            friendCoreData.bdate      = [friend objectForKey:@"bdate"];
            friendCoreData.avatar     = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[friend objectForKey:@"photo_100"]]]];
        }
    }
    
    //сохраняем
    NSError *errorForSave = nil;
    if (![self.managedObjectContext save:&errorForSave]) {
        NSLog(@"%@", errorForSave);
    }
    
}

//запрос API

- (void) loadFriends {
    NSString *friendsRequest = [[NSString alloc] initWithString:[NSString stringWithFormat:@"https://api.vk.com/method/friends.get?user_id=%@&fields=photo_100,sex,bdate", [[VKSdk getAccessToken] userId]]];
    NSURL *friendsURL = [[NSURL alloc] initWithString:friendsRequest];
    self.loader = [[FriendsLoader alloc]initWithURL:friendsURL andKey:@"Friends"];
}

//загружаем сохранённые данные

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
            NSLog(@"%@", error);
        }
    }];
}

//переносим данные в массив

- (void)processAsyncFetchRequest:(NSAsynchronousFetchResult *)result
{
    if (result.finalResult) {
        self.loadedFriends = result.finalResult;
        [self.tableView reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//настройка таблицы для онлайн или оффлайн-режима соответственно

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
    
    //онлайн-режим
    
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
        
        //оффлайн-режим
        
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
        cell.detailTextLabel.text = @"You should load data at least once";
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
