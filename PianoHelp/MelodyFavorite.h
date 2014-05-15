//
//  MelodyFavorite.h
//  PianoHelp
//
//  Created by Jobs on 14-5-12.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Melody;

@interface MelodyFavorite : NSManagedObject

@property (nonatomic, retain) NSString * melodyID;
@property (nonatomic, retain) NSNumber * sort;
@property (nonatomic, retain) NSSet *melody;
@end

@interface MelodyFavorite (CoreDataGeneratedAccessors)

- (void)addMelodyObject:(Melody *)value;
- (void)removeMelodyObject:(Melody *)value;
- (void)addMelody:(NSSet *)values;
- (void)removeMelody:(NSSet *)values;

@end
