//
//  EntitisTableViewController.h
//  YOGA Studios
//
//  Created by Clyde Barrow on 16.04.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//
//  Класс таблицы со списком преподавателей/студентов/практик для добавления

#import <UIKit/UIKit.h>
#import "YSStudio+CoreDataClass.h"

//  Энум типа сущностей студии что добавляем
typedef enum {
    AddedEntitisTypeTeacher,
    AddedEntitisTypeStudent,
    AddedEntitisTypePractice
} AddedEntitisType;

//  Тайпдев блока возвращаемого объекта
typedef void(^AddedEntitisBlock)(AddedEntitisType type, id entity);


@interface EntitisTableViewController : UITableViewController

//  Текущая студия
@property (nonatomic, strong) YSStudio * currentStudio;
//  Практика/студент/преподаватель из коорого вызвано
@property (nonatomic, strong) id parentEntity;

//  Инициализация по типу необходимой сущности и блоку реализации
- (instancetype)initWithEntityType:(AddedEntitisType)type completionBlock:(AddedEntitisBlock)completionBlock;

@end
