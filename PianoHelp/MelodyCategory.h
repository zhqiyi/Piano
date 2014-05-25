//
//  MelodyCategory.h
//  PianoHelp
//
//  Created by Jobs on 14-5-20.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Melody, MelodyCategory;

@interface MelodyCategory : NSManagedObject

@property (nonatomic, retain) NSNumber * buy;
@property (nonatomic, retain) NSString * buyURL;
@property (nonatomic, retain) NSString * categoryID;
@property (nonatomic, retain) NSString * cover;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * parentID;
@property (nonatomic, retain) NSNumber * sale;
@property (nonatomic, retain) NSString * saleURL;
@property (nonatomic, retain) NSSet *melody;
@property (nonatomic, retain) MelodyCategory *parentCategory;
@end

@interface MelodyCategory (CoreDataGeneratedAccessors)

- (void)addMelodyObject:(Melody *)value;
- (void)removeMelodyObject:(Melody *)value;
- (void)addMelody:(NSSet *)values;
- (void)removeMelody:(NSSet *)values;

@end
