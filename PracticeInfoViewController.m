//
//  PracticeInfoViewController.m
//  YOGA Studios
//
//  Created by Clyde Barrow on 18.12.2017.
//  Copyright © 2017 Clyde Barrow. All rights reserved.
//

#import "PracticeInfoViewController.h"
#import "YSPractice+CoreDataClass.h"
#import "YSPractice+CoreDataProperties.h"
#import "YSTeacher+CoreDataClass.h"
#import "YSTeacher+CoreDataProperties.h"
#import "YSStudent+CoreDataClass.h"
#import "YSStudent+CoreDataProperties.h"
#import "CoreDataManager.h"
#import "EntitisTableViewController.h"


@interface PracticeInfoViewController () <UITableViewDataSource, UITextViewDelegate, UITextFieldDelegate>


//  Флаг редактирования практики
@property (nonatomic, assign) BOOL isEditing;
//  Имя картинки
@property (nonatomic, strong) NSString * imageName;

@end



@implementation PracticeInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  Установка значения картинки по умолчанию флага редактирования
    self.imageName = @"imageNotFound";
    self.isEditing = NO;
    
    //  Создаем рандомое имя картинки
    NSInteger practiceNum = arc4random()%100;
    NSString * imageName = [NSString stringWithFormat:@"yoga-%li.png", practiceNum];
    
    //  Настройка картинки практики
    self.photoImageView.backgroundColor = [UIColor clearColor];
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    //  Отключение большого тайтла
    self.navigationController.navigationBar.prefersLargeTitles = NO;
    
    //  Установка практики которую редактируем в свойство
    YSPractice * practice = (YSPractice *)self.entity;
    self.practice = practice;
    
    //  Извлекаем массивы студентов и преподавателей
    self.studentArray = [[NSMutableArray alloc] initWithArray:[self sortedObjectsInArray:self.practice.students.allObjects]];
    self.teacherArray = [[NSMutableArray alloc] initWithArray:[self sortedObjectsInArray:self.practice.teachers.allObjects]];
    //  Описание практики из практики
    self.descriptionLabel.text = practice.descriptionText;
    //  Имя практики
    self.nameLabel.text = [NSString stringWithFormat:@"\"%@\"", practice.name];
    
    //  Если иям картинки практики НЕ imageNotFound то картинка как в памяти
    if (![practice.imageName isEqualToString:@"imageNotFound"]) {
        imageName = practice.imageName;
        
    //  Иначе картинка рандомная
    } else {
        imageName = [NSString stringWithFormat:@"yoga-%li.png", practiceNum];
    }
    //  Установка картинки
    self.photoImageView.image = [UIImage imageNamed:imageName];

    
    //  Правая кнопка
    UIBarButtonItem * editButton = [[UIBarButtonItem alloc] initWithTitle:@"Редактировать" style:UIBarButtonItemStylePlain target:self action:@selector(editButton)];
    self.navigationItem.rightBarButtonItem = editButton;
    //
    self.tableView.allowsSelectionDuringEditing = YES;
    
    
    //  Настройка лейблов имени, описания
    self.nameLabel.userInteractionEnabled = NO;
    self.nameLabel.borderStyle = UITextBorderStyleNone;
    
    self.descriptionLabel.editable = NO;
    self.descriptionLabel.selectable = NO;
    
    //  Плейсхолдера
    self.placeholderLabel.alpha = 0.f;
    //  Если есть описание практики то скрываем плейсхолдер
    if (practice.descriptionText.length == 0) {
        self.placeholderLabel.alpha = 1.f;
    }
}


//  Нажатие
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //  Определяем точку нажатия и вью на который нажимаем
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    UIView * view = [self.view hitTest:point withEvent:event];
    
    //  Если режим редактирования и нажали на картинку то смена картинки
    if (![view isEqual:self.view] & self.tableView.editing) {
        [self changeImage];
        
    //  Иначе скрываем клавиатуру
    } else {
        [self.view endEditing:YES];
    }
}


//  Реализация нажатия по картинке
- (void) changeImage {
    //  Название рандомной картинки
    NSString * practiceImageName = [NSString stringWithFormat:@"yoga-%d", arc4random()%100];
    //  Установка картинки по названию и запись в свойства
    self.imageName = practiceImageName;
    self.photoImageView.image = [UIImage imageNamed:practiceImageName];
}


