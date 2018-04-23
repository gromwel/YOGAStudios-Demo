//
//  InfoViewController.m
//  YOGA Studios
//
//  Created by Clyde Barrow on 17.12.2017.
//  Copyright © 2017 Clyde Barrow. All rights reserved.
//

#import "PeopleInfoViewController.h"
#import "YSTeacher+CoreDataClass.h"
#import "YSTeacher+CoreDataProperties.h"
#import "YSStudent+CoreDataClass.h"
#import "YSStudent+CoreDataProperties.h"
#import "YSPractice+CoreDataClass.h"
#import "YSPractice+CoreDataProperties.h"
#import "CoreDataManager.h"
#import "EntitisTableViewController.h"


@interface PeopleInfoViewController () <UITableViewDataSource, UITextFieldDelegate>

//  Тип сущности студент/преподаватель
@property (nonatomic, strong) NSString * peopleType;

//  Пол студента/преподавателя
@property (nonatomic, assign) double sex;
//  Флаг режима редактирования
@property (nonatomic, assign) BOOL isEditing;

@end



@implementation PeopleInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //  Установка большого тайтла
    self.navigationController.navigationBar.prefersLargeTitles = NO;
    //  Флаг редактирования по умолчанию NO
    self.isEditing = NO;
    
    
    //  Если сущность преподавателя
    if ([self.entity isKindOfClass:[YSTeacher class]]) {
        
        //  По умолчанию картинка розовая и пол женский imageNamed:@"teacher_gray.png"
        self.photoImageView.image = [UIImage imageNamed:@"teacher_gray.png"];
        self.sex = NSNotFound;
        
        //  Создаем преподавателя из переданной сущности
        YSTeacher * teacher = (YSTeacher *)self.entity;
        
        //  Устанавливаем лейблы имени и фамилии из сущности
        self.firstNameLabel.text = teacher.firstName;
        self.lastNameLabel.text = teacher.lastName;
        
        //  Если есть возраст, то устанавливаем возраст
        if (teacher.age) {
            self.ageLabel.text = [NSString stringWithFormat:@"%i лет", teacher.age];
        }
        
        //  Берем массив практик из сущности
        self.practicesArray = [[NSMutableArray alloc] initWithArray:[self sortedObjectsInArray:teacher.practices.allObjects]];
        
        //  Преверяем сущность на пол, и в зависимости от пола устанавливаем картинку
        if (teacher.sex == 1) {
            self.sex = 1;
            self.photoImageView.image = [UIImage imageNamed:@"teacher_blue.png"];
        } else if (teacher.sex == 0) {
            self.sex = 0;
            self.photoImageView.image = [UIImage imageNamed:@"teacher_pink.png"];
        }
        
        //  Текущую студию берем из сущности
        self.studio = teacher.studio;
        
    
    //  Если сущность студента
    } else if ([self.entity isKindOfClass:[YSStudent class]]) {
        
        self.photoImageView.image = [UIImage imageNamed:@"student_gray.png"];
        self.sex = NSNotFound;
        
        YSStudent * student = (YSStudent *)self.entity;
        self.firstNameLabel.text = student.firstName;
        self.lastNameLabel.text = student.lastName;
        
        if (student.age) {
            self.ageLabel.text = [NSString stringWithFormat:@"%i лет", student.age];
        }
        
        self.practicesArray = [[NSMutableArray alloc] initWithArray:[self sortedObjectsInArray:student.practices.allObjects]];
        
        if (student.sex == 1) {
            self.sex = 1;
            self.photoImageView.image = [UIImage imageNamed:@"student_blue.png"];
        } else if (student.sex == 0) {
            self.sex = 0;
            self.photoImageView.image = [UIImage imageNamed:@"student_pink.png"];
        }
        
        self.studio = student.studio;
    }
    
    
    //  Создание и установка правой кнопки
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Редактировать" style:UIBarButtonItemStylePlain target:self action:@selector(editButton)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    //
    self.tableView.allowsSelectionDuringEditing = YES;
    
    //  Настройка лейблов имени, фамилии, возраста
    self.firstNameLabel.borderStyle = UITextBorderStyleNone;
    self.firstNameLabel.userInteractionEnabled = NO;
    
    self.lastNameLabel.borderStyle = UITextBorderStyleNone;
    self.lastNameLabel.userInteractionEnabled = NO;
    
    self.ageLabel.borderStyle = UITextBorderStyleNone;
    self.ageLabel.userInteractionEnabled = NO;
}


