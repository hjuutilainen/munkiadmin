//
//  MAMunkiDateRowTemplate.m
//  MunkiAdmin
//
//  Created by Hannes Juutilainen on 11.5.2016.
//
//

#import "MAMunkiDateRowTemplate.h"

@implementation MAMunkiDateRowTemplate

- (id)initWithLeftExpressions:(NSArray *)leftExpressions
{
    NSAttributeType rightType = NSDateAttributeType;
    NSComparisonPredicateModifier modifier = NSDirectPredicateModifier;
    NSArray *dateOperators = @[
                               @(NSGreaterThanPredicateOperatorType),
                               @(NSGreaterThanOrEqualToPredicateOperatorType),
                               @(NSLessThanPredicateOperatorType),
                               @(NSLessThanOrEqualToPredicateOperatorType)
                               ];
    NSUInteger options = 0;
    return [super initWithLeftExpressions:leftExpressions
             rightExpressionAttributeType:rightType
                                 modifier:modifier
                                operators:dateOperators
                                  options:options];
}

- (NSArray *)templateViews
{
    NSArray *views = [super templateViews];
    for (id view in views) {
        if ([view isKindOfClass:[NSDatePicker class]]) {
            /*
             Configure the date picker to show time controls and set time zone to GMT
             */
            NSDatePicker *datePicker = view;
            NSDatePickerElementFlags flags = (NSYearMonthDayDatePickerElementFlag | NSHourMinuteSecondDatePickerElementFlag);
            [datePicker setDatePickerElements:flags];
            [datePicker setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [datePicker sizeToFit];
        }
    }
    return views;
}

- (NSPredicate *)predicateWithSubpredicates:(NSArray *)subpredicates
{
    NSPredicate *predicate = [super predicateWithSubpredicates:subpredicates];
    if ([predicate isKindOfClass:[NSComparisonPredicate class]]) {
        NSComparisonPredicate *comparison = (NSComparisonPredicate *)predicate;
        
        NSExpression *right = [comparison rightExpression];
        NSDate *value = [right constantValue];
        
        /*
         Create a custom expression from the user provided date to get a predicate
         in format: CAST("2013-01-02T00:00:00Z", "NSDate")
         */
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
        dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        NSString *dateStringForMunki = [dateFormatter stringFromDate:value];
        
        NSArray *castArguments = @[
                                   [NSExpression expressionForConstantValue:dateStringForMunki],
                                   [NSExpression expressionForConstantValue:@"NSDate"]
                                   ];
        NSExpression *expression = [NSExpression expressionForFunction:@"castObject:toType:" arguments:castArguments];
        
        predicate = [NSComparisonPredicate predicateWithLeftExpression:[comparison leftExpression]
                                               rightExpression:expression
                                                      modifier:[comparison comparisonPredicateModifier]
                                                          type:[comparison predicateOperatorType]
                                                       options:[comparison options]];
    }
    return predicate;
}

- (void)setPredicate:(NSPredicate *)newPredicate
{
    if ([newPredicate isKindOfClass:[NSComparisonPredicate class]]) {
        
        NSComparisonPredicate * comparison = (NSComparisonPredicate *)newPredicate;
        newPredicate = [NSComparisonPredicate predicateWithLeftExpression:[comparison leftExpression]
                                                          rightExpression:[comparison rightExpression]
                                                                 modifier:[comparison comparisonPredicateModifier]
                                                                     type:[comparison predicateOperatorType]
                                                                  options:[comparison options]];
    }
    
    [super setPredicate:newPredicate];
}

@end
