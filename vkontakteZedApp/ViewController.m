//
//  ViewController.m
//  vkontakteZedApp
//
//  Created by AIR on 15.10.15.
//  Copyright © 2015 Ivan Golikov. All rights reserved.
//

#import "ViewController.h"
#import <VKSdk.h>

static NSString *const TOKEN_KEY = @"hJtexe8Ma9aVdh6nFCAw";
static NSString *const NEXT_CONTROLLER_SEGUE_ID = @"START";
static NSArray  * SCOPE = nil;

@interface ViewController () <UIAlertViewDelegate>

@end

@implementation ViewController


- (void)viewDidLoad {
    SCOPE = @[VK_PER_FRIENDS, VK_PER_WALL, VK_PER_AUDIO, VK_PER_PHOTOS, VK_PER_NOHTTPS, VK_PER_EMAIL, VK_PER_MESSAGES];
    [super viewDidLoad];
    [VKSdk initializeWithDelegate:self andAppId:@"5082054"];
    if ([VKSdk wakeUpSession])
    {
        //Start working
        [self startWorking];
    }
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)startWorking {
    [self performSegueWithIdentifier:@"START" sender:self];
}

- (IBAction)authorize:(id)sender {
    [VKSdk authorize:SCOPE];
}

-(void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Acces denied" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle: @"Dismiss"
                                                          style: UIAlertActionStyleDestructive
                                                        handler: ^(UIAlertAction *action) {
                                                            NSLog(@"Dismiss button tapped!");
                                                        }];
    
    [alertController addAction: alertAction];
    
    [self presentViewController: alertController animated: YES completion: nil];
}

-(void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    [self authorize:nil];
}

-(void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:self.navigationController.topViewController];
}

-(void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [self.navigationController.topViewController presentViewController:controller animated:YES completion:nil];
}

-(void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
    [self startWorking];
}

@end