//  Нажатие
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //  Берем нажатие и определяем вью на который нажимаем
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    UIView * view = [self.view hitTest:point withEvent:event];
    
    //  Если это вью картинки студента/преподавателя и мы в режиме редактирования
    if (![view isEqual:self.view] & self.tableView.editing) {
        //  Отрабатываем нажатие по картинке
        [self changeImage];
        
    //  Иначе скрываем клавиатуру
    } else {
        [self.view endEditing:YES];
    }
}


//  Реализация нажаттия на картинку
- (void) changeImage {
    
    //  Создаем переменные пола и сущности
    NSString * entity = @"";
    
    //  Если пола нет то устанавливаем мужчину
    if (self.sex == NSNotFound) {
        self.sex = 1;
        
    //  Если пол женский то устанавливаем мужчину
    } else if (self.sex == 0) {
        self.sex = 1;
        
    //  Если пол мужской то устанавливаем женщину
    } else if (self.sex == 1) {
        self.sex = 0;
    }
    
    
    //  Если сущность преподавателя то переменная - преподаватель, если студент то студент
    if ([self.entity isKindOfClass:[YSTeacher class]]) {
        entity = @"teacher";
    } else if ([self.entity isKindOfClass:[YSStudent class]]) {
        entity = @"student";
    }
    
    //  Смена изображения на ПОЛ у СУЩНОСТИ
    [self changeImageWithSex:self.sex entity:entity];
}

 
//  Реализация смены иображения на пол у сущности
- (void) changeImageWithSex:(double)sex entity:(NSString *)entity {
    
    //  Имя картинки в зависимости от сущности и пола
    NSString * imageName = [NSString stringWithFormat:@"%@_pink", entity];
    if (sex == 1) {
        imageName = [NSString stringWithFormat:@"%@_blue", entity];
    }
    
    //  Установка картинки по имени
    self.photoImageView.image = [UIImage imageNamed:imageName];
}


- (NSManagedObjectContext *) managedObgectContext {
    if (!_managedObgectContext) {
        _managedObgectContext = [[[CoreDataManager sharedManager] persistentContainer] viewContext];
    }
    return _managedObgectContext;
}


//  Сохранение информации
- (void) saveInfo {
    
    //  Если сущность преподавателя
    if ([self.entity isKindOfClass:[YSTeacher class]]) {
        //  Приводим к типу преподавателя и меняем его свойства
        YSTeacher * teacher = (YSTeacher *)self.entity;
        teacher.firstName = self.firstNameLabel.text;
        teacher.lastName = self.lastNameLabel.text;
        teacher.sex = self.sex;
        
        
    //  Если сущность студента
    } else if ([self.entity isKindOfClass:[YSStudent class]]) {
        //  Приводим к типу студента и меняем его свойства
        YSStudent * student = (YSStudent *)self.entity;
        student.firstName = self.firstNameLabel.text;
        student.lastName = self.lastNameLabel.text;
        student.sex = self.sex;
    }
    
    //  Сохранение контекста
    [[CoreDataManager sharedManager] saveContext];
}


