//
//  PracticeTableViewController.m
//  YOGA Studios
//
//  Created by Clyde Barrow on 06.12.2017.
//  Copyright © 2017 Clyde Barrow. All rights reserved.
//

#import "PracticeTableViewController.h"
#import "YSPractice+CoreDataClass.h"
#import "YSPractice+CoreDataProperties.h"
#import "PracticeInfoViewController.h"
#import "CoreDataManager.h"


@interface PracticeTableViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIBarButtonItem * rightButton;
@property (nonatomic, strong) UIAlertController * alert;

@end


@implementation PracticeTableViewController
@synthesize fetchedResultsController = _fetchedResultsController;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  Тайтл
    self.parentViewController.navigationItem.title = @"ПРАКТИКИ";
    
    //  Кнопка Add
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightAddButton)];
    self.rightButton = rightButton;
    
    /*
     //   Серч бар
     UISearchController * searchBar = [[UISearchController alloc] initWithSearchResultsController:nil];
     self.parentViewController.navigationItem.searchController = searchBar;
     */
}


//  После показа вью
- (void) viewDidAppear:(BOOL)animated {
    //  Тайтл
    self.parentViewController.navigationItem.title = @"ПРАКТИКИ";
    
    //  Правая кнопка из свойства
    self.parentViewController.navigationItem.rightBarButtonItem = self.rightButton;
}


//  Правая кнопка реализация нажатия
- (void) rightAddButton {
    //  Создаем алерт
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Новая практика" message:@"Введите название практики" preferredStyle:(UIAlertControllerStyleAlert)];
    
    //  Добавление и настройка текст филда
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Название практики";
        textField.delegate = self;
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }];
    
    //  Кнопка доваления
    UIAlertAction * actionAdd = [UIAlertAction actionWithTitle:@"Добавить" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //  Срабатывает если строка не пустая
        UITextField * field = alert.textFields.firstObject;
        if (![field.text isEqualToString:@""]) {
            [[CoreDataManager sharedManager] addPracticeWithName:alert.textFields.firstObject.text Studio:self.studio];
            [self.tableView reloadData];
        }
    }];
    //  Отключена по умолчанию
    actionAdd.enabled = NO;
    
    
    //  Кнопка отмены
    UIAlertAction * actionClose = [UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    //  Добавление кнопок в алерт
    [alert addAction:actionAdd];
    [alert addAction:actionClose];
    
    //  Алерт в свойства
    self.alert = alert;
    
    //  Показ алерта
    [self presentViewController:alert animated:YES completion:^{
    }];
}


//  Редактирование ячейки
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //  Если удаление
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //  Берем практику из таблицы
        YSPractice * practice = [self.fetchedResultsController objectAtIndexPath:indexPath];
                
        //  Удаляем практику
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:practice];
        
        //  Сохраняем изменения
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
    
    //  Создаем и настраиваем реквест на практики
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"YSPractice" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    
    //  Фильтрация практик по студии
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"studios contains %@", self.studio];
    [fetchRequest setPredicate:predicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    //  Сортируем по имени
    NSSortDescriptor *sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptorName]];
    
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



//  Собираем ячейку
- (void)configureCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    
    //  Берем практику из таблицы по ячейке
    YSPractice * practice = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //  Заполняем имя
    cell.textLabel.text = practice.name;
    
    //  Индикатор стрелочка
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}



- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo name];
}


//  Нажатие на ячейку
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //  Вью контроллер с информацией по практике
    PracticeInfoViewController * vc = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"Practice"];
    
    //  Практика из таблицы по ячейке
    YSPractice * practice = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //  Настройка вью контроллера
    vc.entity = practice;
    vc.studio = self.studio;
    
    //  Пуш вью контроллера
    [self.navigationController pushViewController:vc animated:YES];
}


//  Изменение текста в текст филде
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    //  Просчет текста в текст филде
    NSString * str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    //  Алерт из свойств
    UIAlertAction * action = self.alert.actions.firstObject;
    
    //  Если филд не пустой то кнопка включена
    if (str.length > 0) {
        action.enabled = YES;
    } else {
        action.enabled = NO;
    }
    
    return YES;
}


@end
