//
//  TeacherTableViewController.h
//  YOGA Studios
//
//  Created by Clyde Barrow on 06.12.2017.
//  Copyright © 2017 Clyde Barrow. All rights reserved.
//

#import "CoreDataTableViewController.h"

#import "YSStudio+CoreDataClass.h"
#import "YSStudio+CoreDataProperties.h"

@interface TeacherTableViewController : CoreDataTableViewController

@property (nonatomic, strong) YSStudio * studio;

@end