//  Реализация кнопки редактирования
- (void) editButton {
    //  Включаем или выключаем редактирование таблицы
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    //  Скрываем клавиатуру если она есть
    [self.view endEditing:YES];
    
    
    //  Добавление строки "добавить практику" в таблицу практик
    //  Создаем объект и path его в таблице
    NSString * firstObject = @"Добавить практику";
    NSInteger index = 0;
    NSIndexPath * path = [NSIndexPath indexPathForRow:index inSection:0];
    
    
    //  Если таблица в состоянии редактирования
    if (self.tableView.editing) {
        
        //  Создаем кнопку с новым именем и устанавливаем ее
        UIBarButtonItem * buttonDone = [[UIBarButtonItem alloc] initWithTitle:@"Готово"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self action:@selector(editButton)];
        [self.navigationItem setRightBarButtonItem:buttonDone animated:YES];
        
        
        //  Меняем свойства лейблов ставя рамки и разрешая их редактировать
        self.firstNameLabel.borderStyle = UITextBorderStyleRoundedRect;
        self.firstNameLabel.userInteractionEnabled = YES;
        
        self.lastNameLabel.borderStyle = UITextBorderStyleRoundedRect;
        self.lastNameLabel.userInteractionEnabled = YES;
        
        self.ageLabel.borderStyle = UITextBorderStyleRoundedRect;
        self.ageLabel.userInteractionEnabled = YES;
        
        self.photoImageView.layer.borderWidth = 0.5f;
        self.photoImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.photoImageView.layer.cornerRadius = 10.f;
        
        
        //  Меняе свойство
        self.isEditing = YES;
        //  Добавление объекта в массив практик
        [self.practicesArray insertObject:firstObject atIndex:index];
        //  Добавление ячейки в таблицу
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
        
    
    //  Если таблица в состоянии не редактирования
    } else {
        
        //  Сохраняем информацию по сущности
        [self saveInfo];
        
        //  Создаем кнопку с другим именем и устанавливаем ее
        UIBarButtonItem * buttonEdit = [[UIBarButtonItem alloc] initWithTitle:@"Редактировать"
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self action:@selector(editButton)];
        [self.navigationItem setRightBarButtonItem:buttonEdit animated:YES];
        
        
        //  Меняем свойства лейблов убирая рамки и отключая их
        self.firstNameLabel.borderStyle = UITextBorderStyleNone;
        self.firstNameLabel.userInteractionEnabled = NO;
        
        self.lastNameLabel.borderStyle = UITextBorderStyleNone;
        self.lastNameLabel.userInteractionEnabled = NO;
        
        self.ageLabel.borderStyle = UITextBorderStyleNone;
        self.ageLabel.userInteractionEnabled = NO;
        
        self.photoImageView.layer.borderColor = [[UIColor clearColor] CGColor];
        
        
        //  Меняем свойство
        self.isEditing = NO;
        //  Удаление объекта из массива практик
        [self.practicesArray removeObjectAtIndex:index];
        //  Удаление ячейки из таблицы
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
        
    }
}


//  До появления вью
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //  Убираем большой тайтл
    self.navigationController.navigationBar.prefersLargeTitles = NO;
}


//  Перед скрытием вью
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //  Установка большого тайтла
    self.navigationController.navigationBar.prefersLargeTitles = YES;
}



//  Редактирование ячейки
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //  Если удаление
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //  Удаление практики по номеру в таблице
        [self deletePracticeAtIndexPath:indexPath];
        
    //  Если добавление
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        //  Добавление практики
        [self addPractice];
    }
}


//  Смена текста в текстовых полях
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //  Считаем строку при редактировании
    NSString * str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    //  Флаг состояния кнопки сохранения
    BOOL buttonEnable = YES;
    
    //  Если текстфилд имени
    if ([textField.restorationIdentifier isEqualToString:@"firstName"]) {
        //  Флаг состояния
        buttonEnable = (str.length == 0) | (self.lastNameLabel.text.length == 0);
        
        
    //  Если текстфилд фамилии
    } else if ([textField.restorationIdentifier isEqualToString:@"lastName"]) {
        //  Флаг сотояния
        buttonEnable = (str.length == 0) | (self.firstNameLabel.text.length == 0);
    }
    
    //  Устанавливаем состояние кнопки
    self.navigationItem.rightBarButtonItem.enabled = !buttonEnable;
    
    return YES;
}



//  Количество ячеек
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.practicesArray.count;
}


//  Заполнение ячейки
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //  Берем ячейку
    static NSString * identififer = @"Cell";
    UITableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:identififer];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identififer];
    }
    
    //  Если режим редактирования
    if (self.isEditing) {
        //  Первая ячейка это строка, остальные - практики
        if (indexPath.row == 0) {
            NSString * string = [self.practicesArray objectAtIndex:indexPath.row];
            cell.textLabel.text = string;
        } else {
            YSPractice * practice = [self.practicesArray objectAtIndex:indexPath.row];
            cell.textLabel.text = practice.name;
        }
        
        
    //  Если режим не редактирования
    } else {
        //  Все ячейки - практики
        YSPractice * practice = [self.practicesArray objectAtIndex:indexPath.row];
        cell.textLabel.text = practice.name;
    }
    
    return cell;
}


//  Стиль ячейки
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    //  По умолчанию стиль ячейки - удаление
    UITableViewCellEditingStyle style = UITableViewCellEditingStyleDelete;
    
    //  Если первая ячейка и редактирование то стиль - добавление
    if ((indexPath.row == 0) & self.tableView.editing) {
        style = UITableViewCellEditingStyleInsert;
    }
    
    return style;
}

//  Хэдер
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Практики";
}


