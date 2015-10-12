//
//  YSServerManager.m
//  Yandex Speller
//
//  Created by Евгений Глухов on 06.10.15.
//  Copyright © 2015 Evgeny Glukhov. All rights reserved.
//

#import "YSServerManager.h"
#import "AFHTTPRequestOperationManager.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "YSWord.h"

@interface YSServerManager ()

@property (strong, nonatomic) NSString* textToCorrect;
@property (strong, nonatomic) NSString* resultText;

@end

@implementation YSServerManager

+ (YSServerManager*) sharedManager {
    
    // синглтон
    
    static YSServerManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[YSServerManager alloc] init];
        
    });
    
    return manager;
    
}

- (void) getCorrectText:(NSString*) text
              onSuccess:(void(^)(NSString* correctText, NSArray* rangeOfWords, NSMutableArray* wordsAndCorrectives)) success
              onFailure:(void(^)(NSString* fail)) failure {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    self.textToCorrect = text;
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:text, @"text", nil];
    
    [manager GET:@"https://speller.yandex.net/services/spellservice.json/checkText" parameters:params success:^(AFHTTPRequestOperation *operation, NSArray* responseObject) {
        
        // NSRanges слов для подсвечивания
        NSMutableArray* rangesOfWords = [NSMutableArray array];
        
        NSMutableArray* wordsAndCorrectives = [NSMutableArray array];
        
        NSString *initialWord;
        NSMutableArray* correctTextArray = [NSMutableArray array];
        NSInteger pos, len;
        
        if ([responseObject count] > 0) {
            
            for (NSDictionary* object in responseObject) {
                
                // исходный текст в self.textToCorrect
                
                YSWord* element = [[YSWord alloc] init];
                
                // Исправленное слово
                correctTextArray = [NSMutableArray arrayWithObjects:[object objectForKey:@"s"], nil];

                NSArray* correctivesArray = [correctTextArray firstObject];
                
                element.correctives = correctivesArray;
                
                // Позиция слова с ошибкой
                NSNumber* position = [object objectForKey:@"pos"];
                
                pos = [position integerValue];
                
                element.position = pos;
                
                // Длина слова с ошибкой
                NSNumber* length = [object objectForKey:@"len"];
                
                len = [length integerValue];
                
                element.length = len;
                
                // Исходное слово
                initialWord = [object objectForKey:@"word"];
                
                element.initialWord = initialWord;
                
                if ([correctTextArray count] > 0) {
                    // Если есть исправленное слово, берем исходное, подсвечиваем.

                    NSArray* words = [self.textToCorrect componentsSeparatedByString:@" "];
                    
                    for (NSString *word in words) {
                        
                        if ([word containsString:initialWord]) {
                            
                            // Передаем NSRange для подсвечивания слов и массив YSWord
                            
                            NSRange range = [self.textToCorrect rangeOfString:initialWord];
                            
                            [rangesOfWords addObject:[NSValue valueWithRange:range]];
                            
                            [wordsAndCorrectives addObject:element];
                            
                        }
                        
                    }
                    
                }
                
                
                [correctTextArray removeAllObjects];
                
            }
            
        }
        
        
        if (success) {
            
            success(self.textToCorrect, rangesOfWords, wordsAndCorrectives);
            
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) {
            
            failure([error localizedDescription]);
            
        }
        
    }];

    
    
}

@end
