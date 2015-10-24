//
//  FriendsFetcher.m
//  vkontakteZedApp
//
//  Created by AIR on 23.10.15.
//  Copyright © 2015 Ivan Golikov. All rights reserved.
//

//делегат для управления полученными через API данными

#import "FriendsLoader.h"

@implementation FriendsLoader

- (instancetype)initWithURL:(NSURL *)dataURL andKey:(NSString *)key

{
    self = [super init];
    if (self) {
        
        //настраиваем получение ответа API
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:
                                 [NSURLSessionConfiguration ephemeralSessionConfiguration]];
        NSURLSessionDataTask *jsonData = [session dataTaskWithURL:dataURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            self.friends = [[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] objectForKey:@"response"];
            if([self.delegate respondsToSelector:@selector(fetchFriends)]) {
                [self.delegate fetchFriends];
            }
        }];
        [jsonData resume];
    }
    return self;
}

@end
