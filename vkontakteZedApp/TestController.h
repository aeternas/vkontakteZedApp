//
//  TestController.h
//  vkontakteZedApp
//
//  Created by AIR on 16.10.15.
//  Copyright © 2015 Ivan Golikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VKSdk.h>

@interface TestController : UIViewController

@property (nonatomic,strong) IBOutlet UILabel *methodName;

@property (nonatomic, strong) IBOutlet UITextView *callResult;

@property (nonatomic, strong) VKRequest * callingRequest;

@end
