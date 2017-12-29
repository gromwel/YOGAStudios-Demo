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

@interface StudentTableViewController ()

@property (nonatomic, strong) UIBarButtonItem * rightButton;

@end


@implementation StudentTableViewController
@synthesize fetchedResultsController = _fetchedResultsController;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"student");
    self.parentViewController.navigationItem.title = @"СТУДЕНТЫ";
    
    UISearchController * controller = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.parentViewController.navigationItem.searchController = controller;
    
    
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightAddButton)];
    self.rightButton = rightButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) rightAddButton {
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Новый студент" message:@"Введите данные" preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Имя";
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Фамилия";
    }];
    
    
    UIAlertAction * buttonAdd = [UIAlertAction actionWithTitle:@"Добавить" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        [[CoreDataManager sharedManager] addStudentWithFirstName:alert.textFields.firstObject.text
                                                        LastName:alert.textFields.lastObject.text
                                                          Studio:self.studio
                                                        Practice:nil];
        [self.tableView reloadData];
        
    }];
    
    UIAlertAction * buttonCancel = [UIAlertAction actionWithTitle:@"Отмена" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:buttonAdd];
    [alert addAction:buttonCancel];
    
    [self presentViewController:alert animated:YES completion:^{
    }];
    
    NSLog(@"STUDENT");
}


- (void)viewDidAppear:(BOOL)animated {
    self.parentViewController.navigationItem.title = @"СТУДЕНТЫ";
    self.parentViewController.navigationItem.rightBarButtonItem = self.rightButton;
}

- (void)viewWillAppear:(BOOL)animated {
    //self.navigationController.navigationBar.prefersLargeTitles = YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    //если удаление
    //NSLog(@"удаление");

    if (editingStyle == UITableViewCellEditingStyleDelete) {
    
        YSStudent * student = [self.fetchedResultsController objectAtIndexPath:indexPath];
        student.studio = nil;
        
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    
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
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"YSStudent" inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"studio == %@", self.studio];
    [fetchRequest setPredicate:predicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
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

- (void)configureCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    
    YSStudent * student = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", student.firstName, student.lastName];
    
    //cell.detailTextLabel.text = @"info";
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo name];
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    YSStudent * student = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    PeopleInfoViewController * vc = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"People"];
    vc.entity = student;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}


@end
