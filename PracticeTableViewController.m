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

@interface PracticeTableViewController ()

@property (nonatomic, strong) UIBarButtonItem * rightButton;

@end

@implementation PracticeTableViewController
@synthesize fetchedResultsController = _fetchedResultsController;


- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSLog(@"ведомый viewDidLoad");
    self.parentViewController.navigationItem.title = @"ПРАКТИКИ";


    
    UISearchController * searchBar = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.parentViewController.navigationItem.searchController = searchBar;
    
    
    //add button
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightAddButton)];
    self.rightButton = rightButton;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    self.parentViewController.navigationItem.title = @"ПРАКТИКИ";
    
    self.parentViewController.navigationItem.rightBarButtonItem = self.rightButton;
}


- (void) rightAddButton {
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Новая практика" message:@"Введите название практики" preferredStyle:(UIAlertControllerStyleAlert)];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Название практики";
    }];
    
    UIAlertAction * actionAdd = [UIAlertAction actionWithTitle:@"Добавить" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[CoreDataManager sharedManager] addPracticeWithName:alert.textFields.firstObject.text Studio:self.studio];
        [self.tableView reloadData];
    }];
    UIAlertAction * actionClose = [UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alert addAction:actionAdd];
    [alert addAction:actionClose];
    
    [self presentViewController:alert animated:YES completion:^{
    }];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"ведомый commitEditingStyle");
    //если удаление
    NSLog(@"удаление");
    
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        YSPractice * practice = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        [practice removeStudiosObject:self.studio];
        
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
    NSLog(@"ведомый fetchedResultsController");
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"YSPractice" inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    
    //отсеиваем практики по студии
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"studios contains %@", self.studio];
    [fetchRequest setPredicate:predicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    //Сортируем по имени
    NSSortDescriptor *sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];

    
    [fetchRequest setSortDescriptors:@[sortDescriptorName]];
    
    
    NSArray * array = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    for (YSPractice * practice in array) {
        NSLog(@"fr %@", practice.name);
    }
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:self.managedObjectContext
                                                                                                  sectionNameKeyPath:nil
                                                                                                           cacheName:nil];
    aFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    NSLog(@"ведомый performFetch");
    if (![aFetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    NSLog(@"ведомый после performFetch");
    
    
    NSArray * performObject = aFetchedResultsController.fetchedObjects;
    for (YSPractice * object in performObject) {
        NSLog(@"frc %@", object.name);
    }
    
    
    
    _fetchedResultsController = aFetchedResultsController;
    return _fetchedResultsController;
}


//собираем ячейку
- (void)configureCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"ведомый withIndexPath");
    YSPractice * practice = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = practice.name;
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"info"];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo name];

}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PracticeInfoViewController * vc = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"Practice"];
    
    YSPractice * practice = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    vc.entity = practice;
    vc.studio = self.studio;
    
    [self.navigationController pushViewController:vc animated:YES];
}


//- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
//    return @"5 практик";
//}

@end
