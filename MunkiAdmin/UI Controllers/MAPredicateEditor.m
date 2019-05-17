//
//  PredicateEditor.m
//  MunkiAdmin
//
//  Created by Juutilainen Hannes on 9.2.2012.
//

#import "MAPredicateEditor.h"
#import "ConditionalItemMO.h"
#import "MAMunkiDateRowTemplate.h"
#import "CocoaLumberjack.h"

DDLogLevel ddLogLevel;

#define DEFAULT_PREDICATE @"hostname == ''"

@implementation MAPredicateEditor

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {        
        self.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:DEFAULT_PREDICATE]]];
    }
    
    return self;
}

- (void)awakeFromNib
{
    NSMutableArray *rowTemplates = [[self.predicateEditor rowTemplates] mutableCopy];
    
    /*
     Add the Any, All and None options
     */
    [rowTemplates addObject:[[NSPredicateEditorRowTemplate alloc] initWithCompoundTypes:@[@(NSAndPredicateType), @(NSOrPredicateType), @(NSNotPredicateType)]]];
    
    /*
     Simple strings that do not need a modifier
     */
    NSArray *simpleLeftExpressions = @[
                                       [NSExpression expressionForKeyPath:@"hostname"],
                                       [NSExpression expressionForKeyPath:@"arch"],
                                       [NSExpression expressionForKeyPath:@"os_vers"],
                                       [NSExpression expressionForKeyPath:@"machine_model"],
                                       [NSExpression expressionForKeyPath:@"munki_version"],
                                       [NSExpression expressionForKeyPath:@"serial_number"],
                                       [NSExpression expressionForKeyPath:@"os_build_number"]];
    NSArray *simpleOperators = @[
                                 @(NSContainsPredicateOperatorType),
                                 @(NSMatchesPredicateOperatorType),
                                 @(NSLikePredicateOperatorType),
                                 @(NSBeginsWithPredicateOperatorType),
                                 @(NSEndsWithPredicateOperatorType),
                                 @(NSEqualToPredicateOperatorType),
                                 @(NSNotEqualToPredicateOperatorType)
                                 ];
    
    // NSComparisonPredicateOptions options = (NSCaseInsensitivePredicateOption | NSDiacriticInsensitivePredicateOption);
    NSPredicateEditorRowTemplate *simpleStringsRowTemplate = [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:simpleLeftExpressions
                                                                                              rightExpressionAttributeType:NSStringAttributeType
                                                                                                                  modifier:NSDirectPredicateModifier
                                                                                                                 operators:simpleOperators
                                                                                                                   options:0];
    [rowTemplates addObject:simpleStringsRowTemplate];
    
    /*
     Machine type template
     */
    NSArray *machineTypeExpressions = @[[NSExpression expressionForConstantValue:@"desktop"], [NSExpression expressionForConstantValue:@"laptop"]];
    NSPredicateEditorRowTemplate *predefinedRowTemplate = [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:@[[NSExpression expressionForKeyPath:@"machine_type"]]
                                                                                                       rightExpressions:machineTypeExpressions
                                                                                                               modifier:NSDirectPredicateModifier
                                                                                                              operators:@[@(NSEqualToPredicateOperatorType), @(NSNotEqualToPredicateOperatorType)]
                                                                                                                options:0];
    [rowTemplates addObject:predefinedRowTemplate];
    
    /*
     Numeric
     */
    NSArray *numericLeftExpressions = @[
                                        [NSExpression expressionForKeyPath:@"os_vers_major"],
                                        [NSExpression expressionForKeyPath:@"os_vers_minor"],
                                        [NSExpression expressionForKeyPath:@"os_vers_patch"],
                                        [NSExpression expressionForKeyPath:@"os_build_last_component"]];
    NSArray *numericOperators = @[
                                  @(NSGreaterThanPredicateOperatorType),
                                  @(NSGreaterThanOrEqualToPredicateOperatorType),
                                  @(NSLessThanPredicateOperatorType),
                                  @(NSLessThanOrEqualToPredicateOperatorType),
                                  @(NSEqualToPredicateOperatorType),
                                  @(NSNotEqualToPredicateOperatorType)
                                  ];
    NSPredicateEditorRowTemplate *numericRowTemplate = [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:numericLeftExpressions
                                                                                        rightExpressionAttributeType:NSInteger64AttributeType
                                                                                                            modifier:NSDirectPredicateModifier
                                                                                                           operators:numericOperators
                                                                                                             options:0];
    [rowTemplates addObject:numericRowTemplate];
    
    /*
     Strings that need the ANY modifier
     */
    NSArray *containsOperator = @[
                                  @(NSContainsPredicateOperatorType),
                                  @(NSLikePredicateOperatorType),
                                  @(NSBeginsWithPredicateOperatorType),
                                  @(NSEndsWithPredicateOperatorType),
                                  @(NSEqualToPredicateOperatorType),
                                  @(NSNotEqualToPredicateOperatorType)
                                  ];
    NSArray *leftExpressions = @[
                                 [NSExpression expressionForKeyPath:@"ipv4_address"],
                                 [NSExpression expressionForKeyPath:@"catalogs"]
                                 ];
    // NSComparisonPredicateOptions options = (NSCaseInsensitivePredicateOption | NSDiacriticInsensitivePredicateOption);
    NSPredicateEditorRowTemplate *catalogsTemplate = [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:leftExpressions
                                                                                      rightExpressionAttributeType:NSStringAttributeType
                                                                                                          modifier:NSAnyPredicateModifier
                                                                                                         operators:containsOperator
                                                                                                           options:0];
    [rowTemplates addObject:catalogsTemplate];
    
    
    /*
     Date
     */
    MAMunkiDateRowTemplate *dateTemplate = [[MAMunkiDateRowTemplate alloc] initWithLeftExpressions:@[[NSExpression expressionForKeyPath:(@"date")]]];
    [rowTemplates addObject:dateTemplate];
    
    /*
     Add the row templates to the predicate editor
     */
    [self.predicateEditor setRowTemplates:rowTemplates];
    
    NSDictionary *formatting = @{
                                 @"%[hostname]@ %[is, is not, contains, matches, is like, begins with, ends with]@ %@" : @"%[Hostname]@ %[is, is not, contains, matches, is like, begins with, ends with]@ %@",
                                 @"%[arch]@ %[is, is not, contains, matches, is like, begins with, ends with]@ %@" : @"%[Processor architecture]@ %[is, is not, contains, matches, is like, begins with, ends with]@ %@",
                                 @"%[os_vers]@ %[is, is not, contains, matches, is like, begins with, ends with]@ %@" : @"%[Full OS Version]@ %[is, is not, contains, matches, is like, begins with, ends with]@ %@",
                                 @"%[machine_model]@ %[is, is not, contains, matches, is like, begins with, ends with]@ %@" : @"%[Machine model]@ %[is, is not, contains, matches, is like, begins with, ends with]@ %@",
                                 @"%[munki_version]@ %[is, is not, contains, matches, is like, begins with, ends with]@ %@" : @"%[Munki version]@ %[is, is not, contains, matches, is like, begins with, ends with]@ %@",
                                 @"%[serial_number]@ %[is, is not, contains, matches, is like, begins with, ends with]@ %@" : @"%[Machine serial number]@ %[is, is not, contains, matches, is like, begins with, ends with]@ %@",
                                 @"%[machine_type]@ %[is, is not]@ %@" : @"%[Machine type]@ %[is, is not]@ %@",
                                 @"%[os_vers_major]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@" :
                                     @"%[OS Major Version]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@",
                                 @"%[os_vers_minor]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@" :
                                     @"%[OS Minor Version]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@",
                                 @"%[os_vers_patch]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@" :
                                     @"%[OS Patch Version]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@",
                                 @"%[os_build_number]@ %[is, is not, contains, matches, is like, begins with, ends with]@ %@" : @"%[OS Build Number]@ %[is, is not, contains, matches, is like, begins with, ends with]@ %@",
                                 @"%[os_build_last_component]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@" :
                                     @"%[OS Build Last Component]@ %[is, is not, is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@",
                                 @"%[ipv4_address]@ %[is, is not, contains, is like, begins with, ends with]@ %@" : @"%[IPv4 address of any interface]@ %[is, is not, contains, is like, begins with, ends with]@ %@",
                                 @"%[catalogs]@ %[is, is not, contains, is like, begins with, ends with]@ %@" : @"%[Catalogs]@ %[is, is not, contains, is like, begins with, ends with]@ %@",
                                 @"%[date]@ %[is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@" :
                                     @"%[Date]@ %[is greater than, is greater than or equal to, is less than, is less than or equal to]@ %@",
                                 };
    [self.predicateEditor setFormattingDictionary:formatting];
}

- (void)resetPredicateToDefault
{
    self.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:DEFAULT_PREDICATE]]];
    self.customPredicateString = DEFAULT_PREDICATE;
    self.predicateEditor.objectValue = self.predicate;
}

- (void)saveAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
    [self.window orderOut:sender];
}

- (void)cancelAction:(id)sender
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
    [self.window orderOut:sender];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

@end
