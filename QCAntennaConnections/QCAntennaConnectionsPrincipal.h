//
//  QCAntennaConnectionsPrincipal.h
//  QCAntennaConnections
//
//  Created by Bartosz Ciechanowski on 01.04.2014.
//  Copyright (c) 2014 Macoscope. All rights reserved.
//


@interface QCAntennaConnectionsPrincipal : NSObject <GFPlugInRegistration>

+ (void)registerNodesWithManager:(QCNodeManager*)manager;

@end
