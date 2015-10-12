//
//  YSWord.h
//  Yandex Speller
//
//  Created by Евгений Глухов on 11.10.15.
//  Copyright © 2015 Evgeny Glukhov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSWord : NSObject

@property (strong, nonatomic) NSString* initialWord;
@property (assign, nonatomic) NSInteger position;
@property (assign, nonatomic) NSInteger length;
@property (strong, nonatomic) NSArray* correctives;

@property (strong, nonatomic) NSString* option;
@property (strong, nonatomic) NSString* corrective;

@end
