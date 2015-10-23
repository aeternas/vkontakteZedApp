//
//  TestController.m
//  vkontakteZedApp
//
//  Created by AIR on 16.10.15.
//  Copyright © 2015 Ivan Golikov. All rights reserved.
//

#import "TestController.h"
#import <VKSdk.h>

@interface TestController ()

@end

@implementation TestController

//static NSString *const ALL_USER_FIELDS = @"first_name,last_name,sex,bdate,photo_50";
static NSString *const ALL_USER_FIELDS = @"first_name";
- (void)viewDidLoad {
    [super viewDidLoad];
//    self.callingRequest = [[VKApi friends] get:@{ VK_API_FIELDS : ALL_USER_FIELDS}];
    NSMutableArray *myArray = [NSMutableArray new];
    self.callingRequest = [[VKApi friends] get:@{VK_API_FIELDS : ALL_USER_FIELDS}];
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:self action:@selector(logout:)];
    self.methodName.text = self.callingRequest.methodName;
    self.callingRequest.debugTiming = YES;
    self.callingRequest.requestTimeout = 10;
    [self.callingRequest executeWithResultBlock: ^(VKResponse *response) {
        self.callResult.text = [NSString stringWithFormat:@"Result: %@", response];
        NSInteger count = ((NSString *) response.json[@"count"]).intValue;
        for (int i = 0; i < count; i++) {
            [myArray addObject:response.json[@"items"][i][@"first_name"]];
        }
        NSLog(myArray.description);
        self.callingRequest = nil;
        NSLog(@"%@", response.request.requestTiming);
    } errorBlock: ^(NSError *error) {
        self.callResult.text = [NSString stringWithFormat:@"Error: %@", error];
        self.callingRequest = nil;
    }];

}

- (void) logout:(id) sender {
    [VKSdk forceLogout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
