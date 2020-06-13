//
//  LUStringUtils.m
//
//  Lunar Unity Mobile Console
//  https://github.com/SpaceMadness/lunar-unity-console
//
//  Copyright 2015-2020 Alex Lementuev, SpaceMadness.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


#import "LUStringUtils.h"

#import "Lunar.h"

static inline NSNumber *LUNumberFromString(NSString *str)
{
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *number = [numberFormatter numberFromString:str];
    
    return number;
}

BOOL LUStringTryParseInteger(NSString *str, NSInteger *outResult)
{
    NSNumber *number = LUNumberFromString(str);
    if (number)
    {
        // FIXME: find a better way of telling if number is integer
        NSString *decimalSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];
        if ([str rangeOfString:decimalSeparator].location == NSNotFound)
        {
            if (outResult) *outResult = number.integerValue;
            return YES;
        }
    }
    
    return NO;
}

BOOL LUStringTryParseHex(NSString *str, NSInteger *outResult) {
    if (str.length > 0) {
        NSScanner *scanner = [[NSScanner alloc] initWithString:str];
        return [scanner scanInteger:outResult];
    }
    
    return NO;
}

BOOL LUStringTryParseFloat(NSString *str, float *outResult)
{
    NSNumber *number = LUNumberFromString(str);
    if (number)
    {
        if (outResult) *outResult = number.floatValue;
        return YES;
    }
    
    return NO;
}

BOOL LUStringContainsRichTextTags(NSString *str)
{
    return [str containsString:@"</color>"] || [str containsString:@"</b>"] || [str containsString:@"</i>"];
}

NSString *LUStringRemoveRichTextTags(NSString *string)
{
    static NSArray * tokens = nil;
    if (tokens == nil)
    {
        tokens = @[@"<b>", @"</b>", @"<i>", @"</i>", @"</color>"];
    }
    
    for (int i = 0; i < tokens.count; ++i) {
        string = [string stringByReplacingOccurrencesOfString:tokens[i] withString:@""];
    }
    
    static NSRegularExpression *regex;
    if (regex == nil)
    {
        NSError *error = nil;
        regex = [NSRegularExpression regularExpressionWithPattern:@"\\<color\\=\\w+\\>"
                                                          options:NSRegularExpressionCaseInsensitive
                                                            error:&error];
    }
    return [regex stringByReplacingMatchesInString:string
                                           options:0
                                             range:NSMakeRange(0, [string length])
                                      withTemplate:@""];
}

NSString *LUStringRichTextToHtml(NSString *string)
{
    string = [string stringByReplacingOccurrencesOfString:@"<color=" withString:@"<font color="];
    string = [string stringByReplacingOccurrencesOfString:@"</color>" withString:@"</font>"];
    return string;
}

NSString *LUSerializeDictionaryToString(NSDictionary *data)
{
    if (data.count == 0) return @"";
    
    NSMutableString *result = [NSMutableString string];
    NSInteger index = 0;
    for (id key in data)
    {
        id value = [[data objectForKey:key] description];
        value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"]; // we use new lines as separators
        [result appendFormat:@"%@:%@", key, value];
        if (++index < data.count)
        {
            [result appendString:@"\n"];
        }
    }
    
    return result;
}
