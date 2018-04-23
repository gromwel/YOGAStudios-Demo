//
//  CoreDataManager.h
//  YOGA Studios
//
//  Created by Clyde Barrow on 04.12.2017.
//  Copyright © 2017 Clyde Barrow. All rights reserved.
//
//  Класс который берет на себя взаимодействие с кор датой

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

#import "YSStudio+CoreDataClass.h"
#import "YSStudio+CoreDataProperties.h"


@interface CoreDataManager : NSObject

@property (readonly, strong) NSPersistentContainer * persistentContainer;

//  Сигнлтон
+ (CoreDataManager *) sharedManager;

//  Сохранение контекста
- (void) saveContext;


//- (void) setEntitysWithName:(NSString *)name StudentNamber:(NSInteger)studentNum;
//- (void) printEntitys;
- (void) clearEntitys;


//  Создание студента по имени, студии, практике
- (void) addStudentWithFirstName:(NSString *)firstName LastName:(NSString *)lastName Studio:(YSStudio *)studio Practice:(YSPractice *)practice;
//  Создание преподавателя по имени, студии, практике
- (void) addTeacherWithFirstName:(NSString *)firstName LastName:(NSString *)lastName Studio:(YSStudio *)studio Practice:(YSPractice *)practice;
//  Создание практики по имени, студии
- (void) addPracticeWithName:(NSString *)name Studio:(YSStudio *)studio;
//  Создание по имени
- (YSStudio *) createStudioWithName:(NSString *)name;

@end
