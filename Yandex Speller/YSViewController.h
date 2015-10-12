//
//  ViewController.h
//  Yandex Speller
//
//  Created by Евгений Глухов on 06.10.15.
//  Copyright © 2015 Evgeny Glukhov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSViewController : UIViewController <UITextViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UITextView *mainTextView;
@property (weak, nonatomic) IBOutlet UIButton *showMistakesButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;


- (IBAction)showMistakesAction:(UIButton *)sender;

@end

