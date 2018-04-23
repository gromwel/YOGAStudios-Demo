//
//  PracticeInfoViewController.h
//  YOGA Studios
//
//  Created by Clyde Barrow on 18.12.2017.
//  Copyright © 2017 Clyde Barrow. All rights reserved.
//
//  Класс который показывает подробную информацию о практике

#import <UIKit/UIKit.h>
#import "YSStudio+CoreDataClass.h"

@interface PracticeInfoViewController : UIViewController

//  Таблица студентов и преподавателей
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//  Изображение практики
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
//  Название практики
@property (weak, nonatomic) IBOutlet UITextField *nameLabel;
//  Описание практики
@property (weak, nonatomic) IBOutlet UITextView *descriptionLabel;
//  Плейсхолдер
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;


//  Сущность практики с которой работаем
@property (nonatomic, strong) id entity;


//  Текущая студия
@property (nonatomic,strong) YSStudio * studio;
//  Текущая практика
@property (nonatomic, strong) YSPractice * practice;


//  Массив преподавателей
@property (nonatomic, strong) NSMutableArray * teacherArray;
//  Массив студентов
@property (nonatomic, strong) NSMutableArray * studentArray;


//frc
@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;


@end
