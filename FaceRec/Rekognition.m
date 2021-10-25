//
//  Rekognition.m
//  FaceRec
//
//  Created by Andrew Kuo on 2018/2/25.
//  Copyright © 2018年 Andrew Kuo. All rights reserved.
//

#import "Rekognition.h"

@implementation Rekognition

- (instancetype)init
{
    self = [super init];
    if (self) {
        AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:kAWSKey secretKey:kAWSSecret];
        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
        [AWSRekognition registerRekognitionWithConfiguration:configuration forKey:kServiceKey];
        self.rekognitionClient = [AWSRekognition RekognitionForKey:kServiceKey];
        [AWSS3 registerS3WithConfiguration:configuration forKey:kS3ServiceKey];
        self.s3Client = [AWSS3 S3ForKey:kS3ServiceKey];
        self.isDoingSearch = NO;
    }
    return self;
}

- (void)searchFacesByImage:(UIImage *)image
{
    if (image==nil) {
        return;
    }
    if (self.isDoingSearch) {
        return;
    }
    self.isDoingSearch = YES;
    AWSRekognitionSearchFacesByImageRequest *request = [AWSRekognitionSearchFacesByImageRequest new];
    request.collectionId = kCollectionId;
    request.faceMatchThreshold = [NSNumber numberWithInt:90];
    request.maxFaces = [NSNumber numberWithInt:1];
    AWSRekognitionImage *awsImage = [[AWSRekognitionImage alloc] init];
    awsImage.bytes = [NSData dataWithData:UIImageJPEGRepresentation(image, 0.7)];
    request.image = awsImage;
    __weak typeof(self) wself = self;
    [self.rekognitionClient searchFacesByImage:request completionHandler:^(AWSRekognitionSearchFacesByImageResponse * _Nullable response, NSError * _Nullable error) {
        
        wself.isDoingSearch = NO;
        if (error) {
            NSLog(@"Search Face Error %@", [error description]);
        } else {
            if (response.faceMatches.count>0) {
                AWSRekognitionFaceMatch *faceMatch = [response.faceMatches objectAtIndex:0];
                if (self.delegate) {
                    [self.delegate getFaceInfo:faceMatch.face];
                }
            }
            
        }
        
    }];
}

- (void)getFaceInfo:(NSString *)filename completionHandled:(void (^)(NSDictionary *))completion
{
    AWSS3GetObjectRequest *request = [AWSS3GetObjectRequest new];
    request.bucket = @"thufaces";
    request.key = [NSString stringWithFormat:@"%@.json", filename];
//    NSURL *localURL = [[NSBundle mainBundle] URLForResource:@"xxx" withExtension:@"json"];
//    NSData *data = [NSData dataWithContentsOfURL:localURL];
//    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    [self.s3Client getObject:request completionHandler:^(AWSS3GetObjectOutput * _Nullable response, NSError * _Nullable error) {
        NSError *err = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response.body options:0 error:&err];
        if (error) {
            NSLog(@"Parse Json error: %@", [error description]);
        } else {
            if (completion) {
                completion(json);
            }
        }
        
    }];
}

@end
