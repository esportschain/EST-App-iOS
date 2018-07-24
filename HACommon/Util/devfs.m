//
//  devfs.m
//

#include "devfs.h"
#include "unistd.h"
#include <stdio.h>
#include <sys/stat.h>
#include <unistd.h>
#include <dirent.h>
#include <fcntl.h>
#import <Foundation/Foundation.h>

char * g_document_directory = NULL;
char * g_cache_directory = NULL;

bool devFS_isFolderExist(const char* folder)
{
	if (NULL != folder) {
        BOOL isDir,valid;
        valid = [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:folder] isDirectory:&isDir];
        return valid && isDir;
    }
    
    return FALSE;
}

bool devFS_isFileExist(const char* filePathName)
{
	if (NULL != filePathName) {
        BOOL isDir,valid;
        valid = [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:filePathName] isDirectory:&isDir];
        return valid && !isDir;
    }
    
    return FALSE;
}

/**
 *  @brief   This function create folder.
 *
 *  @param   fileName   [I] Pointer to a null-terminated string that specifies the name of the folder object to create.
 *
 *  @return  If the function succeeds, the return value is TRUE. \
 *           If the function fails, FALSE;
 */
bool devFS_createFolder(const char* folder)
{
	if (NULL != folder) {
        NSFileManager* fileManager = [NSFileManager defaultManager];
        bool ret = [fileManager createDirectoryAtPath:[NSString stringWithUTF8String:folder] withIntermediateDirectories:YES attributes:nil error:nil];
        return ret;
    }
    
    return FALSE;
}

/**
 *  @brief   This function remove folder.
 *
 *  @param   fileName   [I] Pointer to a null-terminated string that specifies the name of the folder object to remove.
 *
 *  @return  If the function succeeds, the return value is TRUE. \
 *           If the function fails, FALSE;
 */
bool devFS_removeFolder(const char* folder)
{
	if (NULL != folder) {
		NSString* path = [NSString stringWithUTF8String:folder];
		NSFileManager* fileManager = [NSFileManager defaultManager];
		BOOL isDir;
		if ([fileManager fileExistsAtPath:path isDirectory:&isDir] && isDir) {
			if ([fileManager removeItemAtPath:path error:nil])
            {
                rmdir(folder);
				return TRUE;
            }
		}
	}
	
	return FALSE;
}

/**
 *  @brief   This function open a file according to opening mode.
 *
 *  @param   fileName   [I] Pointer to a null-terminated string that specifies the name of the file object to create or open.
 *  @param   openMode   [I] Specifies the opening mode.
 *
 *  @return  If the function success, the return value is a file handle. \
 *           If the function fails, the return value is $FO_INVALID_FILE_HANDLE$;
 *
 *  @note    When using $FO_FOPEN_CREATE$, the old file will be removed if it existed.
 *           Binary mode should be used whenever we call this function to open a file.
 *
 *  @see     #FO_FileOpenMode#, #devFS_closeFile#, #devFS_writeFile#, #devFS_readFile#, #devFS_seek#, #devFS_getFileLength#
 */
FO_FILE_HANDLE devFS_openFile(const char *fileName, FO_FileOpenMode openMode)
{
	if (NULL != fileName) {
        FO_FILE_HANDLE fh = NULL;
        const char* lpOpenMode = "rb";
        
        if(openMode == FO_FOPEN_CREATE)
        {
            lpOpenMode = "w+b";
        }
        else if(openMode == FO_FOPEN_READ)
        {
            lpOpenMode = "rb";
        }
        else if(openMode == FO_FOPEN_WRITE)
        {
            lpOpenMode = "w";
        }
        else if(openMode == FO_FOPEN_APPEND){
            lpOpenMode = "a";
        }
        else if(openMode == FO_FOPEN_READ_SEEK){
            lpOpenMode = "r+";
        }
        else if(openMode == FO_FOPEN_WRITE_SEEK){
            lpOpenMode = "w+";
        }
        
//        // 判断路径是否存在
//        NSString* filePathName = [NSString stringWithUTF8String:fileName];
//        NSRange range = [filePathName rangeOfString:@"/" options:NSBackwardsSearch];
//        if (range.location != NSNotFound) {
//            NSString* path = [filePathName substringToIndex:range.location];
//            if (!devFS_isFolderExist([path cStringUsingEncoding:NSUTF8StringEncoding])) {
//                devFS_createFolder([path cStringUsingEncoding:NSUTF8StringEncoding]);
//            }
//        }
        
        fh = (FO_FILE_HANDLE)fopen(fileName, lpOpenMode);
        if ( fh == NULL ) {
            fh = FO_INVALID_FILE_HANDLE;
        }
        
        return fh;
    }
    
    return FO_INVALID_FILE_HANDLE;
}

