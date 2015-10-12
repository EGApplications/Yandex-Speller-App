//
//  ViewController.m
//  Yandex Speller
//
//  Created by Евгений Глухов on 06.10.15.
//  Copyright © 2015 Evgeny Glukhov. All rights reserved.
//

#import "YSViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "YSServerManager.h"
#import "YSWord.h"

@interface YSViewController ()

@property (strong, nonatomic) NSMutableAttributedString* stringToCorrect;
@property (strong, nonatomic) NSMutableArray* wordsAndCorrectives; // (YSWord)
@property (strong, nonatomic) UIFont* textViewFont;
@property (strong, nonatomic) NSMutableArray* words;
@property (strong, nonatomic) NSMutableArray* rangesOfWords;

@end

@implementation YSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.wordsAndCorrectives = [NSMutableArray array];
    self.words = [NSMutableArray array];
    self.rangesOfWords = [NSMutableArray array];
    
    self.textViewFont = [UIFont fontWithName:@".SFUIText-Regular" size:16.f];
    
    UISwipeGestureRecognizer* swipeKeyboard = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    
    swipeKeyboard.direction = UISwipeGestureRecognizerDirectionDown;
    
    [self.view addGestureRecognizer:swipeKeyboard];
    
    [self.mainTextView becomeFirstResponder];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showMistakesRedColored {
    
    self.stringToCorrect = [[NSMutableAttributedString alloc]initWithString:self.mainTextView.text];
    
    for (NSValue* rangeValue in self.rangesOfWords) {
        
        NSRange range = [rangeValue rangeValue];
        
        [self.stringToCorrect addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
        
    }
    
    [self.mainTextView setAttributedText:self.stringToCorrect];
    
    self.mainTextView.font = self.textViewFont;
    
}

#pragma mark - Actions

- (IBAction)showMistakesAction:(UIButton *)sender {
    
//    NSString* exampleText = @"Привед, какк дела? А синхрафазатрон находится в дубне, или это Яндекс Спеллер рабатает?";
//    
//    [self.mainTextView setText:exampleText];
    
    self.mainTextView.font = self.textViewFont;
    
    [[YSServerManager sharedManager] getCorrectText:self.mainTextView.text
                                          onSuccess:^(NSString *correctText, NSArray* rangesOfWords, NSMutableArray* wordsAndCorrectives) {
                                              
                                              self.wordsAndCorrectives = wordsAndCorrectives;
                                              self.rangesOfWords = (NSMutableArray*)rangesOfWords;
                                              
                                              self.stringToCorrect = [[NSMutableAttributedString alloc]initWithString:correctText];
                                              
                                              for (NSValue* rangeValue in rangesOfWords) {
                                                  
                                                  NSRange range = [rangeValue rangeValue];
                                                  
                                                  [self.stringToCorrect addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
                                                  
                                              }
                                              
                                              [self.mainTextView setAttributedText:self.stringToCorrect];

                                              self.mainTextView.font = self.textViewFont;
                                              
                                              [self.tableView reloadData];
                                              
                                              NSLog(@"SUCCESS");
                                              
                                          }
                                          onFailure:^(NSString *fail) {
                                              
                                              
                                             UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"ERROR" message:fail preferredStyle:UIAlertControllerStyleAlert];
                                              
                                             UIAlertAction* OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                                                    handler:^(UIAlertAction * action) {}];
                                              
                                              [alert addAction:OKAction];
                                              
                                              [self presentViewController:alert animated:YES completion:nil];
                                              
                                          }];
    

    
    
}

