//
//  ViewController.m
//  TestDropbox
//
//  Created by tyl on 4/8/17.
//  Copyright © 2017 strikespark. All rights reserved.
//

#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [self beginUpload2];
}

-(IBAction)actionLogDropBox:(id)sender{
    
    
    if ([DBClientsManager authorizedClient] || [DBClientsManager authorizedTeamClient]) {
        //case when already logged in
        [DBClientsManager unlinkAndResetClients];
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                       message:@"You have logged out of Dropbox"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction* action){
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        
    } else {
        //case when not logged in
        [DBClientsManager authorizeFromController:[UIApplication sharedApplication]
                                       controller:self
                                          openURL:^(NSURL *url) {
                                              [[UIApplication sharedApplication] openURL:url];
                                          }];
    }
}

-(IBAction)actionUpload2:(id)sender{
    NSLog(@"beginUpload2");
    DBUserClient* _dbUserClient = [DBClientsManager authorizedClient];
    //In the documents directory of the iphone app make a photo and call it MainPhoto.db //yes change the extension
    //Next in the documents directory make a folder called photos, add about 20 or so pngs// you can just use cmd-d to duplicate one photo many times
    //Once you do that you should be able to run the method, this method has will Garbage at end of file then further use of this method will cause
    
    
    NSURL* documentsDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL* picturesDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:@"photos"];;
    NSString* mainPictureFileName =  @"MainPhoto.db";
    NSURL* mainPictureFileURL =  [documentsDirectoryURL URLByAppendingPathComponent:mainPictureFileName];
    NSString* rootDropboxPath = @"";
    
    [[_dbUserClient.filesRoutes listFolder:rootDropboxPath]
     setResponseBlock:^(DBFILESListFolderResult *result, DBFILESListFolderError *routeError, DBRequestError *error) {
         NSLog(@"listFolder");
         if (result) {
             
             NSFileManager *fm = [NSFileManager defaultManager];
             NSArray* allPhotosArray = [fm contentsOfDirectoryAtPath:picturesDirectoryURL.path error:nil];
             NSMutableIndexSet *indexesPhotosThatExists = [NSMutableIndexSet new];
             NSMutableArray* mutableMetaDataArray = [result.entries mutableCopy];
             NSMutableArray* mutablePhotosArray = [allPhotosArray mutableCopy];
             //this removes the .DS_Store file that might be created in a mac when you put photos into the photo folder
             if ([mutablePhotosArray containsObject:@".DS_Store"]) {
                 [mutablePhotosArray removeObject:@".DS_Store"];
             }
             
             //two checks are going on here
             //first check if the file in dropbox exists in the bottom
             //second check which photos do not exists in dropbox and dump them up
             for (int i = 0; i < mutablePhotosArray.count ; i++) {
                 NSString* photoName = mutablePhotosArray[i];
                 
                 
                 NSLog(@"In app photo folder, photoName: %@",photoName);
                 NSInteger localFilesize = (NSInteger)[[[NSFileManager defaultManager] attributesOfItemAtPath:[picturesDirectoryURL URLByAppendingPathComponent:photoName isDirectory:NO].path error: nil] fileSize];
                 for (int j = 0; j < mutableMetaDataArray.count ; j++){
                     
                     DBFILESMetadata *metaData = mutableMetaDataArray[j];
                     
                     NSLog(@"metaData.name %@",metaData.name);
                     
                     if ([metaData.name isEqualToString:photoName] && [[metaData valueForKey:@"size"] integerValue] == localFilesize) {
                         //case where photos exists and doesn't need to update
                         [indexesPhotosThatExists addIndex:i];
                         //this speeds up the process of finding the object
                         //removes it from the loop or it will be O(n2)
                         [mutableMetaDataArray removeObjectAtIndex:j];
                         break;
                     }
                 }
             }
             //get all the paths for files that need to be deleted in the dropbox
             NSMutableArray* arrayOfDeletePaths = [NSMutableArray new];
             for (DBFILESMetadata* data in mutableMetaDataArray){
                 [arrayOfDeletePaths addObject:[[DBFILESDeleteArg alloc]initWithPath:data.pathDisplay]];
             }
             
             [mutablePhotosArray removeObjectsAtIndexes:indexesPhotosThatExists];
             
             __block NSMutableDictionary<NSURL *, DBFILESCommitInfo *> *uploadFilesUrlsToCommitInfo = [NSMutableDictionary new];
             
             for (NSString* photoName in mutablePhotosArray){
                 
                 //                 if ([photoName isEqualToString:@".DS_Store"]) {
                 //                     break;
                 //                 }
                 
                 NSString* urlpathInDropbox = [NSString stringWithFormat:@"/%@",photoName];
                 NSLog(@"url photo path in dropbox %@",urlpathInDropbox);
                 DBFILESCommitInfo *commitInfo = [[DBFILESCommitInfo alloc] initWithPath:urlpathInDropbox];
                 NSURL* photoURLPath = [picturesDirectoryURL URLByAppendingPathComponent:photoName isDirectory:NO];
                 NSLog(@"photoURLPath %@",photoURLPath);
                 [uploadFilesUrlsToCommitInfo setObject:commitInfo forKey:photoURLPath];
             }
             
             [[_dbUserClient.filesRoutes deleteBatch:arrayOfDeletePaths]setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
                 //case where the deletion has finished
                 if (totalBytesWritten == totalBytesExpectedToWrite) {
                     
                     NSString* filenameDropboxPath = [NSString stringWithFormat:@"/%@",mainPictureFileName];
                     NSLog(@"filenameDropboxPath %@",filenameDropboxPath);
                     // For overriding on upload
                     DBFILESWriteMode *mode = [[DBFILESWriteMode alloc] initWithOverwrite];
                     
                     [[[_dbUserClient.filesRoutes
                        uploadUrl:filenameDropboxPath
                        mode:mode
                        autorename:@(YES)
                        clientModified:nil
                        mute:@(NO)
                        inputUrl:mainPictureFileURL.path]
                       setResponseBlock:^(DBFILESFileMetadata *result, DBFILESUploadError *routeError, DBRequestError *networkError) {
                           
                       }] setProgressBlock:^(int64_t bytesUploaded, int64_t totalBytesUploaded, int64_t totalBytesExpectedToUploaded) {
                           
                           float uploadedTotalMegabyte = (float)totalBytesUploaded/1048576;
                           float uploadedExpectedMegabyte = (float)totalBytesExpectedToUploaded/1048576;
                           NSString* amountUploaded = [NSString stringWithFormat:@"Uploading DB %.2f of %.2f MB",uploadedTotalMegabyte,uploadedExpectedMegabyte];
                           NSLog(@"%@", amountUploaded);
                           
                           if (totalBytesUploaded == totalBytesExpectedToUploaded) {
                               //FIXME: THIS IS WHERE THE ERROR OCCURS
                               //For some reason batch upload
                               //gives error session_id missing or there is garbage at the end
                               
                               [[DBClientsManager authorizedClient].filesRoutes
                                batchUploadFiles:uploadFilesUrlsToCommitInfo
                                queue:nil
                                progressBlock:^(int64_t uploaded, int64_t uploadedTotal, int64_t expectedToUploadTotal) {
                                    float uploadedTotalMegabyte = (float)uploadedTotal/1048576;
                                    float uploadedExpectedMegabyte = (float)expectedToUploadTotal/1048576;
                                    NSString* message = [NSString stringWithFormat:@"Uploading Pictures: %.2f of %.2f MB",uploadedTotalMegabyte,uploadedExpectedMegabyte];
                                    NSLog(@"%@", message);
                                }
                                responseBlock:^(NSDictionary<NSURL *, DBFILESUploadSessionFinishBatchResultEntry *> *fileUrlsToBatchResultEntries,
                                                DBASYNCPollError *finishBatchRouteError, DBRequestError *finishBatchRequestError,
                                                NSDictionary<NSURL *, DBRequestError *> *fileUrlsToRequestErrors) {
                                    if (fileUrlsToBatchResultEntries) {
                                        
                                        BOOL hasErrors = false;
                                        for (NSURL *clientSideFileUrl in fileUrlsToBatchResultEntries) {
                                            DBFILESUploadSessionFinishBatchResultEntry *resultEntry = fileUrlsToBatchResultEntries[clientSideFileUrl];
                                            if ([resultEntry isSuccess]) {
                                                
                                            } else if ([resultEntry isFailure]) {
                                                hasErrors = true;
                                                DBRequestError *uploadNetworkError = fileUrlsToRequestErrors[clientSideFileUrl];
                                                DBFILESUploadSessionFinishError *uploadSessionFinishError = resultEntry.failure;
                                                NSLog(@"uploadNetworkError %@,uploadSessionFinishError %@",uploadNetworkError,uploadSessionFinishError);
                                                NSLog(@"resultEntry %@,clientSideFileUrl %@",resultEntry,clientSideFileUrl);
                                                
                                            }
                                        }
                                        
                                        if (hasErrors) {
                                            NSLog(@"Upload Failed, message: %@",@"Some Photos were not uploaded properly. Retry uploading again");
                                        }
                                    }
                                    
                                    NSString *title = @"";
                                    NSString *message = @"";
                                    if (finishBatchRouteError) {
                                        title = @"Either bug in SDK code, or transient error on Dropbox server";
                                        message = [NSString stringWithFormat:@"%@", finishBatchRouteError];
                                        NSLog(@"Either bug in SDK code, or transient error on Dropbox server");
                                        NSLog(@"Error title: %@, message: %@, finishBatchRouteError: %@",title,message,finishBatchRouteError);
                                    } else if (finishBatchRequestError) {
                                        title = @"Request error from calling `/upload_session/finish_batch/check`";
                                        message = [NSString stringWithFormat:@"%@", finishBatchRequestError];
                                        NSLog(@"Request error from calling `/upload_session/finish_batch/check`");
                                        NSLog(@"%@", finishBatchRequestError);
                                    } else if ([fileUrlsToRequestErrors count] > 0) {
                                        title = @"Other additional errors (e.g. file doesn't exist client-side, etc.).";
                                        message = [NSString stringWithFormat:@"%@", fileUrlsToRequestErrors];
                                        NSLog(@"Other additional errors (e.g. file doesn't exist client-side, etc.).");
                                        NSLog(@"%@", fileUrlsToRequestErrors);
                                    } else {
                                        NSLog(@"Upload has completed without problems");
                                    }
                                }];
                               //end
                           }
                       }];
                 }
             }];
         } else {
             NSString *title = @"";
             NSString *message = @"";
             if (routeError) {
                 // Route-specific request error
                 title = @"Route-specific error";
                 if ([routeError isPath]) {
                     message = [NSString stringWithFormat:@"Invalid path: %@", routeError.path];
                 }
             } else {
                 // Generic request error
                 title = @"Generic request error";
                 if ([error isInternalServerError]) {
                     DBRequestInternalServerError *internalServerError = [error asInternalServerError];
                     message = [NSString stringWithFormat:@"%@", internalServerError];
                 } else if ([error isBadInputError]) {
                     DBRequestBadInputError *badInputError = [error asBadInputError];
                     message = [NSString stringWithFormat:@"%@", badInputError];
                 } else if ([error isAuthError]) {
                     DBRequestAuthError *authError = [error asAuthError];
                     message = [NSString stringWithFormat:@"%@", authError];
                 } else if ([error isRateLimitError]) {
                     DBRequestRateLimitError *rateLimitError = [error asRateLimitError];
                     message = [NSString stringWithFormat:@"%@", rateLimitError];
                 } else if ([error isHttpError]) {
                     DBRequestHttpError *genericHttpError = [error asHttpError];
                     message = [NSString stringWithFormat:@"%@", genericHttpError];
                 } else if ([error isClientError]) {
                     DBRequestClientError *genericLocalError = [error asClientError];
                     message = [NSString stringWithFormat:@"%@", genericLocalError];
                 }
             }
             NSLog(@"Upload Failed, title: %@, message: %@",title,message);
         }
     }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
