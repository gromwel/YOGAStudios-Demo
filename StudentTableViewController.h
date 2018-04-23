//
//  StudentTableViewController.h
//  YOGA Studios
//
//  Created by Clyde Barrow on 06.12.2017.
//  Copyright © 2017 Clyde Barrow. All rights reserved.
//
//  Таблица студентов с возможностью удаления/добавления

#import "CoreDataTableViewController.h"

#import "YSStudio+CoreDataClass.h"
#import "YSStudio+CoreDataProperties.h"

@interface StudentTableViewController : CoreDataTableViewController

//  Студия в которой смотрим студентов
@property (nonnull, strong) YSStudio * studio;

@end
