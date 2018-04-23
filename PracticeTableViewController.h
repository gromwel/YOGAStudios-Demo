//
//  PracticeTableViewController.h
//  YOGA Studios
//
//  Created by Clyde Barrow on 06.12.2017.
//  Copyright © 2017 Clyde Barrow. All rights reserved.
//
//  Таблица практики возможностью удаления добавления

#import "CoreDataTableViewController.h"
#import "YSStudio+CoreDataClass.h"
#import "YSStudio+CoreDataProperties.h"

@interface PracticeTableViewController : CoreDataTableViewController

//  Студия у которой смотрим практики
@property (nonatomic, strong) YSStudio * studio;

@end