bool devFS_isHandleValid(FO_FILE_HANDLE fh)
{
    return fh != NULL && fh != FO_INVALID_FILE_HANDLE;
}

/**
 *  @brief   This function close the file handle which is opened by $devFS_openFile$.
 *
 *  @param   fh   [I] The file handle to be closed.
 *
 *  @return  If successful, the return value is nonzero. \
 *           Otherwise, the return value is zero.
 *
 *  @note    none.
 *
 *  @see     #devFS_openFile#
 */
bool  devFS_closeFile(FO_FILE_HANDLE fh)
{
	return (fclose((FILE*)fh) == 0);
}

/**
 *  @brief   This function read data to buffer according to the size to be read.
 *
 *  @param   fh     [I] The file handle to be read.
 *  @param   buffer [I] Storage location for data.
 *  @param   size   [I] Size (bytes) to be read.
 *
 *  @return  Function returns the number of full items actually read. which may
 *           be less than count if an error occurs or if the end of the file is
 *           encountered before reaching count. \
 *           If size or count is 0, fread returns 0 and the buffer contents are unchanged.
 *
 *  @note    none.
 *
 *  @see     #devFS_openFile#, #devFS_closeFile#, #devFS_writeFile#, #devFS_seek#, #devFS_getFileLength#
 */
unsigned int devFS_readFile(FO_FILE_HANDLE fh, void *buffer, unsigned int size)
{
	return (unsigned int)fread(buffer,1, size,(FILE*)fh);
}

/**
 *  @brief   This function save buffer to a file according to the size to be written.
 *
 *  @param   fh     [I] The file handle to be write.
 *  @param   buffer [I] Pointer to data to be written.
 *  @param   size   [I] Size (bytes) to be written.
 *
 *  @return  Function returns the number of full items actually written, which may
 *           be less than count if an error occurs. Also, if an error occurs, the
 *           file-position indicator cannot be determined.
 *
 *  @note    none.
 *
 *  @see     #devFS_openFile#, #devFS_closeFile#, #devFS_readFile#, #devFS_seek#, #devFS_getFileLength#
 */
unsigned int devFS_writeFile(FO_FILE_HANDLE fh, const void *buffer, unsigned int size)
{
    if (buffer && size > 0)
    {
        return fwrite(buffer, 1, size, (FILE*)fh);
    }
    else
    {
        return 0;
    }
}

/**
 *  @brief   Moves the file pointer to a specified location.
 *
 *  @param   fh     [I] File handle ,it should have be opened by other function call.
 *  @param   offset [I] Number of bytes from origin.
 *  @param   origin [I] Initial position.
 *
 *  @return  If successful, function returns 0. \n
 *           Otherwise, it returns a nonzero value.
 *
 *  @note    none.
 *
 *  @see     #FO_FileSeekMode#, #devFS_openFile#, #devFS_closeFile#, #devFS_readFile#, #devFS_writeFile#
 */
int devFS_seek(FO_FILE_HANDLE fh, int offset, FO_FileSeekMode origin)
{
	return fseek((FILE*)fh, offset, (int)origin);
}

