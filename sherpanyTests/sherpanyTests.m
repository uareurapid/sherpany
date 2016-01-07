//
//  sherpanyTests.m
//  sherpanyTests
//
//  Created by PC Dreams on 05/01/16.
//  Copyright © 2016 Sherpany. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import <RestKit/Testing.h>
#import "User.h"
#import "Photo.h"
#import "Album.h"
#import "Geo.h"
#import "Company.h"
#import "Address.h"

@class Address;
@class Geo;
@class Company;
@class Photo;
@class User;
@class Album;

@interface sherpanyTests : XCTestCase
//TODO
@end

@implementation sherpanyTests

- (void)setUp {
    [super setUp];
    // Configure RKTestFixture
    NSBundle *testTargetBundle = [NSBundle bundleWithIdentifier:@"com.test.sherpanyTests"];
    [RKTestFixture setFixtureBundle:testTargetBundle];
    
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testUsersMapping
{
    //id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"Users.json"];
    //RKMappingTest *test = [RKMappingTest testForMapping:[self usersMapping] sourceObject:parsedJSON destinationObject:nil];
    
    //[test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"name"
    //                                                                        destinationKeyPath:@"name"
    //                                                                                     value:@"Leanne Graham"]];
    //just check if we have this element there
   // XCTAssert([mappingTest evaluate]);
    
    
    //[test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"name" destinationKeyPath:@"name"]];
    //XCTAssert([test evaluate], @"The name has not been set!");
}

- (void)testAlbumsMapping
{
    //id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"Albums.json"];
    //RKMappingTest *test = [RKMappingTest testForMapping:[self albumsMapping] sourceObject:parsedJSON destinationObject:nil];

    //[test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"title" destinationKeyPath:@"title"]];
    //XCTAssert([test evaluate], @"The title has not been set!");

}

- (void)testPhotosMapping
{
    //id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"Photos.json"];
    //RKMappingTest *test = [RKMappingTest testForMapping:[self photosMapping] sourceObject:parsedJSON destinationObject:nil];
    //[test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"title" destinationKeyPath:@"title"]];
    //XCTAssert([test evaluate], @"The title has not been set!");

}

- (RKObjectMapping *)usersMapping
{
    //GEO
    RKObjectMapping *geoMapping = [RKObjectMapping mappingForClass:[Geo class]];
    [geoMapping addAttributeMappingsFromDictionary:@{
                                                     @"lat" : @"lat",
                                                     @"lng" : @"lng"}];//mappings are in the following form "remote_name" : "local_name"
    
    //Address
    RKObjectMapping *addressMapping = [RKObjectMapping mappingForClass: [Address class]];
    [addressMapping addAttributeMappingsFromDictionary:@{
                                                         @"city" : @"city",
                                                         @"street" : @"street",
                                                         @"suite" : @"suite",
                                                         @"zipcode" : @"zipcode"}];
    //address contains geo
    [addressMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"geo" toKeyPath:@"geo" withMapping:geoMapping]];
    
    //Company
    RKObjectMapping *companyMapping = [RKObjectMapping mappingForClass: [Company class]];
    [companyMapping addAttributeMappingsFromDictionary:@{
                                                         @"name" : @"name",
                                                         @"catchPhrase" : @"catchphrase",
                                                         @"bs" : @"bs"}];
    
    //User
    RKObjectMapping *userMapping = [RKObjectMapping mappingForClass: [User class]];
    [userMapping addAttributeMappingsFromDictionary:@{
                                                      @"id" : @"identifier",
                                                      @"phone" : @"phone",
                                                      @"website" : @"website",
                                                      @"username" : @"username",
                                                      @"email" : @"email",
                                                      @"name" : @"name"}];
    //userMapping.identificationAttributes = @[@"identifier"];
    [userMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"address" toKeyPath:@"address" withMapping:addressMapping]];
    [userMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"company" toKeyPath:@"company" withMapping:companyMapping]];

    return userMapping;
}

- (RKObjectMapping *)albumsMapping
{
    RKObjectMapping *albumMapping = [RKObjectMapping mappingForClass: [Album class]];
    [albumMapping addAttributeMappingsFromDictionary:@{
                                                       @"userId" : @"userId",
                                                       @"title" : @"title",
                                                       @"id" : @"identifier"}];
    return albumMapping;
}

- (RKObjectMapping *)photosMapping
{
    RKObjectMapping *photoMapping = [RKObjectMapping mappingForClass:[Photo class]];
    [photoMapping addAttributeMappingsFromDictionary:@{
                                                       @"albumId" : @"albumId",
                                                       @"id" : @"identifier",
                                                       @"url" : @"url",
                                                       @"title" : @"title",
                                                       @"thumbnailUrl" : @"thumbnailUrl"}];
    return photoMapping;
}

@end
