///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBTEAMLOGGetTeamEventsContinueArg;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `GetTeamEventsContinueArg` struct.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMLOGGetTeamEventsContinueArg : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// Indicates from what point to get the next set of events.
@property (nonatomic, readonly, copy) NSString *cursor;

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @param cursor Indicates from what point to get the next set of events.
///
/// @return An initialized instance.
///
- (instancetype)initWithCursor:(NSString *)cursor;

- (instancetype)init NS_UNAVAILABLE;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `GetTeamEventsContinueArg` struct.
///
@interface DBTEAMLOGGetTeamEventsContinueArgSerializer : NSObject

///
/// Serializes `DBTEAMLOGGetTeamEventsContinueArg` instances.
///
/// @param instance An instance of the `DBTEAMLOGGetTeamEventsContinueArg` API
/// object.
///
/// @return A json-compatible dictionary representation of the
/// `DBTEAMLOGGetTeamEventsContinueArg` API object.
///
+ (NSDictionary *)serialize:(DBTEAMLOGGetTeamEventsContinueArg *)instance;

///
/// Deserializes `DBTEAMLOGGetTeamEventsContinueArg` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMLOGGetTeamEventsContinueArg` API object.
///
/// @return An instantiation of the `DBTEAMLOGGetTeamEventsContinueArg` object.
///
+ (DBTEAMLOGGetTeamEventsContinueArg *)deserialize:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
