//
//  ViewController.m
//  YOGA Studios
//
//  Created by Clyde Barrow on 04.12.2017.
//  Copyright © 2017 Clyde Barrow. All rights reserved.
//

#import "ViewController.h"
#import "CoreDataManager.h"

#import "PeopleInfoViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //[[CoreDataManager sharedManager] setEntitysWithName:@"" StudentNamber:20];
    //[[CoreDataManager sharedManager] printEntitys];
    //[[CoreDataManager sharedManager] clearEntitys];
    //[[CoreDataManager sharedManager] printEntitys];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)adminButton:(id)sender {
    PeopleInfoViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"People"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)userButton:(id)sender {
}
@end
