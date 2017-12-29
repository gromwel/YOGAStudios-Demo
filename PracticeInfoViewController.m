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

@interface PracticeInfoViewController () <UITableViewDataSource, UITextViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) YSPractice * practice;

@property (nonatomic, strong) NSMutableArray * teacherArray;
@property (nonatomic, strong) NSMutableArray * studentArray;

@property (nonatomic, assign) BOOL isEditing;

@end

@implementation PracticeInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.isEditing = NO;
    
    NSInteger practiceNum = arc4random()%100;
    NSString * imageNamed = [NSString stringWithFormat:@"yoga-%li.png", practiceNum];
    self.photoImageView.image = [UIImage imageNamed:imageNamed];
    self.photoImageView.backgroundColor = nil;
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.navigationController.navigationBar.prefersLargeTitles = NO;
    
    YSPractice * practice = (YSPractice *)self.entity;
    self.practice = practice;
    
    self.studentArray = [[NSMutableArray alloc] initWithArray:[self sortedObjectsInArray:self.practice.students.allObjects]];
    self.teacherArray = [[NSMutableArray alloc] initWithArray:[self sortedObjectsInArray:self.practice.teachers.allObjects]];
    //
    self.descriptionLabel.text = practice.descriptionText;
    //
    self.nameLabel.text = [NSString stringWithFormat:@"\"%@\"", practice.name];
    
    UIBarButtonItem * editButton = [[UIBarButtonItem alloc] initWithTitle:@"Редактировать" style:UIBarButtonItemStylePlain target:self action:@selector(editButton)];
    self.navigationItem.rightBarButtonItem = editButton;
    
    self.tableView.allowsSelectionDuringEditing = YES;
    
    
    
    self.nameLabel.userInteractionEnabled = NO;
    self.nameLabel.borderStyle = UITextBorderStyleNone;
    
    self.descriptionLabel.editable = NO;
    self.descriptionLabel.selectable = NO;
    
    self.placeholderLabel.alpha = 0.f;
    
    if (practice.descriptionText.length == 0) {
        NSLog(@"dfgdfg");
        self.placeholderLabel.alpha = 1.f;
    }
    
    
}

//заполнение ячеек
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * identifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    if (self.isEditing) {
        //режим редактирования
        NSLog(@"Режим редактирования");
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                cell.textLabel.text = [self.teacherArray objectAtIndex:indexPath.row];
            } else {
                YSTeacher * teacher = [self.teacherArray objectAtIndex:indexPath.row];
                cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", teacher.firstName, teacher.lastName];
            }
            
        } else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                cell.textLabel.text = [self.studentArray objectAtIndex:indexPath.row];
            } else {
                YSStudent * student = [self.studentArray objectAtIndex:indexPath.row];
                cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", student.firstName, student.lastName];
            }
        }
        
    } else {
        //простой режим
        NSLog(@"Режим обычный");
        if (indexPath.section == 0) {
            YSTeacher * teacher = [self.teacherArray objectAtIndex:indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", teacher.firstName, teacher.lastName];
        } else if (indexPath.section == 1) {
            YSStudent * student = [self.studentArray objectAtIndex:indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", student.firstName, student.lastName];
        }
    }
    
    return cell;
}



- (void) saveInfo {
    
    YSPractice * practice = (YSPractice *)self.entity;
    
    practice.descriptionText = self.descriptionLabel.text;
    
    NSString * name = nil;
    
    NSString * firstSimbol = [self.nameLabel.text substringToIndex:1];
    if ([firstSimbol isEqualToString:@"\""]) {
        NSString * string = self.nameLabel.text;
        NSRange range = NSMakeRange(1, string.length - 2);
        name = [[NSMutableString alloc] initWithString:[string substringWithRange:range]];
    } else {
        name = self.nameLabel.text;
    }
    
    practice.name = name;
    
    [[CoreDataManager sharedManager] saveContext];
    
}

//добавление студента со всеми вытекающими
- (void) addStudent {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Новый студент" message:@"Введите данные" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Имя";
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Фамилия";
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }];
    
    UIAlertAction * buttonAdd = [UIAlertAction actionWithTitle:@"Добавить" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        //создание студента
        YSStudent * student = [NSEntityDescription insertNewObjectForEntityForName:@"YSStudent"
                                                            inManagedObjectContext:self.managedObjectContext];
        student.firstName = alert.textFields.firstObject.text;
        student.lastName = alert.textFields.lastObject.text;
        student.sex = NSNotFound;
        student.studio = self.studio;
        [student addPracticesObject:self.practice];
        
        //добавление студента в кор дату
        [[CoreDataManager sharedManager] saveContext];
        
        //добавление студента в массив
            //удаление первого объекта
        id firstObject = [self.studentArray objectAtIndex:0];
        [self.studentArray removeObjectAtIndex:0];
        
            //добавление студента
        [self.studentArray addObject:student];
        
            //сортировка массива по имени/фамилии
        [self sortedObjectsInArray:self.studentArray];
        
            //добавление первого объекта
        [self.studentArray insertObject:firstObject atIndex:0];
        
        
        //добавление студента в таблицу
            //поиск студента в массиве
        NSInteger indexObject = [self.studentArray indexOfObject:student];
        NSIndexPath * path = [NSIndexPath indexPathForRow:indexObject inSection:1];
        
            //бегин апдейт
        [self.tableView beginUpdates];
        
            //инсерт студента
        [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
        
            //енд апдейт
        [self.tableView endUpdates];
        
    }];
    
    UIAlertAction * buttonCancel = [UIAlertAction actionWithTitle:@"Отмена" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alert addAction:buttonAdd];
    [alert addAction:buttonCancel];
    
    [self presentViewController:alert animated:YES completion:^{
    }];
}


