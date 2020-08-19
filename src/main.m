//
//  Created by Leptos on 3/16/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>
#import <IOKit/pwr_mgt/IOPM.h>

#define TEMPERATURE_EXTREME_STRING "Warning: Temperature considered to be too "

int main(int argc, char *argv[]) {
    BOOL silent = NO;
    
    int opt;
    while ((opt = getopt(argc, argv, "s")) != -1) {
        switch (opt) {
            case 's':
                silent = YES;
                break;
                
            default:
                printf("Usage: %s [-s]\n"
                       "  Battery temperature, as provided by IOKit\n"
                       "    -s  Silent, print nothing\n"
                       "\n"
                       "Exit status is\n"
                       "  0 if the temperature is within recommended operating temperatures,\n"
                       "  1 if the temperature is too low,\n"
                       "  2 if the temperature is too high,\n"
                       "  3 if the temperature is either too high or low, but which cannot be determined.\n"
                       , argv[0]);
                return 1;
        }
    }
    
    io_service_t service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPMPowerSource"));
    CFNumberRef temperature = IORegistryEntryCreateCFProperty(service, CFSTR(kIOPMPSBatteryTemperatureKey), NULL, 0);
    CFStringRef chargeStat = IORegistryEntryCreateCFProperty(service, CFSTR(kIOPMPSBatteryChargeStatusKey), NULL, 0);
    IOObjectRelease(service);
    
    double ioTemp = NAN;
    if (temperature) {
        CFNumberGetValue(temperature, kCFNumberDoubleType, &ioTemp);
        CFRelease(temperature);
    }
    
    double const celsiusTemp = ioTemp/100;
    
    NSString *chargeStatus = CFBridgingRelease(chargeStat);
    
    int ret = 0;
    const char *warningText = NULL;
    if ([chargeStatus isEqualToString:@kIOPMBatteryChargeStatusTooHotOrCold]) {
        warningText = (TEMPERATURE_EXTREME_STRING "warm or cold");
        ret = 3;
    } else if ([chargeStatus isEqualToString:@kIOPMBatteryChargeStatusTooHot]) {
        warningText = (TEMPERATURE_EXTREME_STRING "warm");
        ret = 2;
    } else if ([chargeStatus isEqualToString:@kIOPMBatteryChargeStatusTooCold]) {
        warningText = (TEMPERATURE_EXTREME_STRING "cold");
        ret = 1;
    }
    
    if (!silent) {
        NSMeasurement *celsius = [[NSMeasurement alloc] initWithDoubleValue:celsiusTemp unit:NSUnitTemperature.celsius];
        
        NSMeasurementFormatter *unitFormatter = [NSMeasurementFormatter new];
        unitFormatter.unitOptions = NSMeasurementFormatterUnitOptionsNaturalScale;
        unitFormatter.numberFormatter.maximumFractionDigits = 2;
        
        NSString *localizedTemperature = [unitFormatter stringFromMeasurement:celsius];
        if (warningText) {
            puts(warningText);
        }
        printf("Battery temperature: %s\n", localizedTemperature.UTF8String);
    }
    
    return ret;
}
