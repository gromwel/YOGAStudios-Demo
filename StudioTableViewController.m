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

//#import "YSPractice+CoreDataClass.h"


@interface StudioTableViewController ()

@end

@implementation StudioTableViewController
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[[CoreDataManager sharedManager] printEntitys];
    self.navigationItem.title = @"СТУДИИ";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    
    
//    [[CoreDataManager sharedManager] clearEntitys];
//    [[CoreDataManager sharedManager] setEntitysWithName:@"formula YOGA" StudentNamber:20];
//    [[CoreDataManager sharedManager] setEntitysWithName:@"Анахата" StudentNamber:30];
//    [[CoreDataManager sharedManager] setEntitysWithName:@"World Gym" StudentNamber:10];

    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemAdd) target:self action:@selector(rightButton)];
}


- (void) rightButton {
//    [[CoreDataManager sharedManager] setEntitysWithName:[NSString stringWithFormat:@"%i", arc4random()%999999999 + 1000000] StudentNamber:arc4random()%10 + 10];
//    [self.tableView reloadData];
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Новая студия" message:@"Введите название студии" preferredStyle:(UIAlertControllerStyleAlert)];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Имя новой студии";
    }];
    
    
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"Создать" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField * field = alert.textFields.firstObject;
        
        if ([field.text isEqualToString:@""]) {
            NSLog(@"Не создаем");
        } else {
            [[CoreDataManager sharedManager] setEntitysWithName:field.text StudentNamber:arc4random()%10 + 10];
            [self.tableView reloadData];
        }
        
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alert addAction:action];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //если удаление
    NSLog(@"удаление");
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
                NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
                [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
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
    
    NSLog(@"fetchedResultsController");
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"YSStudio" inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    
    
//    NSArray * arr = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
//    NSLog(@"STUIOS = %li", arr.count);
//    for (YSStudio * st in arr) {
//        NSLog(@"st = %@", st.name);
//        NSLog(@"p = %li", st.practices.allObjects.count);
//    }
    
    
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


//формирование ячейки
- (void)configureCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"configure");
    
    YSStudio * studio = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", studio.name];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%li ПРАКТИК", studio.practices.allObjects.count];
}


//тайтл
//- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//
//    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
//    return [sectionInfo name];
//}


//
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITabBarController * tabBar = [[UITabBarController alloc] init];
    
    
    UIBarButtonItem * rightBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:nil];
    tabBar.navigationItem.rightBarButtonItem = rightBar;
    
    
    
    
    
    YSStudio * studio = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSLog(@"%@", studio.name);
    
    TeacherTableViewController * vc1 = [[TeacherTableViewController alloc] init];
    vc1.studio = studio;
    vc1.tabBarItem.title = @"ПРЕПОДАВАТЕЛИ";
    vc1.tabBarItem.image = [UIImage imageNamed:@"teachers.png"];
    
    StudentTableViewController * vc2 = [[StudentTableViewController alloc] init];
    vc2.studio = studio;
    vc2.tabBarItem.title = @"СТУДЕНТЫ";
    vc2.tabBarItem.image = [UIImage imageNamed:@"students.png"];
        
    PracticeTableViewController * vc3 = [[PracticeTableViewController alloc] init];
    vc3.studio = studio;
    vc3.tabBarItem.title = @"ПРАКТИКИ";
    UIImage * im3 = [UIImage imageNamed:@"practices.png"];
    
    vc3.tabBarItem.image = im3;
    
    [tabBar setViewControllers:@[vc3, vc1, vc2]];
    [tabBar setSelectedViewController:vc3];
    
    [self.navigationController pushViewController:tabBar animated:YES];
    

    /*
    if (self.segmentControl.selectedSegmentIndex == 0) {
        PracticeTableViewController * vc = [[PracticeTableViewController alloc] init];
        vc.studio = studio;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (self.segmentControl.selectedSegmentIndex == 1) {
        TeacherTableViewController * vc = [[TeacherTableViewController alloc] init];
        vc.studio = studio;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (self.segmentControl.selectedSegmentIndex == 2) {
        StudentTableViewController * vc = [[StudentTableViewController alloc] init];
        vc.studio = studio;
        [self.navigationController pushViewController:vc animated:YES];
    }
    */
    
}





@end
