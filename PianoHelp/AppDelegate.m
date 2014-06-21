//
//  AppDelegate.m
//  PianoHelp
//
//  Created by Jobs on 14-5-12.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "AppDelegate.h"
#import "MelodyFavorite.h"
#import "MelodyCategory.h"
#import "Melody.h"
#import "Score.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    // Override point for customization after application launch.
//    self.window.backgroundColor = [UIColor whiteColor];
//    self.window.backgroundColor = [UIColor lightGrayColor];
//    [self.window makeKeyAndVisible];
    NSInteger iLoop = 0;
    while (iLoop > 0)
    {
        [self initCategoryAndMelody];
        iLoop--;
    }
    [self loadDemoMidiToSQL];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PianoHelp" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PianoHelp.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(NSString*)filePathForName:(NSString*)fileName
{
    NSString *strResult = [[NSBundle mainBundle] pathForResource:[fileName stringByDeletingPathExtension] ofType:[fileName pathExtension]];
    return strResult;
}

-(void)initCategoryAndMelody
{
    MelodyCategory *cate = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    //cate.categoryID = @"01";
    cate.name = @"示范曲谱";
    
    //    cate.name = @"教材曲谱";
    
    //    cate.name = @"会员曲谱";
    
    //    cate.name = @"影视金曲";

    MelodyCategory *cateYingHuang = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cateYingHuang.parentCategory = cate;
    cateYingHuang.name = @"英皇考级";

    Melody *melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.melodyID = @"聂耳义勇军进行曲";
    melody.category = cateYingHuang;
    melody.author = @"聂耳";
    melody.name = @"义勇军进行曲";
    
    Melody *melody1 = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody1.melodyID = @"聂耳黄河大合唱";
    melody1.category = cateYingHuang;
    melody1.author = @"聂耳";
    melody1.name = @"黄河大合唱";
    
    Melody *melody2 = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody2.melodyID = @"贝多芬第一交响曲";
    melody2.category = cateYingHuang;
    melody2.author = @"贝多芬";
    melody2.name = @"贝多芬第一交响曲";
    
    Melody *melody3 = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody3.melodyID = @"贝多芬第二交响曲";
    melody3.category = cateYingHuang;
    melody3.author = @"贝多芬";
    melody3.name = @"贝多芬第二交响曲";
    
    Melody *melody4 = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody4.melodyID = @"贝多芬第三交响曲";
    melody4.category = cateYingHuang;
    melody4.author = @"贝多芬";
    melody4.name = @"贝多芬第三交响曲";
    
    MelodyFavorite *favo = (MelodyFavorite*)[NSEntityDescription insertNewObjectForEntityForName:@"MelodyFavorite" inManagedObjectContext:self.managedObjectContext];
    favo.melody = melody1;
    favo.sort = @1;
    
    Score *score = (Score*)[NSEntityDescription insertNewObjectForEntityForName:@"Score" inManagedObjectContext:self.managedObjectContext];
    score.melody = melody1;
    score.rank = @1;
    score.score = @99;

    
    for (int i=1; i<10; i++)
    {
        MelodyCategory *cateYingHuang = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
        cateYingHuang.parentCategory = cate;
        cateYingHuang.name = [NSString stringWithFormat:@"英皇考级%d", i];
    }
    
    NSError *error;
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

-(void)loadDemoMidiToSQL
{
    MelodyCategory *cate = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate.name = @"考级";
    
    MelodyCategory *cate_sub = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate_sub.name = @"中国音协第六级－第八级";
    cate_sub.parentCategory = cate;
    Melody *melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"拉可夫";
    melody.name = @"波尔卡";
    melody.melodyID = melody.name;
    melody.filePath = @"01.波尔卡.mid";
    melody.style = @"乐曲";
    melody.memo = @"中国音乐家协会 2007";
    melody.level = @"6";
    NSError *error;
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"于苏贤";
    melody.name = @"儿童舞";
    melody.melodyID = melody.name;
    melody.filePath = @"08.儿童舞.mid";
    melody.style = @"复调性乐曲";
    melody.memo = @"中国音乐家协会 2007";
    melody.level = @"7";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"皮埃松卡";
    melody.name = @"塔兰泰拉舞曲";
    melody.melodyID = melody.name;
    melody.filePath = @"09.塔兰泰拉舞曲.mid";
    melody.style = @"乐曲";
    melody.memo = @"中国音乐家协会 2007";
    melody.level = @"7";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"巴赫";
    melody.name = @"布列舞曲";
    melody.melodyID = melody.name;
    melody.filePath = @"14.布列舞曲.mid";
    melody.style = @"复调性乐曲";
    melody.memo = @"中国音乐家协会 2007";
    melody.level = @"6";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    
    cate_sub = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate_sub.name = @"中国音协第一级－第五级";
    cate_sub.parentCategory = cate;
    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"瞿希贤";
    melody.name = @"听妈妈讲那过去的故事";
    melody.melodyID = melody.name;
    melody.filePath = @"04.听妈妈讲那过去的故事.mid";
    melody.style = @"复调性乐曲";
    melody.memo = @"中国音乐家协会 2007";
    melody.level = @"5";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"卡尔汉斯";
    melody.name = @"森林波尔卡";
    melody.melodyID = melody.name;
    melody.filePath = @"05.森林波尔卡.mid";
    melody.style = @"乐曲";
    melody.memo = @"中国音乐家协会 2007";
    melody.level = @"4";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    //=====
    cate = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate.name = @"教程";
    
    cate_sub = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate_sub.name = @"约翰汤普森现代钢琴教程，第二册";
    cate_sub.parentCategory = cate;
    
    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"约翰汤普森";
    melody.name = @"淘气包";
    melody.melodyID = melody.name;
    melody.filePath = @"03.淘气包.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"约翰汤普森";
    melody.name = @"带我回弗吉尼故乡";
    melody.melodyID = melody.name;
    melody.filePath = @"07.带我回弗吉尼故乡.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"约翰汤普森";
    melody.name = @"诙谐曲";
    melody.melodyID = melody.name;
    melody.filePath = @"10.诙谐曲.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"约翰汤普森";
    melody.name = @"星光圆舞曲";
    melody.melodyID = melody.name;
    melody.filePath = @"11.星光圆舞曲.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"约翰汤普森";
    melody.name = @"卡门";
    melody.melodyID = melody.name;
    melody.filePath = @"16.卡门.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    // ====
    cate_sub = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate_sub.name = @"车尔尼849";
    cate_sub.parentCategory = cate;
    
    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"车尔尼";
    melody.name = @"849-3首";
    melody.melodyID = melody.name;
    melody.filePath = @"02.849-03.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    cate_sub = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate_sub.name = @"车尔尼599";
    cate_sub.parentCategory = cate;
    
    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"车尔尼";
    melody.name = @"599-54课";
    melody.melodyID = melody.name;
    melody.filePath = @"13.599-054.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"车尔尼";
    melody.name = @"599-58课";
    melody.melodyID = melody.name;
    melody.filePath = @"15.599-058.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    // ====
    cate_sub = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate_sub.name = @"拜厄钢琴基本教程";
    cate_sub.parentCategory = cate;
    
    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"拜厄";
    melody.name = @"拜尔-100课";
    melody.melodyID = melody.name;
    melody.filePath = @"06.拜尔-100.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    // ====
    cate_sub = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate_sub.name = @"拜厄幼儿钢琴教程";
    cate_sub.parentCategory = cate;
    
    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"拜厄";
    melody.name = @"幼儿拜尔-104课";
    melody.melodyID = melody.name;
    melody.filePath = @"12.幼儿拜尔-104课.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }


    //====
    
    cate = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate.name = @"流行歌曲";
    
    cate_sub = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate_sub.name = @"经典系列";
    cate_sub.parentCategory = cate;
    
    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"理查德克莱德曼";
    melody.name = @"秋日私语";
    melody.melodyID = melody.name;
    melody.filePath = @"17.秋日私语.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"理查德克莱德曼";
    melody.name = @"水边的阿第丽娜";
    melody.melodyID = melody.name;
    melody.filePath = @"18.水边的阿第丽娜.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"理查德克莱德曼";
    melody.name = @"献给爱丽丝";
    melody.melodyID = melody.name;
    melody.filePath = @"19.献给爱丽丝.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

@end
