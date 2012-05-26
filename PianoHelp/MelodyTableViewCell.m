//
//  MelodyTableViewCell.m
//  PianoHelp
//
//  Created by Jobs on 14-5-19.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "MelodyTableViewCell.h"
#import "Melody.h"
#import "MelodyFavorite.h"
#import "AppDelegate.h"

@implementation MelodyTableViewCell

-(void) updateContent:(id)obj
{
    self.melody = (Melody*)obj;
    self.labTitle.text = self.melody.name;
    if(self.melody.favorite)
    {
        if([self.melody.favorite.sort intValue] == 1)
        {
            [self.btnFavorite setSelected:YES];
            [self.btnTask setSelected:NO];
        }
        else if([self.melody.favorite.sort intValue] == 2)
        {
            [self.btnFavorite setSelected:NO];
            [self.btnTask setSelected:YES];
        }
        else if([self.melody.favorite.sort intValue] == 3)
        {
            [self.btnFavorite setSelected:YES];
            [self.btnTask setSelected:YES];
        }
    }
    else
    {
        [self.btnFavorite setSelected:NO];
        [self.btnTask setSelected:NO];
    }
    if(self.isInSearch)
    {
        if([self.melody.buy intValue] == 1)
        {
            [self.btnBuy setSelected:YES];
        }
        else
        {
            [self.btnBuy setSelected:NO];
        }
        self.btnBuy.hidden = NO;
        self.labBuy.hidden = NO;
    }
    else
    {
        self.btnBuy.hidden = YES;
        self.labBuy.hidden = YES;
    }
}
- (IBAction)btnFavorite_click:(id)sender
{
    NSManagedObjectContext *moc = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
    if (self.melody.favorite == nil)
    {
        MelodyFavorite *favo = (MelodyFavorite*)[NSEntityDescription insertNewObjectForEntityForName:@"MelodyFavorite" inManagedObjectContext:moc];
        [favo addMelodyObject:self.melody];
        favo.sort = [NSNumber numberWithInt:1];
    }
    else
    {
        if([self.melody.favorite.sort intValue] == 1)
        {
            [moc deleteObject:self.melody.favorite];
        }
        else if([self.melody.favorite.sort intValue] == 2)
        {
            self.melody.favorite.sort = [NSNumber numberWithInt:3];
        }
        else if([self.melody.favorite.sort intValue] == 3)
        {
            self.melody.favorite.sort = [NSNumber numberWithInt:2];
        }
    }
    
    NSError *error;
    if(![moc save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
//    if([self.updateDelegate conformsToProtocol:@protocol(MelodyTableViewCellDelegate) ])
//    {
//        [self.updateDelegate updateMelodyState];
//    }
    if ([self.updateDelegate respondsToSelector:@selector(updateMelodyState)])
    {
        [self.updateDelegate updateMelodyState];
    }
    [self updateContent:self.melody];
}

- (IBAction)btnTask_click:(id)sender
{
    NSManagedObjectContext *moc = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
    if (self.melody.favorite == nil)
    {
        MelodyFavorite *favo = (MelodyFavorite*)[NSEntityDescription insertNewObjectForEntityForName:@"MelodyFavorite" inManagedObjectContext:moc];
        [favo addMelodyObject:self.melody];
        favo.sort = [NSNumber numberWithInt:2];
    }
    else
    {
        if([self.melody.favorite.sort intValue] == 1)
        {
            self.melody.favorite.sort = [NSNumber numberWithInt:3];
        }
        else if([self.melody.favorite.sort intValue] == 2)
        {
            [moc deleteObject:self.melody.favorite];
        }
        else if([self.melody.favorite.sort intValue] == 3)
        {
            self.melody.favorite.sort = [NSNumber numberWithInt:1];
        }
    }
    
    NSError *error;
    if(![moc save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    //    if([self.updateDelegate conformsToProtocol:@protocol(MelodyTableViewCellDelegate) ])
    //    {
    //        [self.updateDelegate updateMelodyState];
    //    }
    if ([self.updateDelegate respondsToSelector:@selector(updateMelodyState)])
    {
        [self.updateDelegate updateMelodyState];
    }
    [self updateContent:self.melody];
}

- (IBAction)btnBuy_click:(id)sender {
}

- (IBAction)btnView_click:(id)sender {
}
@end
