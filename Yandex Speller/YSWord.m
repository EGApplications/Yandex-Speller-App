//
//  YSWord.m
//  Yandex Speller
//
//  Created by Евгений Глухов on 11.10.15.
//  Copyright © 2015 Evgeny Glukhov. All rights reserved.
//

#import "YSWord.h"

@implementation YSWord

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.correctives = [NSArray array];
        self.position = 0;
        self.length = 0;
        
    }
    return self;
}

@end
