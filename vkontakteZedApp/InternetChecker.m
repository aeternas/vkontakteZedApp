//
//  InternetChecker.m
//  vkontakteZedApp
//
//  Created by AIR on 24.10.15.
//  Copyright © 2015 Ivan Golikov. All rights reserved.
//

//класс для проверки соединения

#import "InternetChecker.h"

@implementation InternetChecker

+(BOOL)isConnection {
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://google.ru"]];
    if (data) {
        return YES;
    } else {
        return NO;
    }
    
}

@end
