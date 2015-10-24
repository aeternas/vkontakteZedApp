//
//  FriendsLoader.h
//  vkontakteZedApp
//
//  Created by AIR on 23.10.15.
//  Copyright © 2015 Ivan Golikov. All rights reserved.
//


//делегат для управления полученными через API данными

#import <Foundation/Foundation.h>

@class FriendsLoader;
@protocol FriendsLoaderDelegate <NSObject>
- (void) fetchFriends;
@end

@interface FriendsLoader : NSObject

@property (strong, nonatomic) NSArray *friends;

@property (nonatomic, weak) id <FriendsLoaderDelegate> delegate;

- (instancetype)initWithURL:(NSURL *)dataURL andKey:(NSString*)key;

@end
