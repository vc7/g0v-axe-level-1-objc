//
//  main.m
//  axeLevel01
//
//  Created by vincent on 2014/04/22.
//  Copyright (c) 2014年 vc7. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        static NSString *url = @"http://axe-level-1.herokuapp.com/";
        
        NSURLRequest    *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSURLResponse   *response;
        NSError         *requestError;
        
        NSData *receivedData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&response
                                                                 error:&requestError];
        
        if ( ! requestError) {
            
            NSString *pageContent = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            
            // Regex
            
            NSString *regexPattern = @"<tr>\\s*<td>(.*)</td>\\s*<td>(.*)</td>\\s*<td>(.*)</td>\\s*<td>(.*)</td>\\s*<td>(.*)</td>\\s*<td>(.*)</td>\\s*</tr>";
            NSError  *regexError;
            NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:regexPattern
                                                                              options:NSRegularExpressionUseUnixLineSeparators
                                                                                error:&regexError];
            
            if ( ! regexError) {
                
                NSMutableArray *keyNameArray  = [NSMutableArray array];
                NSMutableArray *resultArray   = [NSMutableArray array];
                
                NSArray        *matchesArray  = [regex matchesInString:pageContent options:0 range:NSMakeRange(0, [pageContent length])];
                
                [matchesArray enumerateObjectsUsingBlock:^(NSTextCheckingResult *match, NSUInteger matchesArrayIndex, BOOL *stop) {
                    
                    NSMutableDictionary *personDictionary = [NSMutableDictionary dictionary];
                    NSMutableDictionary *gradesDictionary = [NSMutableDictionary dictionary];
                    
                    for (NSInteger matchIndex = 1; matchIndex < match.numberOfRanges; matchIndex++) {
                        
                        NSString *resultString = [pageContent substringWithRange:[match rangeAtIndex:matchIndex]];
                        
                        if (matchesArrayIndex > 0) {
                            
                            switch (matchIndex) {
                                case 1:
                                    [personDictionary setValue:resultString forKey:@"name"];
                                    break;
                                    
                                default:
                                    [gradesDictionary setValue:resultString forKey:[keyNameArray objectAtIndex:matchIndex-1]];
                                    break;
                            }
                        }
                        else
                        {
                            [keyNameArray insertObject:resultString atIndex:[keyNameArray count]];
                        }
                    }
                    
                    if ([gradesDictionary count]) {
                        
                        [personDictionary setObject:gradesDictionary forKey:@"grades"];
                        [resultArray addObject:personDictionary];
                    }
                }];
                
                NSError  *JSONError;
                NSData   *JSONData   = [NSJSONSerialization dataWithJSONObject:resultArray options:0 error:&JSONError];
                NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
                
                if ( ! JSONError) {
                    
                    NSLog(@"%@", JSONString);
                }
            }
            else
            {
                NSLog(@"%@", requestError.localizedDescription);
            }
        }
        else
        {
            NSLog(@"%@", requestError.localizedDescription);
        }
    }
    return 0;
}

