//
//  TeacherTableViewController.m
//  YOGA Studios
//
//  Created by Clyde Barrow on 06.12.2017.
//  Copyright © 2017 Clyde Barrow. All rights reserved.
//

#import "TeacherTableViewController.h"
#import "YSTeacher+CoreDataClass.h"
#import "YSTeacher+CoreDataProperties.h"
#import "PeopleInfoViewController.h"
#import "StudioTableViewController.h"
#import "CoreDataManager.h"


@interface TeacherTableViewController () <UITextFieldDelegate>

//  Правая кнопка
@property (nonatomic, strong) UIBarButtonItem * rightButton;
//  Алерт
@property (nonatomic, strong) UIAlertController * alert;

@end


@implementation TeacherTableViewController
@synthesize fetchedResultsController = _fetchedResultsController;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  Тайтл
    self.parentViewController.navigationItem.title = @"ПРЕПОДАВАТЕЛИ";
    
    //  Правая кнопка
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightAddButton)];
    self.rightButton = rightButton;
}


//  После появления вью
- (void)viewDidAppear:(BOOL)animated {
    //  Установка тайтсла
    self.parentViewController.navigationItem.title = @"ПРЕПОДАВАТЕЛИ";
    //  Правая кнопка из проперти
    self.parentViewController.navigationItem.rightBarButtonItem = self.rightButton;
}


//  Реализация нажатия правой кнопки
- (void) rightAddButton {
    //  Создание алерта добавления человека
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Новый преподаватель" message:@"Введите данные" preferredStyle:(UIAlertControllerStyleAlert)];
    
    //  Добавелние и настройка текстфилдов
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.delegate = self;
        textField.placeholder = @"Имя";
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.delegate = self;
        textField.placeholder = @"Фамилия";
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }];
    
    //  Кнопка добавления человека
    UIAlertAction * actionAdd = [UIAlertAction actionWithTitle:@"Добавить" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        //  Добавление в кордату препоа
        [[CoreDataManager sharedManager] addTeacherWithFirstName:alert.textFields.firstObject.text
                                                        LastName:alert.textFields.lastObject.text
                                                          Studio:self.studio
                                                        Practice:nil];
        //  Перезагрузка таблицы
        [self.tableView reloadData];
        
    }];
    //  По умолчанию отключена
    actionAdd.enabled = NO;
    
    //  Кнопка отмены
    UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:@"Отмена" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    
    //  Добавление кнопок к алерту
    [alert addAction:actionAdd];
    [alert addAction:actionCancel];
    
    //  Установка алерта в свойства
    self.alert = alert;
    
    //  Презент алерта
    [self presentViewController:alert animated:YES completion:^{
    }];
}


//  Редактирование ячейки
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //  Если удаление
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //  Тичер из таблицы по ячейке
        YSTeacher * teacher = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        //  Удаление тичера из контекста
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:teacher];
        
        //  Сохранение данных
        NSError *error = nil;
        if (![context save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
            abort();
        }
    }
}


//
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    //  Создание и настройка реквеста
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"YSTeacher" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    //  Фильтрация преподавателей по студии
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"studio == %@", self.studio];
    [fetchRequest setPredicate:predicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Сортировка по имени
    NSSortDescriptor *sortDescriptorFN = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *sortDescriptorLN = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[sortDescriptorFN, sortDescriptorLN]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:self.managedObjectContext
                                                                                                  sectionNameKeyPath:nil
                                                                                                           cacheName:nil];
    aFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    
    _fetchedResultsController = aFetchedResultsController;
    return _fetchedResultsController;
}


//  Формирование ячейки
- (void)configureCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    //  Преподаватель из таблицы по ячейке
    YSTeacher * teacher = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //  Установка свойств ячейки, имя, индикатор стрелочка
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", teacher.firstName, teacher.lastName];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}


- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo name];
}


//  Нажатие на ячейку
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //  Тичер из таблицы по ячейке
    YSTeacher * teacher = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //  Создание контроллера с информацией о преподавателе и передача в него нажатого преподавателя
    PeopleInfoViewController * vc = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"People"];
    vc.entity = teacher;
    
    //  Пуш контроллера с информацией о преподавателе
    [self.navigationController pushViewController:vc animated:YES];
}


//  Изменение текста в текст филдах
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    //  Просчет изменения текстового поля
    NSString * str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    //  Изменяемый массив создается из массива текстфилдов в алерте
    NSMutableArray * mArray = [[NSMutableArray alloc] initWithArray:self.alert.textFields];
    //  Из массива удаляется текст филд в котором мы сейчас
    [mArray removeObject:textField];
    
    //  Остается другой текстфилд
    UITextField * field = [mArray firstObject];
    
    //  Берем кнопку которая выключена
    UIAlertAction * action = self.alert.actions.firstObject;
    
    //  Если текущий текстфилд не пустой, кнопка активируется
    if (str.length > 0) {
        action.enabled = YES;
        
    //  Если текущий текст филд пустой и другой текстфилд пустой, то кнопка не активна
    } else if ((field.text.length == 0) & (str.length == 0)) {
        action.enabled = NO;
    }
    
    return YES;
}


@end
