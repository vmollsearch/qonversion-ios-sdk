#import <Foundation/Foundation.h>
#import "QNUtils.h"
#import "QNMapper.h"
#import "QonversionLaunchResult+Protected.h"

NSString * const QNErrorDomain = @"com.qonversion.io";

static NSDictionary <NSString *, NSNumber *> *PermissionStates = nil;


@interface QNMapperObject : NSObject

@property (nonatomic, nullable) NSDictionary *data;
@property (nonatomic, copy, nullable) NSError *error;

@end

@implementation QNMapperObject : NSObject

@end

@implementation QonversionComposeModel : NSObject
@end

@implementation QonversionLaunchComposeModel

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super init];
  if (self) {
    _error = [coder decodeObjectForKey:NSStringFromSelector(@selector(error))];
    _result = [coder decodeObjectForKey:NSStringFromSelector(@selector(result))];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [coder encodeObject:_error forKey:NSStringFromSelector(@selector(error))];
  [coder encodeObject:_result forKey:NSStringFromSelector(@selector(result))];
}


- (void)setResult:(QonversionLaunchResult *)result {
  _result = result;
}

@end

@implementation QNMapper

- (QonversionLaunchComposeModel * _Nonnull)composeLaunchModelFrom:(NSData * _Nullable)data {
  QNMapperObject *object = [self mapperObjectFrom:data];
  QonversionLaunchComposeModel *result = [QonversionLaunchComposeModel new];
  
  if (object.error == NULL && [object.data isKindOfClass:NSDictionary.class]) {
    QONVERSION_LOG(@"Qonversion Launch Log Response:\n%@", object.data);
    QonversionLaunchResult *resultObject = [[QNMapper new] fillLaunchResult:object.data];
    [result setResult:resultObject];
    return result;
  } else {
    [result setError:object.error];
    return result;
  }
}

- (QonversionLaunchResult * _Nonnull)fillLaunchResult:(NSDictionary *)dict {
  QonversionLaunchResult *result = [[QonversionLaunchResult alloc] init];
  NSDictionary *permissionsDict = dict[@"permissions"] ?: @{};
  NSDictionary *productsDict = dict[@"products"] ?: @{};
  NSDictionary *userProductsDict = dict[@"user_products"] ?: @{};
  
  [result setUid:((NSString *)dict[@"uid"] ?: @"")];
  [result setPermissions:[self fillPermissions:permissionsDict]];
  [result setProducts:[self fillProducts:productsDict]];
  [result setUserProducts:[self fillProducts:userProductsDict]];
  
  return result;
}

- (NSDictionary <NSString *, QonversionPermission *> *)fillPermissions:(NSDictionary *)dict {
  NSMutableDictionary <NSString *, QonversionPermission *> *permissions = [NSMutableDictionary new];
  
  for (NSDictionary* itemDict in dict) {
    QonversionPermission *item = [self fillPermission:itemDict];
    if (item && item.permissionID) {
      permissions[item.permissionID] = item;
    }
  }
  
  return [[NSDictionary alloc] initWithDictionary:permissions];
}

- (NSDictionary <NSString *, QonversionProduct *> *)fillProducts:(NSDictionary *)dict {
  NSMutableDictionary <NSString *, QonversionProduct *> *products = [NSMutableDictionary new];
  
  for (NSDictionary* itemDict in dict) {
    QonversionProduct *item = [self fillProduct:itemDict];
    if (item && item.qonversionID) {
      products[item.qonversionID] = item;
    }
  }
  
  return [[NSDictionary alloc] initWithDictionary:products];
}

- (QonversionPermission * _Nonnull)fillPermission:(NSDictionary *)dict {
  QonversionPermission *result = [[QonversionPermission alloc] init];
  result.permissionID = dict[@"id"];
  result.isActive = ((NSNumber *)dict[@"active"] ?: @0).boolValue;
  result.renewState = ((NSNumber *)dict[@"renew_state"] ?: @0).intValue;
  result.productID = ((NSString *)dict[@"associated_product"] ?: @"");
  
  NSTimeInterval started = ((NSNumber *)dict[@"started_timestamp"] ?: @0).intValue;
  result.startedDate = [[NSDate alloc] initWithTimeIntervalSince1970:started];
  result.expirationDate = nil;
  
  if (dict[@"expiration_timestamp"]) {
    NSTimeInterval expiration = ((NSNumber *)dict[@"expiration_timestamp"] ?: @0).intValue;
    result.expirationDate = [[NSDate alloc] initWithTimeIntervalSince1970:expiration];
  }
  
  return result;
}

- (QonversionProduct * _Nonnull)fillProduct:(NSDictionary *)dict {
  QonversionProduct *result = [[QonversionProduct alloc] init];
  
  result.duration = ((NSNumber *)dict[@"duration"] ?: @0).integerValue;
  result.type = ((NSNumber *)dict[@"type"] ?: @0).integerValue;
  result.qonversionID = ((NSString *)dict[@"id"] ?: @"");
  result.storeID = ((NSString *)dict[@"store_id"] ?: @"");
  
  return result;
}

+ (NSError *)error:(NSString *)message code:(QNErrorCode)errorCode  {
  NSDictionary *info = @{NSLocalizedDescriptionKey: NSLocalizedString(message, nil)};
  return [[NSError alloc] initWithDomain:QNErrorDomain code:errorCode userInfo:info];
}

- (QNMapperObject *)mapperObjectFrom:(NSData *)data {
  QNMapperObject *object = [QNMapperObject new];
  
  if (!data || ![data isKindOfClass:NSData.class]) {
    [object setError:[QNMapper error:@"Could not receive data" code:QNErrorCodeFailedReceiveData]];
    return object;
  }
  
  NSError *jsonError = [[NSError alloc] init];
  NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
  
  if (jsonError.domain) {
    [object setError:[QNMapper error:@"Could not parse response" code:QNErrorCodeFailedParseResponse]];
    return object;
  }
  
  QONVERSION_LOG(@"QONVERSION RESPONSE DATA %@", dict);
  if (!dict || ![dict respondsToSelector:@selector(valueForKey:)]) {
    [object setError:[QNMapper error:@"Could not parse response" code:QNErrorCodeFailedParseResponse]];
    return object;
  }
  
  NSNumber *success = dict[@"success"];
  NSDictionary *resultData = dict[@"data"];
  
  if (success.boolValue && resultData) {
    [object setData:resultData];
    return object;
  } else {
    NSString *message = dict[@"data"][@"message"] ?: @"";
    [object setError:[QNMapper error:message code:QNErrorCodeIncorrectRequest]];
    return object;
  }
}

@end

