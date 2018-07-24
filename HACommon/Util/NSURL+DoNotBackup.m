#import "NSURL+DoNotBackup.h"
#import "sys/xattr.h"

TT_FIX_CATEGORY_BUG(NSURL_DoNotBackup)

@implementation NSURL(DoNotBackup)

- (BOOL) addSkipBackupAttribute
{
    const char* filePath = [[self path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    
    // First try and remove the extended attribute if it is present
    int result = getxattr(filePath, attrName, NULL, sizeof(u_int8_t), 0, 0);
    if (result != -1) {
        // The attribute exists, we need to remove it
        int removeResult = removexattr(filePath, attrName, 0);
        if (removeResult == 0) {
            DLog(@"Removed extended attribute on file %@", self);
        }
    }
    
    // Set the new key
    return [self setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
}

@end