- (void) hideKeyboard:(UISwipeGestureRecognizer*) gesture {
    
    [self.mainTextView resignFirstResponder];
    
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {

    return YES;
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableArray* indexPathArray = [NSMutableArray array];
    
    YSWord* element = [self.wordsAndCorrectives objectAtIndex:indexPath.row];
    
    if ([element.option isEqualToString:@"showCorrective"]) {
        
        NSArray* words = [NSArray array];
        
        NSString* corrective;
        
        NSInteger index = 0;
        
        NSCharacterSet* textSignsSet = [NSCharacterSet punctuationCharacterSet];
        
        words = [self.mainTextView.text componentsSeparatedByString:@" "];
            
        for (NSString* word in words) {
                
            if ([word containsString:element.initialWord]) {
                
                index = [words indexOfObject:word];
                
                NSRange characterRange = [word rangeOfCharacterFromSet:textSignsSet];
                
                if (characterRange.location != NSNotFound) {
                    
                    unichar ch = [word characterAtIndex:characterRange.location];
                    
                    NSString* charString = [NSString stringWithCharacters:&ch length:1];
                    
                    corrective = [NSString stringWithFormat:@"%@%@", element.corrective, charString];
                    
                } else {
                    
                    corrective = element.corrective;
                    
                }
                
            }
                
        }
        
        NSMutableArray* tempArray = [NSMutableArray arrayWithArray:words];
        
        [tempArray removeObject:[words objectAtIndex:index]];
        
        [tempArray insertObject:corrective atIndex:index];
        
        words = tempArray;
        
        NSString* result = [words componentsJoinedByString:@" "];
        
        [self.mainTextView setText:result];

        
        self.stringToCorrect = [[NSMutableAttributedString alloc]initWithString:self.mainTextView.text];
        
        NSRange correctiveRange = NSMakeRange(element.position, element.length);
            
        [self.stringToCorrect addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:correctiveRange];
        
        [self.mainTextView setAttributedText:self.stringToCorrect];
        
        self.mainTextView.font = self.textViewFont;
        
        NSValue* clearRange;
        
        for (NSValue* rangeValue in self.rangesOfWords) {
            
            NSRange range = [rangeValue rangeValue];
            
            if (range.location == element.position && range.length == [element.initialWord length]) {
                
                clearRange = rangeValue;
                
            }
            
        }
        
        [self.rangesOfWords removeObject:clearRange];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.stringToCorrect addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:correctiveRange];
            
            [self.mainTextView setAttributedText:self.stringToCorrect];
            
            self.mainTextView.font = self.textViewFont;
            
            [self showMistakesRedColored];
            
        });
        
    } else if ([element.option isEqualToString:@"CorrectivesOfElementShown"]) {
        
        element.option = @"CorrectivesOfElementHidden";
        
        NSInteger indexOfClickedElement = [self.wordsAndCorrectives indexOfObject:element];
        int correctivesCount = (int)[element.correctives count];
        
        NSMutableArray* deletingIndexPaths = [NSMutableArray array];
        
        for (int i = correctivesCount; i > 0; i--) {
            
            [self.wordsAndCorrectives removeObjectAtIndex:indexOfClickedElement + i];
            
            NSIndexPath* deletingCorrectivesIndexPath = [NSIndexPath indexPathForRow:indexOfClickedElement + i inSection:0];
            
            [deletingIndexPaths addObject:deletingCorrectivesIndexPath];
            
        }
        
        NSArray* array = deletingIndexPaths;
        
        [self showMistakesRedColored];
        
        [tableView beginUpdates];
        
        [tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationLeft];
        
        [tableView endUpdates];
        
        
    } else { // option - correctives of Element hidden
        
        element.option = @"CorrectivesOfElementShown";
        
        NSRange initialWordRange = NSMakeRange(element.position, element.length);
        
        [self.stringToCorrect addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:initialWordRange];
        
        [self.mainTextView setAttributedText:self.stringToCorrect];
        
        self.mainTextView.font = self.textViewFont;
        
        for (int i = 0; i < [element.correctives count]; i++) {
            
            YSWord* correctiveElement = [[YSWord alloc] init];
            
            correctiveElement.option = @"showCorrective";
            
            correctiveElement.corrective = [element.correctives objectAtIndex:i];
            
            correctiveElement.position = element.position;
            correctiveElement.length = [correctiveElement.corrective length];
            
            correctiveElement.initialWord = element.initialWord;
            
            [self.wordsAndCorrectives insertObject:correctiveElement atIndex:indexPath.row + 1];
            
            NSIndexPath* correctiveIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 + i inSection:0];
            
            [indexPathArray addObject:correctiveIndexPath];
            
        }
        
        NSArray* array = indexPathArray;
        
        [tableView beginUpdates];
        
        [tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationRight];
        
        [tableView endUpdates];
        
    }
    
}

#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    NSLog(@"MOVE");
    
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString* header = @"Ошибки в тексте";
    
    return header;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.wordsAndCorrectives count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* initialWordIdentifier = @"initialWord";
    static NSString* correctiveIdentifier = @"corrective";
    
    YSWord* element = [self.wordsAndCorrectives objectAtIndex:indexPath.row];
    
    if ([element.option isEqualToString:@"showCorrective"]) {
        
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:correctiveIdentifier];
        
        cell.textLabel.text = element.corrective;
        
        cell.textLabel.textColor = [UIColor greenColor];
        
        return cell;
        
    } else {
        
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:initialWordIdentifier];
        
        YSWord* element = [self.wordsAndCorrectives objectAtIndex:indexPath.row];
        
        cell.textLabel.text = element.initialWord;

        return cell;
        
    }
    
    return nil;
    
}

@end
