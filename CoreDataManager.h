//
//  CoreDataManager.h
//  YOGA Studios
//
//  Created by Clyde Barrow on 04.12.2017.
//  Copyright © 2017 Clyde Barrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "YSStudio+CoreDataClass.h"
#import "YSStudio+CoreDataProperties.h"


@interface CoreDataManager : NSObject

@property (readonly, strong) NSPersistentContainer * persistentContainer;

+ (CoreDataManager *) sharedManager;

- (void) saveContext;


- (void) setEntitysWithName:(NSString *)name StudentNamber:(NSInteger)studentNum;
- (void) printEntitys;
- (void) clearEntitys;

- (void) addStudentWithFirstName:(NSString *)firstName LastName:(NSString *)lastName Studio:(YSStudio *)studio Practice:(YSPractice *)practice;
- (void) addTeacherWithFirstName:(NSString *)firstName LastName:(NSString *)lastName Studio:(YSStudio *)studio Practice:(YSPractice *)practice;
- (void) addPracticeWithName:(NSString *)name Studio:(YSStudio *)studio;

@end
