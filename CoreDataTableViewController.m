//
//  CoreDataTableViewController.m
//  YOGA Studios
//
//  Created by Clyde Barrow on 05.12.2017.
//  Copyright © 2017 Clyde Barrow. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "CoreDataManager.h"

@interface CoreDataTableViewController () <NSFetchedResultsControllerDelegate>

@end

@implementation CoreDataTableViewController


#pragma mark - ManagedObjectContext
- (NSManagedObjectContext *) managedObjectContext {
    NSLog(@"ведущий managedObjectContext");

    if (!_managedObjectContext) {
        _managedObjectContext = [[[CoreDataManager sharedManager] persistentContainer] viewContext];
    }
    return _managedObjectContext;
}


- (void)insertNewObject:(id)sender {
    NSLog(@"ведущий insertNewObject");
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    //Event *newEvent = [[Event alloc] initWithContext:context];
    
    // If appropriate, configure the new managed object.
    //newEvent.timestamp = [NSDate date];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}


#pragma mark - Table View
- (NSFetchedResultsController *)fetchedResultsController {
    NSLog(@"ведущий fetchedResultsController");
    return nil;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"ведущий numberOfSectionsInTableView");
    //NSLog(@"numberOfSectionsInTableView");
    NSInteger count = [[self.fetchedResultsController sections] count];
    //NSLog(@"%li", count);
    return count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"ведущий numberOfRowsInSection");
    //NSLog(@"numberOfRowsInSection %li", section);
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    //NSLog(@"%li", [sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"ведущий cellForRowAtIndexPath");
    //NSLog(@"cellForRowAtIndexPath");
    
    static NSString * identifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    //Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //[self configureCell:cell withEvent:event];
    [self configureCell:cell withIndexPath:indexPath];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"ведущий canEditRowAtIndexPath");
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //если удаление
    NSLog(@"ведущий commitEditingStyle");
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


//- (void)configureCell:(UITableViewCell *)cell withEvent:(Event *)event {
//    cell.textLabel.text = event.timestamp.description;
//}


- (void)configureCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"ведущий configureCell");
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSLog(@"ведущий moveRowAtIndexPath");
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"ведущий canMoveRowAtIndexPath");
    return nil;
}


#pragma mark - Fetched results controller
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    NSLog(@"ведущий controllerWillChangeContent");
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    NSLog(@"ведущий didChangeSection");
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            return;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    NSLog(@"ведущий didChangeObject");
    UITableView *tableView = self.tableView;
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] withIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSLog(@"ведущий controllerDidChangeContent");
    [self.tableView endUpdates];
}

@end