//  Нажатие на ячейку
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    //  Если ячейка первая и редактирование - добавляем практику
    if ((indexPath.row == 0) & self.tableView.editing) {
        [self addPractice];
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//  Добавление практики
- (void) addPractice {
    
    //  Создание контроллера списка практик
    EntitisTableViewController * tvc = [[EntitisTableViewController alloc]
                                        initWithEntityType:AddedEntitisTypePractice
                                        completionBlock:^(AddedEntitisType type, __autoreleasing id entity) {
                                            
                                            
                                            YSPractice * pract = (YSPractice *)entity;
                                            if ([self.practicesArray containsObject:pract]) {
                                                
                                            }
                                            
                                            //  Если сущность - практика
                                            else if ([entity isKindOfClass:[YSPractice class]]) {
                                                
                                                //  Приводим сущность к типу практики
                                                YSPractice * practice = (YSPractice *)entity;
                                                //  Создаем объект по умолчанию студент
                                                id object = (YSStudent *)self.entity;
                                                //  Если текущая сущность преподаватель то объект меняем на преподавателя
                                                if ([self.entity isKindOfClass:[YSTeacher class]]) {
                                                    object = (YSTeacher *)self.entity;
                                                }
                                                
                                                
                                                //  Полученная практика добавляет студию
                                                [practice addStudiosObject:self.studio];
                                                //  Объект студент/преподаватель добавляем практику
                                                [object addPracticesObject:practice];
                                                
                                                
                                                //  Создаем нулевой индекс
                                                NSInteger index = 0;
                                                //  Берем первый объект по нулевому индексу и удаляем его из массива практик (это стока)
                                                id firstObject = [self.practicesArray objectAtIndex:index];
                                                [self.practicesArray removeObjectAtIndex:index];
                                                //  Добавляем в массив полученную практику
                                                [self.practicesArray addObject:practice];
                                                //  Сортируем массив практик
                                                self.practicesArray = [[NSMutableArray alloc] initWithArray:[self sortedObjectsInArray:self.practicesArray]];
                                                //  Добавлем нулевой объект (строку)
                                                [self.practicesArray insertObject:firstObject atIndex:index];
                                                
                                                
                                                //  Создаем path новой полученной практики в сортированном массиве
                                                NSInteger newIndex = [self.practicesArray indexOfObject:practice];
                                                NSIndexPath * path = [NSIndexPath indexPathForRow:newIndex inSection:0];
                                                
                                                
                                                //  Добавляем ячейку в таблицу
                                                [self.tableView beginUpdates];
                                                [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
                                                [self.tableView endUpdates];
                                            }
                                        }];
    //  Тайтл и текущая студия
    tvc.title = @"Выбери практику";
    tvc.currentStudio = self.studio;
    tvc.parentEntity = self;
    
    //  Навигейшн на основе списка практик
    UINavigationController * navC = [[UINavigationController alloc] initWithRootViewController:tvc];
    NSLog(@"fd");
    //  Показ списка практик
    [self presentViewController:navC animated:YES completion:^{
    }];
}


//  Удаление практики по индексу в массиве
- (void) deletePracticeAtIndexPath:(NSIndexPath *)indexPath {
    
    //  Берем практику из массива практик по индексу
    YSPractice * practice = [self.practicesArray objectAtIndex:indexPath.row];
    
    //  Если текущая сущность - преподаватель
    if ([self.entity isKindOfClass:[YSTeacher class]]) {
        //  Удаляем пактику у преподавателя
        YSTeacher * teacher = (YSTeacher *)self.entity;
        [teacher removePracticesObject:practice];
        
    // Если текущая сущность - студент
    } else if ([self.entity isKindOfClass:[YSStudent class]]) {
        //  Удаляем практику у студента
        YSStudent * student = (YSStudent *)self.entity;
        [student removePracticesObject:practice];
    }
    
    //  Сохраняем изменения в кор дате
    [[CoreDataManager sharedManager] saveContext];
    
    //  Удаляем объект из массива практик
    [self.practicesArray removeObject:practice];
    
    //  Удаление объекта из таблицы
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
}


//  Сортировка массива по имени
- (NSArray *) sortedObjectsInArray:(NSArray *)array {
    //  Создаем изменяемый массив
    NSMutableArray * mArray = [[NSMutableArray alloc] initWithArray:array];
    //  Создаем дискриптор
    NSSortDescriptor * nameDiscriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    //  Сортируем по дискриптору
    [mArray sortUsingDescriptors:@[nameDiscriptor]];
    return mArray;
}


@end
