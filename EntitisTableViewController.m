//
//  EntitisTableViewController.m
//  YOGA Studios
//
//  Created by Clyde Barrow on 16.04.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import "EntitisTableViewController.h"
#import "CoreDataManager.h"
#import "YSStudio+CoreDataClass.h"
#import "YSTeacher+CoreDataClass.h"
#import "YSStudent+CoreDataClass.h"
#import "YSPractice+CoreDataClass.h"
#import "PracticeInfoViewController.h"
#import "PeopleInfoViewController.h"

@interface EntitisTableViewController () <UITextFieldDelegate>


//  Тип принимаемой/возвращаемой сущности и объект возвращаемый
@property (nonatomic, assign) AddedEntitisType type;
@property (nonatomic, strong) id entity;

//  Массив сущностей
@property (nonatomic, strong) NSArray * arrayEntitis;
//  Блок исполнения
@property (nonatomic, strong) AddedEntitisBlock completionBlock;

//  Алерт
@property (nonatomic, strong) UIAlertController * alert;


@end



@implementation EntitisTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  Создание массива
    self.arrayEntitis = [[NSArray alloc] init];
    
    //
    [self setEntitysArray];
    
    //  Создание и установка кнопки отмены
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Отмена"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(cancelButton)];
    self.navigationItem.leftBarButtonItem = leftButton;
}


//  Инициализация по типу и исполняемому блоку
- (instancetype)initWithEntityType:(AddedEntitisType)type completionBlock:(AddedEntitisBlock)completionBlock
{
    self = [super init];
    if (self) {
        self.type = type;
        self.completionBlock = completionBlock;
    }
    return self;
}

//  Кнопка отмены
- (void) cancelButton {
    //  Закрытие контроллера
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}


//  Подтверждение создания
- (void) doneButton {
    //  Если есть исполняемый блок то возвращаем тип сущностей и выбранный объект
    if (self.completionBlock) {
        self.completionBlock(self.type, self.entity);
    }
    //  Закртытие контроллера
    [self cancelButton];
}


//
- (void) setEntitysArray {
    
    //  Если есть студия
    if (self.currentStudio) {
        
        //  В зависимости от требуемого типа сущностей определяем имя сущности
        NSString * entityName = @"";
        if (self.type == AddedEntitisTypeStudent) {
            entityName = @"YSStudent";
        } else if (self.type == AddedEntitisTypeTeacher) {
            entityName = @"YSTeacher";
        } else if (self.type == AddedEntitisTypePractice) {
            entityName = @"YSPractice";
        }
        
        
        //  Создаем и настраиваем реквест
        NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
        //  Создаем сущность в зависимости от требуемого типа
        NSEntityDescription * entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[CoreDataManager sharedManager].persistentContainer.viewContext];
        [fetchRequest setEntity:entity];
        
        //  Создаем предикейт
        NSPredicate * predicate = [[NSPredicate alloc] init];
        //  Фильтруем по студии
        if (self.type == AddedEntitisTypeStudent | self.type == AddedEntitisTypeTeacher) {
        predicate = [NSPredicate predicateWithFormat:@"studio == %@", self.currentStudio];
        } else if (self.type == AddedEntitisTypePractice) {
        predicate = [NSPredicate predicateWithFormat:@"studios contains %@", self.currentStudio];
        }
        [fetchRequest setPredicate:predicate];
        
        [fetchRequest setFetchBatchSize:20];
        
        //  Создаем сорт дискрипторы
        NSSortDescriptor * sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSSortDescriptor * sortDescriptorFirstName = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
        NSSortDescriptor * sortDescriptorLastName = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
        
        //  Применяем в зависимости от типа необходимого результата
        if (self.type == AddedEntitisTypeStudent | self.type == AddedEntitisTypeTeacher) {
            [fetchRequest setSortDescriptors:@[sortDescriptorFirstName, sortDescriptorLastName]];
        } else if (self.type == AddedEntitisTypePractice) {
            [fetchRequest setSortDescriptors:@[sortDescriptorName]];
        }
        
        //  Извлекаем массив данных
        NSError * error = nil;
        self.arrayEntitis = [[CoreDataManager sharedManager].persistentContainer.viewContext executeFetchRequest:fetchRequest error:&error];
    }
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayEntitis.count + 1;
}


