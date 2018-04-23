//
//  StudentTableViewController.m
//  YOGA Studios
//
//  Created by Clyde Barrow on 06.12.2017.
//  Copyright © 2017 Clyde Barrow. All rights reserved.
//

#import "StudentTableViewController.h"
#import "YSStudent+CoreDataClass.h"
#import "YSStudent+CoreDataProperties.h"
#import "PeopleInfoViewController.h"
#import "CoreDataManager.h"


@interface StudentTableViewController () <UITextFieldDelegate>

//  Правая кнопка
@property (nonatomic, strong) UIBarButtonItem * rightButton;
//  Алерт
@property (nonatomic, strong) UIAlertController * alert;

@end



@implementation StudentTableViewController
@synthesize fetchedResultsController = _fetchedResultsController;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  Тайтл
    self.parentViewController.navigationItem.title = @"СТУДЕНТЫ";
    
    //  Создание и установка правой кнопки
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightAddButton)];
    self.rightButton = rightButton;
}


//  Реализация правой кнопки
- (void) rightAddButton {
    
    //  Создание алерта
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Новый студент" message:@"Введите данные" preferredStyle:UIAlertControllerStyleAlert];

    //  Добавление и настройка текст филдов
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
    
    
    //  Кнопка добавления
    UIAlertAction * buttonAdd = [UIAlertAction actionWithTitle:@"Добавить" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        //  Создание сущности студента
        [[CoreDataManager sharedManager] addStudentWithFirstName:alert.textFields.firstObject.text
                                                        LastName:alert.textFields.lastObject.text
                                                          Studio:self.studio
                                                        Practice:nil];
        //  Перезагрузка таблицы
        [self.tableView reloadData];
        
    }];
    //  По умолчанию кнопка не активна
    buttonAdd.enabled = NO;
    
    //  Кнопка отмены
    UIAlertAction * buttonCancel = [UIAlertAction actionWithTitle:@"Отмена" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    //  Добавление кнопок на алерт
    [alert addAction:buttonAdd];
    [alert addAction:buttonCancel];
    
    //  Алерт в свойства
    self.alert = alert;
    
    //  Презент алерта
    [self presentViewController:alert animated:YES completion:^{
    }];
}


//  После появления вью
- (void)viewDidAppear:(BOOL)animated {
    //  Установка родителю тайтл и кнопки
    self.parentViewController.navigationItem.title = @"СТУДЕНТЫ";
    self.parentViewController.navigationItem.rightBarButtonItem = self.rightButton;
}


//  Редактирование ячейки
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    //  Если удаление
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //  Студент из таблицы по ячейке
        YSStudent * student = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        //  Удаление студента из контекста
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:student];
    
        //  Сохранение изменений
        NSError *error = nil;
        if (![context save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
            abort();
        }
    }
}



- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    //  Создание и настройка реквеста на студента
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"YSStudent" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    //  Фильтрация студентов по студии
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"studio == %@", self.studio];
    [fetchRequest setPredicate:predicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    //  Сортировка по имени
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
    
    //  Студент из таблицы по ячейке
    YSStudent * student = [self.fetchedResultsController objectAtIndexPath:indexPath];

    //  Установка свойств ячейки имя и стрелка
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", student.firstName, student.lastName];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}



- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo name];
}


//  Нажатие на ячейку
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //  Студент пиз таблицы по ячейке
    YSStudent * student = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //  Создание контроллера с информацией о студенте и установка в него студента их таблицы
    PeopleInfoViewController * vc = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"People"];
    vc.entity = student;
    
    //  Пуш контроллера с информацией о студенте
    [self.navigationController pushViewController:vc animated:YES];
}


//  Изменение текстфилда
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    //  Просчет строки с изменениями
    NSString * str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    //  Создание изменяемого массива из текстфилдов алерта
    NSMutableArray * mArray = [[NSMutableArray alloc] initWithArray:self.alert.textFields];
    //  Удаление текущего текстфилда
    [mArray removeObject:textField];
    
    //  Текстфилд который не текущий
    UITextField * field = [mArray firstObject];
    
    //  Экшн из свойств
    UIAlertAction * action = self.alert.actions.firstObject;
    
    //  Если текущий текстфилд не пустой то кнопка активна
    if (str.length > 0) {
        action.enabled = YES;
        
    //  Если в текущем текстфилде нет текста и в другом текстфилде тоже нет то кнопка не активна
    } else if ((field.text.length == 0) & (str.length == 0)) {
        action.enabled = NO;
    }
    
    return YES;
}


@end
