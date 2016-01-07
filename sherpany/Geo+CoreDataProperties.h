//
//  Geo+CoreDataProperties.h
//  sherpany
//
//  Created by PC Dreams on 06/01/16.
//  Copyright © 2016 Sherpany. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Geo.h"

NS_ASSUME_NONNULL_BEGIN

@interface Geo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *lat;
@property (nullable, nonatomic, retain) NSString *lng;

@end

NS_ASSUME_NONNULL_END