/**
 *  @brief   This function get a file's length in bytes.
 *
 *  @param   fileName [I] Pointer to a null-terminated string that specifies the name of the file to be checked.
 *
 *  @return  If the function succeeds, the return value is the file size. \
 *           If the function fails, the return value is -1.
 *
 *  @note    none.
 *
 *  @see     #devFS_getFileLength#
 */
int devFS_getFileSize(const char *fileName)
{
	struct stat cacheStat = {0};
	stat(fileName, &cacheStat);
	return cacheStat.st_size;
}

/**
 *  @brief   This function get a file's length in bytes.
 *
 *  @param   fh [I] File handle, it should have be opened by other function call.
 *
 *  @return  If the function succeeds, the return value is the file size. \
 *           If the function fails, the return value is -1.
 *
 *  @note    none.
 *
 *  @see     #devFS_getFileSize#, #devFS_openFile#, #devFS_closeFile#, #devFS_readFile#, #devFS_writeFile#
 */
unsigned int devFS_getFileLength(FO_FILE_HANDLE fh)
{
	int nFileSize, nOldPos;
    
	// Save Old Position
	nOldPos = ftell((FILE*)fh);
    
	// Get File Size
	fseek((FILE*)fh, 0, SEEK_END);
	nFileSize = ftell((FILE *)fh);
    
	// Restore old position
	fseek((FILE*)fh, nOldPos, SEEK_SET);
    
	return nFileSize;
}

/**
 *  @brief   This function determines if a file of a particular name exists
 *           within the file system.
 *
 *  @param   fileName  [I] Pointer to a null-terminated string that specifies the name of the file to be checked.
 *
 *  @return  Function return nonzero, If exist; \n
 *           Otherwise, it return zero.
 *
 *  @note    none.
 *
 *  @see     #devFS_openFile#, #devFS_removeFile#
 */
bool devFS_fileExist(const char *fileName)
{
	return (bool)access(fileName, 0) == 0;
}

/**
 *  @brief   This function delete a file.
 *
 *  @param   fileName  [I] Pointer to a null-terminated string that specifies the name of the file to be deleted.
 *
 *  @return  If successful, the return value is nonzero.
 *           Otherwise, the return value is zero.
 *
 *  @note    If the file exists, the file will been deleted; otherwise it do nothing.
 *
 *  @see     #devFS_openFile#, #devFS_fileExist#
 */
bool devFS_removeFile(const char *fileName)
{
    return remove(fileName);
}

bool devFS_rename(const char * source,const char * target){
	return rename(source, target);
}

int devFS_flush(FO_FILE_HANDLE f){
	return fflush((FILE *)f);
}

void devFS_flushToFile(FO_FILE_HANDLE f)
{
    fcntl(fileno((FILE *)f), F_FULLFSYNC);
    fsync(fileno((FILE *)f));
}


FO_DIR_HANDLE devFS_openDir(const char * dir){
	return (FO_DIR_HANDLE)opendir(dir);
}

void devFS_closeDir(FO_DIR_HANDLE dir){
	closedir((DIR *)dir);
}

const char * devFS_readDir(FO_DIR_HANDLE dir){
	struct dirent * dirent = readdir((DIR *)dir);
	return dirent ? dirent->d_name : NULL;
}

int devFS_getPos(FO_FILE_HANDLE f){
    fpos_t pos = 0;
    return fgetpos((FILE *)f, &pos) ==0 ?pos:-1;
}

const char* devFS_getDocumentDirectory(void)
{
    if (g_document_directory == NULL)
	{
		const char * directory = (const char *)[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] UTF8String];
 		g_document_directory = malloc(strlen(directory) +1);
 		strcpy(g_document_directory,directory);
	}
	return g_document_directory;
}

const char* devFS_getCacheDirectory(void)
{
    if (g_cache_directory == NULL)
	{
		const char * directory = (const char *)[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] UTF8String];
 		g_cache_directory = malloc(strlen(directory) +1);
 		strcpy(g_cache_directory,directory);
	}
	return g_cache_directory;
}
