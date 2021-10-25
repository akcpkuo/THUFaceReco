//
//  Rekognition.h
//  FaceRec
//
//  Created by Andrew Kuo on 2018/2/25.
//  Copyright © 2018年 Andrew Kuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSCore/AWSCore.h>
#import <AWSRekognition/AWSRekognition.h>
#import <AWSS3/AWSS3.h>

#define kAWSKey @"AKIAJTBOHQ5NY3X5Q3KA"
#define kAWSSecret @"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"
#define kServiceKey @"SearchFaceAndrew"
#define kS3ServiceKey @"S3Service"
#define kCollectionId @"thucollection"

@protocol RekognitionDelegate <NSObject>

- (void)getFaceInfo:(AWSRekognitionFace *)info;

@end

@interface Rekognition : NSObject

@property (strong, nonatomic) AWSRekognition *rekognitionClient;
@property (strong, nonatomic) AWSS3 *s3Client;
@property (weak, nonatomic) id<RekognitionDelegate> delegate;
@property (assign, nonatomic) BOOL isDoingSearch;

- (void)searchFacesByImage:(UIImage *)image;
- (void)getFaceInfo:(NSString *)filename completionHandled:(void(^)(NSDictionary *finfo))completion;

@end
