//
//  Friend+CoreDataProperties.h
//  
//
//  Created by AIR on 24.10.15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Friend.h"

NS_ASSUME_NONNULL_BEGIN

@interface Friend (CoreDataProperties)

@property (nullable, nonatomic, retain) id avatar;
@property (nullable, nonatomic, retain) NSString *firstName;
@property (nullable, nonatomic, retain) NSString *lastName;
@property (nullable, nonatomic, retain) NSNumber *sex;
@property (nullable, nonatomic, retain) NSNumber *uid;
@property (nullable, nonatomic, retain) NSString *bdate;

@end

NS_ASSUME_NONNULL_END
