//
//  YSServerManager.h
//  Yandex Speller
//
//  Created by Евгений Глухов on 06.10.15.
//  Copyright © 2015 Evgeny Glukhov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSServerManager : NSObject

+ (YSServerManager*) sharedManager;

- (void) getCorrectText:(NSString*) text
              onSuccess:(void(^)(NSString* correctText, NSArray* rangesOfWords, NSMutableArray* wordsAndCorrectives)) success
              onFailure:(void(^)(NSString* fail)) failure;


@end