//  Заполнение ячеек
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //  Создание ячейки
    static NSString * identifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    //  Если режим редактирования
    if (self.isEditing) {
        //  Секция 0 - преподаватели
        if (indexPath.section == 0) {
            //  Строка "добавить"
            if (indexPath.row == 0) {
                cell.textLabel.text = [self.teacherArray objectAtIndex:indexPath.row];
            //  Преподаватели
            } else {
                YSTeacher * teacher = [self.teacherArray objectAtIndex:indexPath.row];
                cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", teacher.firstName, teacher.lastName];
            }
            
        //  Секция 1 - студенты
        } else if (indexPath.section == 1) {
            //  Строка "добавить"
            if (indexPath.row == 0) {
                cell.textLabel.text = [self.studentArray objectAtIndex:indexPath.row];
            //  Студенты
            } else {
                YSStudent * student = [self.studentArray objectAtIndex:indexPath.row];
                cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", student.firstName, student.lastName];
            }
        }
        
        
    //  Не режим редактирования
    } else {
        //  Секция 0 - преподаватели
        if (indexPath.section == 0) {
            YSTeacher * teacher = [self.teacherArray objectAtIndex:indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", teacher.firstName, teacher.lastName];
            
        //  Секция 1 - студенты
        } else if (indexPath.section == 1) {
            YSStudent * student = [self.studentArray objectAtIndex:indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", student.firstName, student.lastName];
        }
    }
    
    return cell;
}


//  Сохранение информации
- (void) saveInfo {
    //  Практика из сущности
    YSPractice * practice = (YSPractice *)self.entity;
    
    //  Установка новых свойств
    practice.descriptionText = self.descriptionLabel.text;
    
    NSString * name = nil;
    NSString * firstSimbol = [self.nameLabel.text substringToIndex:1];
    //
    if ([firstSimbol isEqualToString:@"\""]) {
        NSString * string = self.nameLabel.text;
        NSRange range = NSMakeRange(1, string.length - 2);
        name = [[NSMutableString alloc] initWithString:[string substringWithRange:range]];
    } else {
        name = self.nameLabel.text;
    }
    
    practice.name = name;
    practice.imageName = self.imageName;
    
    //  Сохранение сущности
    [[CoreDataManager sharedManager] saveContext];
}

//  добавление студента со всеми вытекающими
- (void) addStudent {
    
    //  Создание таблицы студентов текущей студии
    EntitisTableViewController * tvc = [[EntitisTableViewController alloc] initWithEntityType:AddedEntitisTypeStudent completionBlock:^(AddedEntitisType type, id entity) {
        
        //  Если пришел студент и его еще нет
        if ([entity isKindOfClass:[YSStudent class]]) {
            
            //  Приводим к классу студента
            YSStudent * student = (YSStudent *)entity;
            //  Если еще нет такого студента
            if (![self.studentArray containsObject:student]) {
                
                //  Устанавливаем студенту текущую студию
                student.studio = self.studio;
                //  Добавляем студенту текущую практику
                [student addPracticesObject:self.practice];
                
                
                //  Сохранение свойств в кор дату
                [[CoreDataManager sharedManager] saveContext];
                
                
                //  Добавление студента в массив
                //  Удаление первого объекта (строки)
                id firstObject = [self.studentArray objectAtIndex:0];
                [self.studentArray removeObjectAtIndex:0];
                //  Добавление пришедшего студента
                [self.studentArray addObject:student];
                //  Сортировка массива по имени/фамилии
                [self sortedObjectsInArray:self.studentArray];
                //  Добавление первого объекта (строки)
                [self.studentArray insertObject:firstObject atIndex:0];
                
                //  Поиск студента в массиве и создание на его основе path
                NSInteger indexObject = [self.studentArray indexOfObject:student];
                NSIndexPath * path = [NSIndexPath indexPathForRow:indexObject inSection:1];
                
                //  Добавление студента в таблицу
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
                [self.tableView endUpdates];
            }
        }
    }];
    //  Настройка тайтла и установка текущей студии
    tvc.title = @"Выбери студента";
    tvc.currentStudio = self.studio;
    tvc.parentEntity = self;
    
    //  Создание навигейшеа и его презент
    UINavigationController * navC = [[UINavigationController alloc] initWithRootViewController:tvc];
    [self presentViewController:navC animated:YES completion:^{
    }];
}


//  Добавление преподавателя со всеми вытекающими
- (void) addTeacher {
    
    //  Создание таблицы преподавателей текущей студии
    EntitisTableViewController * tvc = [[EntitisTableViewController alloc] initWithEntityType:AddedEntitisTypeTeacher completionBlock:^(AddedEntitisType type, id entity) {
        
        //  Если пришел преподаватель
        if ([entity isKindOfClass:[YSTeacher class]]) {
            
            //  Приведения к типу преподаватель
            YSTeacher * teacher = (YSTeacher *)entity;
            
            //  Если еще нет такого преподавателя
            if (![self.teacherArray containsObject:teacher]) {
                
                //  Установка студии преподавателю и практики
                teacher.studio = self.studio;
                [teacher addPracticesObject:self.practice];
                
                //  Добавление преподавателя в кор дату
                [[CoreDataManager sharedManager] saveContext];
                
                
                //  Добавление преподавателя в массив
                //  Убираем первый объект из массива (строку)
                id firstObject = [self.teacherArray objectAtIndex:0];
                [self.teacherArray removeObjectAtIndex:0];
                //  Добавляем преподавателя
                [self.teacherArray addObject:teacher];
                //  Сортировка по имени/фамилии
                [self sortedObjectsInArray:self.teacherArray];
                //  Добавляем первый объект (строку)
                [self.teacherArray insertObject:firstObject atIndex:0];
                
                //  Ищем объект и берем его индекс
                NSInteger indexObject = [self.teacherArray indexOfObject:teacher];
                NSIndexPath * path = [NSIndexPath indexPathForRow:indexObject inSection:0];
                
                //  Обновление таблицы
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
                [self.tableView endUpdates];
            }
        }
    }];
    //  Установка тайтла и текущей студии
    tvc.title = @"Выбери преподавателя";
    tvc.currentStudio = self.studio;
    tvc.parentEntity = self;
    
    //  Создание навигейшена и его презент
    UINavigationController * navC = [[UINavigationController alloc] initWithRootViewController:tvc];
    [self presentViewController:navC animated:YES completion:^{
    }];
}



//  Удаление человека со всеми вытекющими
- (void) deletePeopleAtIndexPath:(NSIndexPath *)indexPath {
    //  Если первая секция то это преподаватель
    if (indexPath.section == 0) {
        
        //  Удаление из практики но не из кор даты
        YSTeacher * teacher = [self.teacherArray objectAtIndex:indexPath.row];
        [self.practice removeTeachersObject:teacher];
        
        //  Удаление из массива
        [self.teacherArray removeObjectAtIndex:indexPath.row];
        
        
    //  Если вторая секция то это студент
    } else {
        
        //  Удаление из практики но не из кор даты
        YSStudent * student  = [self.studentArray objectAtIndex:indexPath.row];
        [self.practice removeStudentsObject:student];
        
        //  Удаление из массива
        [self.studentArray removeObjectAtIndex:indexPath.row];
    }

    //  Обновление таблицы
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
}


#pragma mark - worked

- (NSManagedObjectContext *) managedObjectContext {
    if (!_managedObjectContext) {
        _managedObjectContext = [[[CoreDataManager sharedManager] persistentContainer] viewContext];
    }
    return _managedObjectContext;
}

//  Перед закрытием вью
- (void)viewWillDisappear:(BOOL)animated {
    //  Установка большого тайтла
    self.navigationController.navigationBar.prefersLargeTitles = YES;
}


//  Сколько секций в таблице
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

//  Сколько ячеек в секциях
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.teacherArray.count;
    }
    return self.studentArray.count;
}

