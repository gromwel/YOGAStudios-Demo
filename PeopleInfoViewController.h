//
//  InfoViewController.h
//  YOGA Studios
//
//  Created by Clyde Barrow on 17.12.2017.
//  Copyright © 2017 Clyde Barrow. All rights reserved.
//
//  Класс информации о студенте/преподавателе

#import <UIKit/UIKit.h>
@class YSStudio;

@interface PeopleInfoViewController : UIViewController

//  Таблица практик
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//  Логотип студента/преподавателя
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
//  Лейбл имени
@property (weak, nonatomic) IBOutlet UITextField *firstNameLabel;
//  Лейбл фамилии
@property (weak, nonatomic) IBOutlet UITextField *lastNameLabel;
//  Лейбл возраста
@property (weak, nonatomic) IBOutlet UITextField *ageLabel;


//  Студия в которой мы находимся
@property (nonatomic, strong) YSStudio * studio;
//  Сущность про которую смотрим информацию
@property (nonatomic, strong) id entity;


//  Массив практик
@property (nonatomic, strong) NSMutableArray * practicesArray;


@property (nonatomic, strong) NSManagedObjectContext * managedObgectContext;


@end
