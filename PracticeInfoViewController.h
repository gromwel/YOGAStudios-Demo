//
//  PracticeInfoViewController.h
//  YOGA Studios
//
//  Created by Clyde Barrow on 18.12.2017.
//  Copyright © 2017 Clyde Barrow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSStudio+CoreDataClass.h"

@interface PracticeInfoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@property (weak, nonatomic) IBOutlet UITextField *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionLabel;

@property (nonatomic, strong) id entity;

@property (nonatomic,strong) YSStudio * studio;

@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;



//frc
@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;

@end
