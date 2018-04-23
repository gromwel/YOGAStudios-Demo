//
//  StudioTableViewController.m
//  YOGA Studios
//
//  Created by Clyde Barrow on 06.12.2017.
//  Copyright © 2017 Clyde Barrow. All rights reserved.
//

#import "CoreDataManager.h"
#import "StudioTableViewController.h"
#import "YSStudio+CoreDataClass.h"
#import "YSStudio+CoreDataProperties.h"
#import "PracticeTableViewController.h"
#import "TeacherTableViewController.h"
#import "StudentTableViewController.h"


@interface StudioTableViewController () <UITextFieldDelegate>

//  Алерт контроллер добавления новой студии
@property (nonatomic, strong) UIAlertController * alert;

@end



@implementation StudioTableViewController
@synthesize fetchedResultsController = _fetchedResultsController;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  Настройка тайтла таблицы
    self.navigationItem.title = @"СТУДИИ";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    
    //  Добавление правой кнопки
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemAdd) target:self action:@selector(rightButton)];
    
#ifdef PRODUCTION_BUILD
    //  Кнопка удаления всего из кор даты
    UIBarButtonItem * buttonClear = [[UIBarButtonItem alloc] initWithTitle:@"DEL"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self action:@selector(clearAllEntitys)];
    
    //  Кнопка перезагрузки таблицы
    UIBarButtonItem * buttonReload = [[UIBarButtonItem alloc] initWithTitle:@"REL"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self action:@selector(reloadTable)];
    
    //  Расстояние между кнопками
    UIBarButtonItem * flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    //  Установка массива кнопок
    self.navigationItem.leftBarButtonItems = @[buttonClear, flexibleSpace, flexibleSpace, buttonReload];
#endif
    
}


#ifdef PRODUCTION_BUILD
//  Удаление всего
- (void) clearAllEntitys {
    [[CoreDataManager sharedManager] clearEntitys];
    [self reloadTable];
}


//  Перезагрузка таблицы
- (void) reloadTable {
    [self.tableView reloadData];
}

//  Хеадер
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSError * error = nil;
    NSArray * array = [[CoreDataManager sharedManager].persistentContainer.viewContext executeFetchRequest:[YSEntity fetchRequest]
                                                                          error:&error];
    return [NSString stringWithFormat:@"Entitis count = %li", array.count];
}
#endif


//  Реализация правой кнопки
- (void) rightButton {
    //  Создание контроллера
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Новая студия" message:@"Введите название студии" preferredStyle:(UIAlertControllerStyleAlert)];
    
    //  Добавление текст филда и настройка его
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.delegate = self;
        textField.placeholder = @"Имя новой студии";
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }];
    
    //  Добавление кнопки
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"Создать" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {

        //  Определяем текстфилд из алерта
        UITextField * field = alert.textFields.firstObject;
        
        //  Если текстфилд пустой
        if ([field.text isEqualToString:@""]) {

        
        //  Если не пустой то создаем студию
        } else {
            [[CoreDataManager sharedManager] createStudioWithName:field.text];
            [self.tableView reloadData];
        }
    }];
    
    //  По умолчанию экшн отключен
    action.enabled = NO;
    
    //  Экшн отмены
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    //  Добавление экшенов
    [alert addAction:action];
    [alert addAction:cancel];
    
    //  Установка алерта в свойство
    self.alert = alert;
    
    //  Презентация алерта
    [self presentViewController:alert animated:YES completion:^{
    }];
}


#pragma mark
//  Действия с ячейкой
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //  Если удаление
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        NSError * error = nil;

        //  Берем и удаляем все объекты по этой студии
        YSStudio * studio = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        NSMutableArray * mArray = [[NSMutableArray alloc] init];
        [mArray addObjectsFromArray:studio.students.allObjects];
        [mArray addObjectsFromArray:studio.teachers.allObjects];
        [mArray addObjectsFromArray:studio.practices.allObjects];
        
        for (YSEntity * entity in mArray) {
            [context deleteObject:entity];
        }
        
        //  Удаляем саму студию
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        //  Сохраняем изменения
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
            abort();
        }
    }
}



//
- (NSFetchedResultsController *)fetchedResultsController {
    
    NSLog(@"fetchedResultsController");
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Создание и настройка реквеста
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"YSStudio" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Сортировка по имени
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    
    //
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:self.managedObjectContext
                                                                                                  sectionNameKeyPath:nil
                                                                                                           cacheName:@"Master"];
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
    
    //  Берем студию по ячейке
    YSStudio * studio = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //  Установка свойств ячейки
    cell.textLabel.text = [NSString stringWithFormat:@"%@", studio.name];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%li ПРАКТИК", studio.practices.allObjects.count];
}



//  Нажатие на ячейку
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //  Создание таббара
    UITabBarController * tabBar = [[UITabBarController alloc] init];
    
    //  Правая кнопка пока пустая
    UIBarButtonItem * rightBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:nil];
    tabBar.navigationItem.rightBarButtonItem = rightBar;
    
    //  Берем студию из таблицы
    YSStudio * studio = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //  Заполнение таббара и выбор одной из таблиц
    //  Таблица учителей с иконкой и надписью
    TeacherTableViewController * vc1 = [[TeacherTableViewController alloc] init];
    vc1.studio = studio;
    vc1.tabBarItem.title = @"ПРЕПОДАВАТЕЛИ";
    vc1.tabBarItem.image = [UIImage imageNamed:@"teachers.png"];
    
    //  Таблица студентов с иконкой и надписью
    StudentTableViewController * vc2 = [[StudentTableViewController alloc] init];
    vc2.studio = studio;
    vc2.tabBarItem.title = @"СТУДЕНТЫ";
    vc2.tabBarItem.image = [UIImage imageNamed:@"students.png"];
    
    //  Таблица практик с иконкой и надписью
    PracticeTableViewController * vc3 = [[PracticeTableViewController alloc] init];
    vc3.studio = studio;
    vc3.tabBarItem.title = @"ПРАКТИКИ";
    vc3.tabBarItem.image = [UIImage imageNamed:@"practices.png"];
    
    
    [tabBar setViewControllers:@[vc3, vc1, vc2]];
    [tabBar setSelectedViewController:vc3];
    
    //  Пуш тап бара студии с учителями, студентами, практиками
    [self.navigationController pushViewController:tabBar animated:YES];
}


#pragma mark - UITextFieldDelegate
//  Изменение такста в текстфилде
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    //  Просчет текста в филде
    NSString * str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    //  Берем кнопку которую будем включать/выключать из алерта
    UIAlertAction * action = self.alert.actions.firstObject;
    
    //  Если строка не пустая то включаем
    if (str.length > 0) {
        action.enabled = YES;
    } else {
        action.enabled = NO;
    }
    
    return YES;
}



@end
