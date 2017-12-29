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


@interface PeopleInfoViewController () <UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) NSString * peopleType;
@property (nonatomic, strong) NSMutableArray * practicesArray;

@property (nonatomic, strong) YSStudio * studio;

@property (nonatomic, assign) BOOL isEditing;

@end

@implementation PeopleInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.prefersLargeTitles = NO;

    self.isEditing = NO;
    
    
    if ([self.entity isKindOfClass:[YSTeacher class]]) {
        
        self.photoImageView.image = [UIImage imageNamed:@"teacher_pink.png"];
        
        YSTeacher * teacher = (YSTeacher *)self.entity;
        self.firstNameLabel.text = teacher.firstName;
        self.lastNameLabel.text = teacher.lastName;
        
        if (teacher.age) {
            self.ageLabel.text = [NSString stringWithFormat:@"%i лет", teacher.age];
        }
        
        
        self.practicesArray = [[NSMutableArray alloc] initWithArray:[self sortedObjectsInArray:teacher.practices.allObjects]];
        
        if (teacher.sex == 1) {
            self.photoImageView.image = [UIImage imageNamed:@"teacher_blue.png"];
        } else if (teacher.sex == NSNotFound) {
            NSLog(@"ЧТО это за пол");
        }
        
        self.studio = teacher.studio;
        
    } else if ([self.entity isKindOfClass:[YSStudent class]]) {
        
        self.photoImageView.image = [UIImage imageNamed:@"student_pink.png"];
        
        YSStudent * student = (YSStudent *)self.entity;
        self.firstNameLabel.text = student.firstName;
        self.lastNameLabel.text = student.lastName;
        
        if (student.age) {
            self.ageLabel.text = [NSString stringWithFormat:@"%i лет", student.age];
        }
        
        self.practicesArray = [[NSMutableArray alloc] initWithArray:[self sortedObjectsInArray:student.practices.allObjects]];
        
        if (student.sex == YES) {
            self.photoImageView.image = [UIImage imageNamed:@"student_blue.png"];
        }
        
        self.studio = student.studio;
    }
    
    
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Редактировать" style:UIBarButtonItemStylePlain target:self action:@selector(editButton)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    
    
    self.tableView.allowsSelectionDuringEditing = YES;
    
    
    self.firstNameLabel.borderStyle = UITextBorderStyleNone;
    self.firstNameLabel.userInteractionEnabled = NO;
    
    self.lastNameLabel.borderStyle = UITextBorderStyleNone;
    self.lastNameLabel.userInteractionEnabled = NO;
    
    self.ageLabel.borderStyle = UITextBorderStyleNone;
    self.ageLabel.userInteractionEnabled = NO;
}


- (NSManagedObjectContext *) managedObgectContext {
    if (!_managedObgectContext) {
        _managedObgectContext = [[[CoreDataManager sharedManager] persistentContainer] viewContext];
    }
    return _managedObgectContext;
}

- (void) saveInfo {
    
    if ([self.entity isKindOfClass:[YSTeacher class]]) {
        NSLog(@"TEACHER TEACHER");
        YSTeacher * teacher = (YSTeacher *)self.entity;
        teacher.firstName = self.firstNameLabel.text;
        teacher.lastName = self.lastNameLabel.text;
        
        
    } else if ([self.entity isKindOfClass:[YSStudent class]]) {
        NSLog(@"STUDENT STUDENT");
        YSStudent * student = (YSStudent *)self.entity;
        student.firstName = self.firstNameLabel.text;
        student.lastName = self.lastNameLabel.text;
        
        
    }
    
    [[CoreDataManager sharedManager] saveContext];
}

- (void) editButton {
    NSLog(@"edit button");
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    [self.view endEditing:YES];
    
    
    
    if (self.tableView.editing) {
        UIBarButtonItem * buttonDone = [[UIBarButtonItem alloc] initWithTitle:@"Готово"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self action:@selector(editButton)];
        [self.navigationItem setRightBarButtonItem:buttonDone animated:YES];
        
        self.firstNameLabel.borderStyle = UITextBorderStyleRoundedRect;
        self.firstNameLabel.userInteractionEnabled = YES;
        
        self.lastNameLabel.borderStyle = UITextBorderStyleRoundedRect;
        self.lastNameLabel.userInteractionEnabled = YES;
        
        self.ageLabel.borderStyle = UITextBorderStyleRoundedRect;
        self.ageLabel.userInteractionEnabled = YES;
        
    } else {
        
        [self saveInfo];
        
        UIBarButtonItem * buttonEdit = [[UIBarButtonItem alloc] initWithTitle:@"Редактировать"
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self action:@selector(editButton)];
        [self.navigationItem setRightBarButtonItem:buttonEdit animated:YES];
        
        
        self.firstNameLabel.borderStyle = UITextBorderStyleNone;
        self.firstNameLabel.userInteractionEnabled = NO;
        
        self.lastNameLabel.borderStyle = UITextBorderStyleNone;
        self.lastNameLabel.userInteractionEnabled = NO;
        
        self.ageLabel.borderStyle = UITextBorderStyleNone;
        self.ageLabel.userInteractionEnabled = NO;
    }
    
    //добавление строки
    NSString * firstObject = @"Добавить практику";
    NSInteger index = 0;
    NSIndexPath * path = [NSIndexPath indexPathForRow:index inSection:0];
    
    if (!self.isEditing) {
        self.isEditing = YES;
        [self.practicesArray insertObject:firstObject atIndex:index];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
        
        
    } else {
        self.isEditing = NO;
        [self.practicesArray removeObjectAtIndex:index];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
    }
    
}



- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"viewWillDisappear");
    self.navigationController.navigationBar.prefersLargeTitles = YES;
}


- (void)viewDidDisappear:(BOOL)animated {
    /*
    NSLog(@"viewDidDisappear");
    if (self.isEditing) {
        [self saveInfo];
    }
     */
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deletePracticeAtIndexPath:indexPath];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self addPractice];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString * string1 = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    
    BOOL buttonEnable = YES;
    
    if ([textField.restorationIdentifier isEqualToString:@"firstName"]) {
        buttonEnable = (string1.length == 0) | (self.lastNameLabel.text.length == 0);
        
    } else if ([textField.restorationIdentifier isEqualToString:@"lastName"]) {
        buttonEnable = (string1.length == 0) | (self.firstNameLabel.text.length == 0);
        
    }
    
    self.navigationItem.rightBarButtonItem.enabled = !buttonEnable;
    
    
    return YES;
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.practicesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * identififer = @"Cell";
    
    UITableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:identififer];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identififer];
    }
    
    if (self.isEditing) {
        NSLog(@"редактирование");
        if (indexPath.row == 0) {
            NSString * string = [self.practicesArray objectAtIndex:indexPath.row];
            cell.textLabel.text = string;
        } else {
            YSPractice * practice = [self.practicesArray objectAtIndex:indexPath.row];
            cell.textLabel.text = practice.name;
        }
        
        
    } else {
        NSLog(@"не редактирование");
        YSPractice * practice = [self.practicesArray objectAtIndex:indexPath.row];
        cell.textLabel.text = practice.name;
    }
    
    
    return cell;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCellEditingStyle style = UITableViewCellEditingStyleDelete;
    
    if ((indexPath.row == 0) & self.isEditing) {
        style = UITableViewCellEditingStyleInsert;
    }
    
    return style;
}


- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Практики";
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if ((indexPath.row == 0) & self.isEditing) {
        [self addPractice];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void) addPractice {
    id object = nil;
    
    if ([self.entity isKindOfClass:[YSTeacher class]]) {
        NSLog(@"add teacher");
        object = (YSTeacher *)self.entity;
        
        
    } else if ([self.entity isKindOfClass:[YSStudent class]]) {
        NSLog(@"add student");
        object = (YSStudent *)self.entity;
        
        
    }
    
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Добавление практики" message:@"Введите название практики" preferredStyle:(UIAlertControllerStyleAlert)];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Название практики";
    }];
    
    UIAlertAction * actionDone = [UIAlertAction actionWithTitle:@"Добавить" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        YSPractice * practice = [NSEntityDescription insertNewObjectForEntityForName:@"YSPractice" inManagedObjectContext:self.managedObgectContext];
        practice.name = alert.textFields.firstObject.text;
        [practice addStudiosObject:self.studio];
        [object addPracticesObject:practice];
        
        NSInteger index = 0;
        
        
        id firstObject = [self.practicesArray objectAtIndex:index];
        [self.practicesArray removeObjectAtIndex:index];
        
        [self.practicesArray addObject:practice];
        
        self.practicesArray = [[NSMutableArray alloc] initWithArray:[self sortedObjectsInArray:self.practicesArray]];
        
        [self.practicesArray insertObject:firstObject atIndex:index];
        
        NSInteger newIndex = [self.practicesArray indexOfObject:practice];
        NSIndexPath * path = [NSIndexPath indexPathForRow:newIndex inSection:0];
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
        
        
    }];
    UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alert addAction:actionDone];
    [alert addAction:actionCancel];
    
    [self presentViewController:alert animated:YES completion:^{
    }];
    
    
}


- (void) deletePracticeAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"delete sextion %@", indexPath);
}


- (NSArray *) sortedObjectsInArray:(NSArray *)array {
    NSMutableArray * mArray = [[NSMutableArray alloc] initWithArray:array];
    NSSortDescriptor * nameDiscriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [mArray sortUsingDescriptors:@[nameDiscriptor]];
    return mArray;
}


@end
