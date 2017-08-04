///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBSHARINGUnmountFolderArg;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `UnmountFolderArg` struct.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBSHARINGUnmountFolderArg : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// The ID for the shared folder.
@property (nonatomic, readonly, copy) NSString *sharedFolderId;

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @param sharedFolderId The ID for the shared folder.
///
/// @return An initialized instance.
///
- (instancetype)initWithSharedFolderId:(NSString *)sharedFolderId;

- (instancetype)init NS_UNAVAILABLE;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `UnmountFolderArg` struct.
///
@interface DBSHARINGUnmountFolderArgSerializer : NSObject

///
/// Serializes `DBSHARINGUnmountFolderArg` instances.
///
/// @param instance An instance of the `DBSHARINGUnmountFolderArg` API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBSHARINGUnmountFolderArg` API object.
///
+ (NSDictionary *)serialize:(DBSHARINGUnmountFolderArg *)instance;

///
/// Deserializes `DBSHARINGUnmountFolderArg` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBSHARINGUnmountFolderArg` API object.
///
/// @return An instantiation of the `DBSHARINGUnmountFolderArg` object.
///
+ (DBSHARINGUnmountFolderArg *)deserialize:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END