//  Стиль редактирования ячейки
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    //  Стиль по умолчанию - удаление
    UITableViewCellEditingStyle style = UITableViewCellEditingStyleDelete;
    //  Если ячейка 0 и режим редактирования то стиль добавление
    if ((indexPath.row == 0) & self.isEditing) {
        style = UITableViewCellEditingStyleInsert;
    }
    return style;
}


//  Отодвигать ли клетку в режиме редактирования
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//  Хедеры секций
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Преподаватели";
    }
    return @"Студенты";
}


//  Реалтзация кнопки редактирования
- (void) editButton {
    //  Изменение состояния таблицы обычное/редактирование
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    self.isEditing = self.tableView.editing;
    
    //  Закрытие клавиатуры
    [self.view endEditing:YES];
    
    
    //  Добавление строк
    NSString * stringTeacher = @"Добавить преподавателя...";
    NSString * stringStudent = @"Добавить студента...";
    
    //  Создание path для добавления/удаления
    NSInteger index = 0;
    NSIndexPath * pathTeacher = [NSIndexPath indexPathForRow:index inSection:0];
    NSIndexPath * pathStudent = [NSIndexPath indexPathForRow:index inSection:1];
    
    
    //  Если режим редактирования
    if (self.isEditing) {
        //  Создание кнопки с новым именем и установка ее
        UIBarButtonItem * buttonDone = [[UIBarButtonItem alloc] initWithTitle:@"Готово"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self action:@selector(editButton)];
        [self.navigationItem setRightBarButtonItem:buttonDone animated:YES];
        
        
        //  Изменение свойств лейблов показ рамок, активация
        self.descriptionLabel.layer.borderWidth = 1.f;
        UIColor * borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        self.descriptionLabel.layer.borderColor = borderColor.CGColor;
        self.descriptionLabel.layer.cornerRadius = 6.f;
        
        self.nameLabel.userInteractionEnabled = YES;
        self.nameLabel.borderStyle = UITextBorderStyleRoundedRect;
        
        self.descriptionLabel.editable = YES;
        self.descriptionLabel.selectable = YES;
        
        self.photoImageView.layer.cornerRadius = 10.f;
        self.photoImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.photoImageView.layer.borderWidth = 0.3f;
        
        //  Добавление строк в массивы
        [self.teacherArray insertObject:stringTeacher atIndex:index];
        [self.studentArray insertObject:stringStudent atIndex:index];
        //  Добавление ячеек в таблицу
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[pathTeacher, pathStudent] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
      
    //  Если обычный режим
    } else {
        //  Создание кнопки с новым именем и установка ее
        UIBarButtonItem * buttonEdit = [[UIBarButtonItem alloc] initWithTitle:@"Редактировать"
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self action:@selector(editButton)];
        [self.navigationItem setRightBarButtonItem:buttonEdit animated:YES];
        
        
        //  Изменение свойств лейблов скрытие рамок, деактивация
        self.descriptionLabel.layer.borderWidth = 0.f;
        
        self.nameLabel.userInteractionEnabled = NO;
        self.nameLabel.borderStyle = UITextBorderStyleNone;
        
        self.descriptionLabel.editable = NO;
        self.descriptionLabel.selectable = NO;
        
        self.photoImageView.layer.borderColor = [[UIColor clearColor] CGColor];
        
        //  Сохранение информации
        [self saveInfo];
        
        //  Удаление строк из массива
        [self.teacherArray removeObjectAtIndex:index];
        [self.studentArray removeObjectAtIndex:index];
        //  Удаление ячеек из таблицы
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[pathTeacher, pathStudent] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}


//  Нажатие на ячейку
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //  Если режим редактирования и первая чейка в первой секции - добавление преподавателя
    if (indexPath.row == 0 & indexPath.section == 0 & self.isEditing) {;
        [self addTeacher];
        
    //  Если режим редактирования и первая ячейка во второй секции - добавление студента
    } else if (indexPath.row == 0 & indexPath.section == 1 & self.isEditing) {
        [self addStudent];
    }
}