//добавление препода со всеми вытекающими
- (void) addTeacher {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Новый преподаватель" message:@"Введите данные" preferredStyle:(UIAlertControllerStyleAlert)];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Имя";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Фамилия";
    }];
    
    
    UIAlertAction * actionAdd = [UIAlertAction actionWithTitle:@"Добавить" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        //создание препода
        YSTeacher * teacher = [NSEntityDescription insertNewObjectForEntityForName:@"YSTeacher"
                                                            inManagedObjectContext:self.managedObjectContext];
        teacher.firstName = alert.textFields.firstObject.text;
        teacher.lastName = alert.textFields.lastObject.text;
        teacher.studio = self.studio;
        [teacher addPracticesObject:self.practice];
        teacher.sex = NSNotFound;
        
        
        //добавление препода в кор дату
        [[CoreDataManager sharedManager] saveContext];
        
        
        //добавление препода в массив
        //убираем первый объект из массива
        id firstObject = [self.teacherArray objectAtIndex:0];
        [self.teacherArray removeObjectAtIndex:0];
        
        //добавляем тичера
        [self.teacherArray addObject:teacher];
        
        //сортируем по именам
        [self sortedObjectsInArray:self.teacherArray];
        
        //добавляем первый объект
        [self.teacherArray insertObject:firstObject atIndex:0];
        
        //ищем объект и берем его индекс
        NSInteger indexObject = [self.teacherArray indexOfObject:teacher];
        
        
        //обновление таблицы
        //бегин  апдейт
        [self.tableView beginUpdates];
        
        //инсерт обджект
        NSIndexPath * path = [NSIndexPath indexPathForRow:indexObject inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
        
        //енд апдейт
        [self.tableView endUpdates];
    }];
    UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:@"Отмена" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alert addAction:actionAdd];
    [alert addAction:actionCancel];
    
    [self presentViewController:alert animated:YES completion:^{
    }];
}

//удаление человека со всеми вытекющими
- (void) deletePeopleAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Удаление студента");
    
    //определение человека
    if (indexPath.section == 0) {
        //удаление из кор даты
        YSTeacher * teacher = [self.teacherArray objectAtIndex:indexPath.row];
        [self.practice removeTeachersObject:teacher];
        
        //удаление из массива
        [self.teacherArray removeObjectAtIndex:indexPath.row];
        
    } else {
        //удаление из кор даты
        YSStudent * student  = [self.studentArray objectAtIndex:indexPath.row];
        [self.practice removeStudentsObject:student];
        
        //удаление массива
        [self.studentArray removeObjectAtIndex:indexPath.row];
        
    }

    //обновление таблицы
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

//установка large title перд закртыием вью
- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.prefersLargeTitles = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    /*
    if (self.isEditing) {
        [self saveInfo];
    }
     */
}


//сколько секций в таблице
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

//сколько ячеек в секциях
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.teacherArray.count;
    }
    return self.studentArray.count;
}