//  Настройки ячейки
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //  Создаем ячейку
    static NSString * identifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    //  Если первая ячейка
    if (indexPath.row == 0) {
        //  Ячейка добавление нового преподавателя/студента/практики 22/108/210
        cell.textLabel.text = @"Создать";
        cell.textLabel.textColor = [UIColor colorWithRed:22.f/255.f green:108.f/255.f blue:210.f/255.f alpha:1.f];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        if ([self.parentEntity isKindOfClass:[PeopleInfoViewController class]]) {
            PeopleInfoViewController * peop = (PeopleInfoViewController *)self.parentEntity;
            if ([peop.entity isKindOfClass:[YSStudent class]]) {
                cell.userInteractionEnabled = NO;
                cell.textLabel.textColor = [UIColor lightGrayColor];
            }
        }
        
        return cell;
    }
    
    
    //  Если тип значений студенты
    if (self.type == AddedEntitisTypeStudent) {
        //  Сущности из массива приводим к типу студент
        YSStudent * student = (YSStudent *)[self.arrayEntitis objectAtIndex:indexPath.row - 1];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", student.firstName, student.lastName];
        
        //  Смотрим есть ли это значение в родителе
        if ([self.parentEntity isKindOfClass:[PracticeInfoViewController class]]) {
            PracticeInfoViewController * prc = (PracticeInfoViewController *)self.parentEntity;
            if ([prc.studentArray containsObject:student]) {
                cell.userInteractionEnabled = NO;
                cell.textLabel.textColor = [UIColor lightGrayColor];
            }
        }
    
        
    //  Если тип значений практика
    } else if (self.type == AddedEntitisTypePractice) {
        //  Сущности из массива приводим к типу практика
        YSPractice * practice = (YSPractice *)[self.arrayEntitis objectAtIndex:indexPath.row - 1];
        cell.textLabel.text = practice.name;
        
        //  Смотрим есть ли эта практика в родителе
        if ([self.parentEntity isKindOfClass:[PeopleInfoViewController class]]) {
            PeopleInfoViewController * peop = (PeopleInfoViewController *)self.parentEntity;
            if ([peop.practicesArray containsObject:practice]) {
                cell.userInteractionEnabled = NO;
                cell.textLabel.textColor = [UIColor lightGrayColor];
            }
        }
        
        
    //  Если тип значений преподаватель
    } else if (self.type == AddedEntitisTypeTeacher) {
        //  Сущности из массива приводим к типу преподаватель
        YSTeacher * teacher = (YSTeacher *)[self.arrayEntitis objectAtIndex:indexPath.row - 1];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", teacher.firstName, teacher.lastName];
        
        //  Смотрим есть ли это значение в родителе
        if ([self.parentEntity isKindOfClass:[PracticeInfoViewController class]]) {
            PracticeInfoViewController * prc = (PracticeInfoViewController *)self.parentEntity;
            if ([prc.teacherArray containsObject:teacher]) {
                cell.userInteractionEnabled = NO;
                cell.textLabel.textColor = [UIColor lightGrayColor];
            }
        }
    }
    
    return cell;
}


//  Алерт нового студента
- (void) newStudent {
    //  Создаем алерт
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Новый студент" message:@"Введите данные" preferredStyle:UIAlertControllerStyleAlert];
    
    //  Добавляем на алерт текстфилды и настраиваем их
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
    
    //  Создаем кнопку подтверждения
    UIAlertAction * buttonAdd = [UIAlertAction actionWithTitle:@"Добавить" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        //  Создание студента
        YSStudent * student = [NSEntityDescription insertNewObjectForEntityForName:@"YSStudent"
                                                            inManagedObjectContext:[CoreDataManager sharedManager].persistentContainer.viewContext];
        //  Установка свойств студента из текстфилдов
        student.firstName = alert.textFields.firstObject.text;
        student.lastName = alert.textFields.lastObject.text;
        student.sex = NSNotFound;
        
        //  Добавление новго студента в кор дату
        [[CoreDataManager sharedManager] saveContext];
        
        //  Студента в свойства и подтверждение создания
        self.entity = student;
        [self doneButton];
    }];
    //  По умолчанию кнопка подтверждения не активна
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


