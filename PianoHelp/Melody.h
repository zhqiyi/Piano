//
//  Melody.h
//  PianoHelp
//
//  Created by Jobs on 14-5-12.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MelodyCategory, MelodyFavorite, Score;

@interface Melody : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSNumber * buy;
@property (nonatomic, retain) NSString * buyURL;
@property (nonatomic, retain) NSString * categoryID;
@property (nonatomic, retain) NSString * deviceID;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSString * melodyID;
@property (nonatomic, retain) NSString * level;
@property (nonatomic, retain) NSString * memo;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * scrawlPath;
@property (nonatomic, retain) NSString * style;
@property (nonatomic, retain) MelodyCategory *category;
@property (nonatomic, retain) Score *score;
@property (nonatomic, retain) MelodyFavorite *favorite;

@end