//какой стиль  редактирования у ячеек, в обычном режиме у всех стиль удаления
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCellEditingStyle style = UITableViewCellEditingStyleDelete;
    if ((indexPath.row == 0) & self.isEditing) {
        style = UITableViewCellEditingStyleInsert;
    }
    return style;
}


//отодвигать ли клетку в режиме редактирования
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//хедеры секций
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Преподаватели";
    }
    return @"Студенты";
}


//кнопка редактирования
- (void) editButton {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    self.isEditing = self.tableView.editing;
    
    [self.view endEditing:YES];
    
    if (self.isEditing) {
        
        
        self.descriptionLabel.layer.borderWidth = 1.f;
        UIColor * borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        self.descriptionLabel.layer.borderColor = borderColor.CGColor;
        self.descriptionLabel.layer.cornerRadius = 6.f;
        
        UIBarButtonItem * buttonDone = [[UIBarButtonItem alloc] initWithTitle:@"Готово"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self action:@selector(editButton)];
        [self.navigationItem setRightBarButtonItem:buttonDone animated:YES];
        
        self.nameLabel.userInteractionEnabled = YES;
        self.nameLabel.borderStyle = UITextBorderStyleRoundedRect;
        self.descriptionLabel.editable = YES;
        self.descriptionLabel.selectable = YES;
        
        
    } else {
        
        self.descriptionLabel.layer.borderWidth = 0.f;
        

        
        UIBarButtonItem * buttonEdit = [[UIBarButtonItem alloc] initWithTitle:@"Редактировать"
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self action:@selector(editButton)];
        [self.navigationItem setRightBarButtonItem:buttonEdit animated:YES];
        
        self.nameLabel.userInteractionEnabled = NO;
        self.nameLabel.borderStyle = UITextBorderStyleNone;
        self.descriptionLabel.editable = NO;
        self.descriptionLabel.selectable = NO;
        
        [self saveInfo];
    }
    
    //добавление строки
    NSString * stringTeacher = @"Добавить преподавателя...";
    NSString * stringStudent = @"Добавить студента...";
    
    NSInteger index = 0;
    
    NSIndexPath * pathTeacher = [NSIndexPath indexPathForRow:index inSection:0];
    NSIndexPath * pathStudent = [NSIndexPath indexPathForRow:index inSection:1];
    
    if (self.isEditing) {
        [self.teacherArray insertObject:stringTeacher atIndex:index];
        [self.studentArray insertObject:stringStudent atIndex:index];
        NSLog(@"begin editing");
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[pathTeacher, pathStudent] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
    } else {
        [self.teacherArray removeObjectAtIndex:index];
        [self.studentArray removeObjectAtIndex:index];
        NSLog(@"end editing");
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[pathTeacher, pathStudent] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

//при нажатии на ячейки
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0 & indexPath.section == 0 & self.isEditing) {;
        [self addTeacher];
        
    } else if (indexPath.row == 0 & indexPath.section == 1 & self.isEditing) {
        [self addStudent];
    }
}

//добавление или удаление по жестам
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deletePeopleAtIndexPath:indexPath];
        
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        if (indexPath.section == 0) {
            [self addTeacher];
        } else {
            [self addStudent];
        }
    }
}

//поддержка режима редактирования (выезд слева иконки)
- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return YES;
}


//берем array из свойств объекта кор даты и сортируем его мо имени/фамилии
- (NSArray *) sortedObjectsInArray:(NSArray *)array {
    NSMutableArray * mArray = [[NSMutableArray alloc] initWithArray:array];
    NSSortDescriptor * firstNameDiscriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
    NSSortDescriptor * lastNameDiscriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
    [mArray sortUsingDescriptors:@[firstNameDiscriptor, lastNameDiscriptor]];
    return mArray;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    if (self.descriptionLabel.text != 0) {
        self.placeholderLabel.alpha = 0.f;
    }
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (self.descriptionLabel.text.length == 0) {
        self.placeholderLabel.alpha = 1.f;
    }
    
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString * string1 = [textField.text stringByReplacingCharactersInRange:range withString:string];
    UIBarButtonItem * button = self.navigationItem.rightBarButtonItem;
    
    if (string1.length == 0) {
        button.enabled = NO;
    } else {
        button.enabled = YES;
    }
    
    return YES;
}

@end
