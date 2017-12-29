//
//  InfoViewController.h
//  YOGA Studios
//
//  Created by Clyde Barrow on 17.12.2017.
//  Copyright © 2017 Clyde Barrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeopleInfoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UITextField *firstNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *lastNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *ageLabel;

@property (nonatomic, strong) NSManagedObjectContext * managedObgectContext;

@property (nonatomic, strong) id entity;

@end