//  Добавление или удаление по жестам
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //  ЕСли удаление
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //  Удаление человека по индексу
        [self deletePeopleAtIndexPath:indexPath];
        
    //  Если добавление
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        //  Если секция 0 то добавление преподавателя
        if (indexPath.section == 0) {
            [self addTeacher];
            
        //  Если секция 1 то добавление студента
        } else {
            [self addStudent];
        }
    }
}


//  Поддержка режима редактирования (выезд слева иконки)
- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return YES;
}


//  Сортировка массива по имени/фамиии
- (NSArray *) sortedObjectsInArray:(NSArray *)array {
    //  Создаем изменяемый масств из пришедшего
    NSMutableArray * mArray = [[NSMutableArray alloc] initWithArray:array];
    //  Создаем сорт дискрипторы
    NSSortDescriptor * firstNameDiscriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
    NSSortDescriptor * lastNameDiscriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
    //  Сортируем по сортдискрипторам
    [mArray sortUsingDescriptors:@[firstNameDiscriptor, lastNameDiscriptor]];
    return mArray;
}

//  Начало редактирования текст вью
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    //  Если начали редактировать то плейсхолдер пропадает
    if (self.descriptionLabel.text != 0) {
        self.placeholderLabel.alpha = 0.f;
    }
    
    return YES;
}

//  Конец редактирования текст вью
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    //  Если перестали редактировать и пусто то показываем плейсхолдер
    if (self.descriptionLabel.text.length == 0) {
        self.placeholderLabel.alpha = 1.f;
    }
    
    return YES;
}

//  Изменение текста лейбла
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //  Просчитываем измененный текст
    NSString * str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    //  Берем правую кнопку
    UIBarButtonItem * button = self.navigationItem.rightBarButtonItem;
    
    //  Если текста нет то кнопка не активна
    if (str.length == 0) {
        button.enabled = NO;
        
    //  Если текст есть то активна
    } else {
        button.enabled = YES;
    }
    
    return YES;
}

@end