//  Алерт нового преподавателя
- (void) newTeacher {
    //  Создаем алерт контроллер
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Новый преподаватель" message:@"Введите данные" preferredStyle:(UIAlertControllerStyleAlert)];
    
    //  Создаем текстфилды и настраиваем их
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
    
    //  Кнопка подтверждения
    UIAlertAction * actionAdd = [UIAlertAction actionWithTitle:@"Добавить" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        //  Создание преподавателя
        YSTeacher * teacher = [NSEntityDescription insertNewObjectForEntityForName:@"YSTeacher"
                                                            inManagedObjectContext:[CoreDataManager sharedManager].persistentContainer.viewContext];
        //  Установка свойств из текстфилдов
        teacher.firstName = alert.textFields.firstObject.text;
        teacher.lastName = alert.textFields.lastObject.text;
        teacher.sex = NSNotFound;
        
        //  Добавление нового преподавателя в кор дату
        [[CoreDataManager sharedManager] saveContext];
        
        //  Преподаватель в свойства и подтверждение создания
        self.entity = teacher;
        [self doneButton];
    }];
    //  По умолчанию кнопка не активна
    actionAdd.enabled = NO;
    
    //  Создание кнопки отмены
    UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:@"Отмена" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    //  Добавление кнопок на алерт
    [alert addAction:actionAdd];
    [alert addAction:actionCancel];
    
    //  Алерт в свойства
    self.alert = alert;
    
    //  Презент алерта
    [self presentViewController:alert animated:YES completion:^{
    }];
}


//  Алерт новой практики
- (void) newPractice {
    //  Создание алерта
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Добавление практики" message:@"Введите название практики" preferredStyle:(UIAlertControllerStyleAlert)];
    //  Добавление на алерт текстфилда и настройка его
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.delegate = self;
        textField.placeholder = @"Название практики";
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }];
    
    //  Кнопка подтверждения
    UIAlertAction * actionDone = [UIAlertAction actionWithTitle:@"Добавить" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //  Создаем практику и заполняем свойства
        YSPractice * practice = [NSEntityDescription insertNewObjectForEntityForName:@"YSPractice" inManagedObjectContext:[CoreDataManager sharedManager].persistentContainer.viewContext];
        practice.name = alert.textFields.firstObject.text;
        practice.imageName = @"imageNotFound";
        
        //  Добавляем практику в кор дату
        [[CoreDataManager sharedManager] saveContext];
        
        //  Практику в свойство
        self.entity = practice;
        
        //  Подтверждение создания
        [self doneButton];
    }];
    //  По умолчанию кнопка не активна
    actionDone.enabled = NO;
    
    //  Кнопка отмены
    UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    //  Добавление кнопок на алерт
    [alert addAction:actionDone];
    [alert addAction:actionCancel];
    
    //  Алерт в свойства
    self.alert = alert;
    
    //  Презент алерта
    [self presentViewController:alert animated:YES completion:^{
    }];
}

//  Нажатие ячейки
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //  ЕСли первая ячейка (создание) в зависимости от типа необходимыч сущностей
    if (indexPath.row == 0) {
        if (self.type == AddedEntitisTypeStudent) {
            [self newStudent];
        } else if (self.type == AddedEntitisTypeTeacher) {
            [self newTeacher];
        } else if (self.type == AddedEntitisTypePractice) {
            [self newPractice];
        }
        
    
    //  Иначе сущность из ячейки в свойства и подтверждение создания
    } else {
        self.entity = [self.arrayEntitis objectAtIndex:indexPath.row - 1];
        [self doneButton];
    }
}


//  Изменение текста в филдах алерта
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //  Просчитаем измененную строку
    NSString * str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    //  Флаг по умолчанию
    BOOL isEmpty = YES;
    
    //  Если больше одного текст филда
    if (self.alert.textFields.count > 1) {
        //  Изменяемый массив из текстфилдов алерта
        NSMutableArray * mArray = [[NSMutableArray alloc] initWithArray:self.alert.textFields];
        //  Удаляем текущий филд
        [mArray removeObject:textField];
        //  Оставшийся филд проверяем
        UITextField * fild = mArray.firstObject;
        //  Флаг
        isEmpty = (fild.text.length == 0);
    }
    
    //  Берем первую кнопку алерта
    UIAlertAction * action = self.alert.actions.firstObject;
    
    //  Если измененная строка не пустая то кнопка активна
    if (str.length > 0) {
        action.enabled = YES;
        
    //  Если измененная строка пустая и флаг YES(пустая строка) то кнопка не активна
    } else if (isEmpty & (str.length == 0)) {
        action.enabled = NO;
    }
    
    return YES;
}

@end
