#if __GLASGOW_HASKELL__ >= 709
{-# LANGUAGE Safe #-}
#else
{-# LANGUAGE Trustworthy #-}
#endif
-----------------------------------------------------------------------------
-- |
-- Module      :  System.Win32.File
-- Copyright   :  (c) Alastair Reid, 1997-2003
-- License     :  BSD-style (see the file libraries/base/LICENSE)
--
-- Maintainer  :  Esa Ilari Vuokko <ei@vuokko.info>
-- Stability   :  provisional
-- Portability :  portable
--
-- A collection of FFI declarations for interfacing with Win32.
--
-----------------------------------------------------------------------------

module System.Win32.File where

import System.Win32.Types
import System.Win32.Time

import Foreign hiding (void)
import Control.Monad
import Control.Concurrent

##include "windows_cconv.h"

#include <windows.h>
#include "alignment.h"

----------------------------------------------------------------
-- Enumeration types
----------------------------------------------------------------

type AccessMode   = UINT

gENERIC_NONE :: AccessMode
gENERIC_NONE = 0

#{enum AccessMode,
 , gENERIC_READ              = GENERIC_READ
 , gENERIC_WRITE             = GENERIC_WRITE
 , gENERIC_EXECUTE           = GENERIC_EXECUTE
 , gENERIC_ALL               = GENERIC_ALL
 , dELETE                    = DELETE
 , rEAD_CONTROL              = READ_CONTROL
 , wRITE_DAC                 = WRITE_DAC
 , wRITE_OWNER               = WRITE_OWNER
 , sYNCHRONIZE               = SYNCHRONIZE
 , sTANDARD_RIGHTS_REQUIRED  = STANDARD_RIGHTS_REQUIRED
 , sTANDARD_RIGHTS_READ      = STANDARD_RIGHTS_READ
 , sTANDARD_RIGHTS_WRITE     = STANDARD_RIGHTS_WRITE
 , sTANDARD_RIGHTS_EXECUTE   = STANDARD_RIGHTS_EXECUTE
 , sTANDARD_RIGHTS_ALL       = STANDARD_RIGHTS_ALL
 , sPECIFIC_RIGHTS_ALL       = SPECIFIC_RIGHTS_ALL
 , aCCESS_SYSTEM_SECURITY    = ACCESS_SYSTEM_SECURITY
 , mAXIMUM_ALLOWED           = MAXIMUM_ALLOWED
 , fILE_ADD_FILE             = FILE_ADD_FILE
 , fILE_ADD_SUBDIRECTORY     = FILE_ADD_SUBDIRECTORY
 , fILE_ALL_ACCESS           = FILE_ALL_ACCESS
 , fILE_APPEND_DATA          = FILE_APPEND_DATA
 , fILE_CREATE_PIPE_INSTANCE = FILE_CREATE_PIPE_INSTANCE
 , fILE_DELETE_CHILD         = FILE_DELETE_CHILD
 , fILE_EXECUTE              = FILE_EXECUTE
 , fILE_LIST_DIRECTORY       = FILE_LIST_DIRECTORY
 , fILE_READ_ATTRIBUTES      = FILE_READ_ATTRIBUTES
 , fILE_READ_DATA            = FILE_READ_DATA
 , fILE_READ_EA              = FILE_READ_EA
 , fILE_TRAVERSE             = FILE_TRAVERSE
 , fILE_WRITE_ATTRIBUTES     = FILE_WRITE_ATTRIBUTES
 , fILE_WRITE_DATA           = FILE_WRITE_DATA
 , fILE_WRITE_EA             = FILE_WRITE_EA
 }

----------------------------------------------------------------

type ShareMode   = UINT

fILE_SHARE_NONE :: ShareMode
fILE_SHARE_NONE = 0

#{enum ShareMode,
 , fILE_SHARE_READ      = FILE_SHARE_READ
 , fILE_SHARE_WRITE     = FILE_SHARE_WRITE
 , fILE_SHARE_DELETE    = FILE_SHARE_DELETE
 }

----------------------------------------------------------------

type CreateMode   = UINT

#{enum CreateMode,
 , cREATE_NEW           = CREATE_NEW
 , cREATE_ALWAYS        = CREATE_ALWAYS
 , oPEN_EXISTING        = OPEN_EXISTING
 , oPEN_ALWAYS          = OPEN_ALWAYS
 , tRUNCATE_EXISTING    = TRUNCATE_EXISTING
 }

----------------------------------------------------------------

type FileAttributeOrFlag   = UINT

#{enum FileAttributeOrFlag,
 , fILE_ATTRIBUTE_READONLY      = FILE_ATTRIBUTE_READONLY
 , fILE_ATTRIBUTE_HIDDEN        = FILE_ATTRIBUTE_HIDDEN
 , fILE_ATTRIBUTE_SYSTEM        = FILE_ATTRIBUTE_SYSTEM
 , fILE_ATTRIBUTE_DIRECTORY     = FILE_ATTRIBUTE_DIRECTORY
 , fILE_ATTRIBUTE_ARCHIVE       = FILE_ATTRIBUTE_ARCHIVE
 , fILE_ATTRIBUTE_NORMAL        = FILE_ATTRIBUTE_NORMAL
 , fILE_ATTRIBUTE_TEMPORARY     = FILE_ATTRIBUTE_TEMPORARY
 , fILE_ATTRIBUTE_COMPRESSED    = FILE_ATTRIBUTE_COMPRESSED
 , fILE_ATTRIBUTE_REPARSE_POINT = FILE_ATTRIBUTE_REPARSE_POINT
 , fILE_FLAG_WRITE_THROUGH      = FILE_FLAG_WRITE_THROUGH
 , fILE_FLAG_OVERLAPPED         = FILE_FLAG_OVERLAPPED
 , fILE_FLAG_NO_BUFFERING       = FILE_FLAG_NO_BUFFERING
 , fILE_FLAG_RANDOM_ACCESS      = FILE_FLAG_RANDOM_ACCESS
 , fILE_FLAG_SEQUENTIAL_SCAN    = FILE_FLAG_SEQUENTIAL_SCAN
 , fILE_FLAG_DELETE_ON_CLOSE    = FILE_FLAG_DELETE_ON_CLOSE
 , fILE_FLAG_BACKUP_SEMANTICS   = FILE_FLAG_BACKUP_SEMANTICS
 , fILE_FLAG_POSIX_SEMANTICS    = FILE_FLAG_POSIX_SEMANTICS
 }
#ifndef __WINE_WINDOWS_H
#{enum FileAttributeOrFlag,
 , sECURITY_ANONYMOUS           = SECURITY_ANONYMOUS
 , sECURITY_IDENTIFICATION      = SECURITY_IDENTIFICATION
 , sECURITY_IMPERSONATION       = SECURITY_IMPERSONATION
 , sECURITY_DELEGATION          = SECURITY_DELEGATION
 , sECURITY_CONTEXT_TRACKING    = SECURITY_CONTEXT_TRACKING
 , sECURITY_EFFECTIVE_ONLY      = SECURITY_EFFECTIVE_ONLY
 , sECURITY_SQOS_PRESENT        = SECURITY_SQOS_PRESENT
 , sECURITY_VALID_SQOS_FLAGS    = SECURITY_VALID_SQOS_FLAGS
 }
#endif

----------------------------------------------------------------

type MoveFileFlag   = DWORD

#{enum MoveFileFlag,
 , mOVEFILE_REPLACE_EXISTING    = MOVEFILE_REPLACE_EXISTING
 , mOVEFILE_COPY_ALLOWED        = MOVEFILE_COPY_ALLOWED
 , mOVEFILE_DELAY_UNTIL_REBOOT  = MOVEFILE_DELAY_UNTIL_REBOOT
 }

----------------------------------------------------------------

type FilePtrDirection   = DWORD

#{enum FilePtrDirection,
 , fILE_BEGIN   = FILE_BEGIN
 , fILE_CURRENT = FILE_CURRENT
 , fILE_END     = FILE_END
 }

----------------------------------------------------------------

type DriveType = UINT

#{enum DriveType,
 , dRIVE_UNKNOWN        = DRIVE_UNKNOWN
 , dRIVE_NO_ROOT_DIR    = DRIVE_NO_ROOT_DIR
 , dRIVE_REMOVABLE      = DRIVE_REMOVABLE
 , dRIVE_FIXED          = DRIVE_FIXED
 , dRIVE_REMOTE         = DRIVE_REMOTE
 , dRIVE_CDROM          = DRIVE_CDROM
 , dRIVE_RAMDISK        = DRIVE_RAMDISK
 }

----------------------------------------------------------------

type DefineDosDeviceFlags = DWORD

#{enum DefineDosDeviceFlags,
 , dDD_RAW_TARGET_PATH          = DDD_RAW_TARGET_PATH
 , dDD_REMOVE_DEFINITION        = DDD_REMOVE_DEFINITION
 , dDD_EXACT_MATCH_ON_REMOVE    = DDD_EXACT_MATCH_ON_REMOVE
 }

----------------------------------------------------------------

type BinaryType = DWORD

#{enum BinaryType,
 , sCS_32BIT_BINARY     = SCS_32BIT_BINARY
 , sCS_DOS_BINARY       = SCS_DOS_BINARY
 , sCS_WOW_BINARY       = SCS_WOW_BINARY
 , sCS_PIF_BINARY       = SCS_PIF_BINARY
 , sCS_POSIX_BINARY     = SCS_POSIX_BINARY
 , sCS_OS216_BINARY     = SCS_OS216_BINARY
 }

----------------------------------------------------------------

type FileNotificationFlag = DWORD

#{enum FileNotificationFlag,
 , fILE_NOTIFY_CHANGE_FILE_NAME  = FILE_NOTIFY_CHANGE_FILE_NAME
 , fILE_NOTIFY_CHANGE_DIR_NAME   = FILE_NOTIFY_CHANGE_DIR_NAME
 , fILE_NOTIFY_CHANGE_ATTRIBUTES = FILE_NOTIFY_CHANGE_ATTRIBUTES
 , fILE_NOTIFY_CHANGE_SIZE       = FILE_NOTIFY_CHANGE_SIZE
 , fILE_NOTIFY_CHANGE_LAST_WRITE = FILE_NOTIFY_CHANGE_LAST_WRITE
 , fILE_NOTIFY_CHANGE_SECURITY   = FILE_NOTIFY_CHANGE_SECURITY
 }

----------------------------------------------------------------

type FileType = DWORD

#{enum FileType,
 , fILE_TYPE_UNKNOWN    = FILE_TYPE_UNKNOWN
 , fILE_TYPE_DISK       = FILE_TYPE_DISK
 , fILE_TYPE_CHAR       = FILE_TYPE_CHAR
 , fILE_TYPE_PIPE       = FILE_TYPE_PIPE
 , fILE_TYPE_REMOTE     = FILE_TYPE_REMOTE
 }

----------------------------------------------------------------

type LockMode = DWORD

#{enum LockMode,
 , lOCKFILE_EXCLUSIVE_LOCK   = LOCKFILE_EXCLUSIVE_LOCK
 , lOCKFILE_FAIL_IMMEDIATELY = LOCKFILE_FAIL_IMMEDIATELY
 }

----------------------------------------------------------------

newtype GET_FILEEX_INFO_LEVELS = GET_FILEEX_INFO_LEVELS (#type GET_FILEEX_INFO_LEVELS)
    deriving (Eq, Ord)

#{enum GET_FILEEX_INFO_LEVELS, GET_FILEEX_INFO_LEVELS
 , getFileExInfoStandard = GetFileExInfoStandard
 , getFileExMaxInfoLevel = GetFileExMaxInfoLevel
 }

----------------------------------------------------------------

data STARTUPINFOA = STARTUPINFOA {
  cb :: DWORD,
  lpReserved :: LPCSTR,
  lpDesktop :: LPCSTR,
  lpTitle :: LPCSTR,
  dwX :: DWORD,
  dwY :: DWORD,
  dwXSize :: DWORD,
  dwYSize :: DWORD,
  dwXCountChars :: DWORD,
  dwYCountChars :: DWORD,
  dwFillAttribute :: DWORD,
  dwFlags :: DWORD,
  wShowWindow :: Word,
  cbReserved2 :: Word,
  lpReserved2 :: LPBYTE,
  hStdInput :: HANDLE,
  hStdOutput :: HANDLE,
  hStdError :: HANDLE
} deriving Show

type LPStartupInfoA = Ptr STARTUPINFOA

instance Storable STARTUPINFOA where
  sizeOf = const #{size STARTUPINFOA}
  alignment _ = #alignment STARTUPINFOA

  poke buf input = do
    (#poke STARTUPINFOA, cb) buf (cb input)
    (#poke STARTUPINFOA, lpReserved) buf (lpReserved input)
    (#poke STARTUPINFOA, lpDesktop) buf (lpDesktop input)
    (#poke STARTUPINFOA, lpTitle) buf (lpTitle input)
    (#poke STARTUPINFOA, dwX) buf (dwX input)
    (#poke STARTUPINFOA, dwY) buf (dwY input)
    (#poke STARTUPINFOA, dwXSize) buf (dwXSize input)
    (#poke STARTUPINFOA, dwYSize) buf (dwYSize input)
    (#poke STARTUPINFOA, dwXCountChars) buf (dwXCountChars input)
    (#poke STARTUPINFOA, dwYCountChars) buf (dwYCountChars input)
    (#poke STARTUPINFOA, dwFillAttribute) buf (dwFillAttribute input)
    (#poke STARTUPINFOA, dwFlags) buf (dwFlags input)
    (#poke STARTUPINFOA, wShowWindow) buf (wShowWindow input)
    (#poke STARTUPINFOA, cbReserved2) buf (cbReserved2 input)
    (#poke STARTUPINFOA, lpReserved2) buf (lpReserved2 input)
    (#poke STARTUPINFOA, hStdInput) buf (hStdInput input)
    (#poke STARTUPINFOA, hStdOutput) buf (hStdOutput input)
    (#poke STARTUPINFOA, hStdError) buf (hStdError input)

  peek p = do
    cb' <- (#peek STARTUPINFOA, cb) p
    lpReserved' <- (#peek STARTUPINFOA, lpReserved) p
    lpDesktop' <- (#peek STARTUPINFOA, lpDesktop) p
    lpTitle' <- (#peek STARTUPINFOA, lpTitle) p
    dwX' <- (#peek STARTUPINFOA, dwX) p
    dwY' <- (#peek STARTUPINFOA, dwY) p
    dwXSize' <- (#peek STARTUPINFOA, dwXSize) p
    dwYSize' <- (#peek STARTUPINFOA, dwYSize) p
    dwXCountChars' <- (#peek STARTUPINFOA, dwXCountChars) p
    dwYCountChars' <- (#peek STARTUPINFOA, dwYCountChars) p
    dwFillAttribute' <- (#peek STARTUPINFOA, dwFillAttribute) p
    dwFlags' <- (#peek STARTUPINFOA, dwFlags) p
    wShowWindow' <- (#peek STARTUPINFOA, wShowWindow) p
    cbReserved2' <- (#peek STARTUPINFOA, cbReserved2) p
    lpReserved2' <- (#peek STARTUPINFOA, lpReserved2) p
    hStdInput' <- (#peek STARTUPINFOA, hStdInput) p
    hStdOutput' <- (#peek STARTUPINFOA, hStdOutput) p
    hStdError' <- (#peek STARTUPINFOA, hStdError) p
    return $ STARTUPINFOA cb' lpReserved' lpDesktop' lpTitle' dwX' dwY' dwXSize' dwYSize' dwXCountChars' dwYCountChars' dwFillAttribute' dwFlags' wShowWindow' cbReserved2' lpReserved2' hStdInput' hStdOutput' hStdError'


foreign import WINDOWS_CCONV unsafe "windows.h InitializeProcThreadAttributeList"
  c_InitializeProcThreadAttributeList :: Ptr () -> DWORD -> DWORD -> Ptr SIZE_T -> IO BOOL

foreign import WINDOWS_CCONV unsafe "windows.h UpdateProcThreadAttribute"
  c_UpdateProcThreadAttribute :: Ptr () -> DWORD -> DWORD64 -> Ptr DWORD64 -> DWORD -> Ptr () -> Ptr () -> IO BOOL

data STARTUPINFOEXA = STARTUPINFOEXA {
  startupInfo :: Ptr STARTUPINFOA,
  lpAttributeList :: Ptr ()
} deriving (Show)

type LPSTARTUPINFOEXA = Ptr STARTUPINFOEXA

instance Storable STARTUPINFOEXA where
  sizeOf = const #{size STARTUPINFOEXA}
  alignment _ = #alignment STARTUPINFOEXA

  poke buf input = do
    (#poke STARTUPINFOEXA, StartupInfo) buf (startupInfo input)
    (#poke STARTUPINFOEXA, lpAttributeList) buf (lpAttributeList input)

  peek p = do
    startupInfo' <- (#peek STARTUPINFOEXA, StartupInfo) p
    lpAttributeList' <- (#peek STARTUPINFOEXA, lpAttributeList) p
    return $ STARTUPINFOEXA startupInfo' lpAttributeList'

data PROCESS_INFORMATION = PROCESS_INFORMATION {
  hProcess :: HANDLE,
  hThread :: HANDLE,
  dwProcessId :: DWORD,
  dwThreadId :: DWORD
} deriving (Show)

type LPPROCESS_INFORMATION = Ptr PROCESS_INFORMATION
type TESTPROCESS_INFORMATION = PROCESS_INFORMATION
instance Storable PROCESS_INFORMATION where
  sizeOf = const #{size PROCESS_INFORMATION}
  alignment _ = #alignment PROCESS_INFORMATION

  poke buf input = do
    (#poke PROCESS_INFORMATION, hProcess) buf (hProcess input)
    (#poke PROCESS_INFORMATION, hThread) buf (hThread input)
    (#poke PROCESS_INFORMATION, dwProcessId) buf (dwProcessId input)
    (#poke PROCESS_INFORMATION, dwThreadId) buf (dwThreadId input)

  peek p = do
    process <- (#peek PROCESS_INFORMATION, hProcess) p
    thread <- (#peek PROCESS_INFORMATION, hThread) p
    procId <-  (#peek PROCESS_INFORMATION, dwProcessId) p
    threadId <- (#peek PROCESS_INFORMATION, dwThreadId) p
    return $ PROCESS_INFORMATION process thread procId threadId

type ProcessCreationFlags = DWORD
#{enum ProcessCreationFlags,
  , eXTENDED_STARTUPINFO_PRESENT = EXTENDED_STARTUPINFO_PRESENT
  }


--createProcess :: LPCSTR -> LPCSTR -> Ptr () -> Ptr () -> BOOL -> DWORD -> Ptr () -> LPCSTR -> DWORD -> PROCESS_INFORMATION -> IO BOOL
--createProcess appName commandLine procAttr threadAttr inheritHandles dwCreationFlags lpEnvironment lpCurrentDir startupInfo processInfo = failIfNull "createProcess" $ c_CreateProcess appName commandLine procAttr threadAttr inheritHandles dwCreationFlags lpEnvironment lpCurrentDir startupInfo processInfo
foreign import WINDOWS_CCONV unsafe "windows.h CreateProcessA"
  c_CreateProcess :: LPCSTR -> LPCSTR -> Ptr () -> Ptr () -> BOOL -> DWORD -> Ptr () -> LPCSTR -> LPSTARTUPINFOEXA -> LPPROCESS_INFORMATION -> IO BOOL




data SECURITY_ATTRIBUTES = SECURITY_ATTRIBUTES
    { nLength              :: !DWORD
    , lpSecurityDescriptor :: !LPVOID
    , bInheritHandle       :: !BOOL
    } deriving Show

type PSECURITY_ATTRIBUTES = Ptr SECURITY_ATTRIBUTES
type LPSECURITY_ATTRIBUTES = Ptr SECURITY_ATTRIBUTES
type MbLPSECURITY_ATTRIBUTES = Maybe LPSECURITY_ATTRIBUTES

instance Storable SECURITY_ATTRIBUTES where
    sizeOf = const #{size SECURITY_ATTRIBUTES}
    alignment _ = #alignment SECURITY_ATTRIBUTES
    poke buf input = do
        (#poke SECURITY_ATTRIBUTES, nLength)              buf (nLength input)
        (#poke SECURITY_ATTRIBUTES, lpSecurityDescriptor) buf (lpSecurityDescriptor input)
        (#poke SECURITY_ATTRIBUTES, bInheritHandle)       buf (bInheritHandle input)
    peek buf = do
        nLength'              <- (#peek SECURITY_ATTRIBUTES, nLength)              buf
        lpSecurityDescriptor' <- (#peek SECURITY_ATTRIBUTES, lpSecurityDescriptor) buf
        bInheritHandle'       <- (#peek SECURITY_ATTRIBUTES, bInheritHandle)       buf
        return $ SECURITY_ATTRIBUTES nLength' lpSecurityDescriptor' bInheritHandle'

----------------------------------------------------------------
-- Other types
----------------------------------------------------------------

data BY_HANDLE_FILE_INFORMATION = BY_HANDLE_FILE_INFORMATION
    { bhfiFileAttributes :: FileAttributeOrFlag
    , bhfiCreationTime, bhfiLastAccessTime, bhfiLastWriteTime :: FILETIME
    , bhfiVolumeSerialNumber :: DWORD
    , bhfiSize :: DDWORD
    , bhfiNumberOfLinks :: DWORD
    , bhfiFileIndex :: DDWORD
    } deriving (Show)

instance Storable BY_HANDLE_FILE_INFORMATION where
    sizeOf = const (#size BY_HANDLE_FILE_INFORMATION)
    alignment _ = #alignment BY_HANDLE_FILE_INFORMATION
    poke buf bhi = do
        (#poke BY_HANDLE_FILE_INFORMATION, dwFileAttributes)     buf (bhfiFileAttributes bhi)
        (#poke BY_HANDLE_FILE_INFORMATION, ftCreationTime)       buf (bhfiCreationTime bhi)
        (#poke BY_HANDLE_FILE_INFORMATION, ftLastAccessTime)     buf (bhfiLastAccessTime bhi)
        (#poke BY_HANDLE_FILE_INFORMATION, ftLastWriteTime)      buf (bhfiLastWriteTime bhi)
        (#poke BY_HANDLE_FILE_INFORMATION, dwVolumeSerialNumber) buf (bhfiVolumeSerialNumber bhi)
        (#poke BY_HANDLE_FILE_INFORMATION, nFileSizeHigh)        buf sizeHi
        (#poke BY_HANDLE_FILE_INFORMATION, nFileSizeLow)         buf sizeLow
        (#poke BY_HANDLE_FILE_INFORMATION, nNumberOfLinks)       buf (bhfiNumberOfLinks bhi)
        (#poke BY_HANDLE_FILE_INFORMATION, nFileIndexHigh)       buf idxHi
        (#poke BY_HANDLE_FILE_INFORMATION, nFileIndexLow)        buf idxLow
        where
            (sizeHi,sizeLow) = ddwordToDwords $ bhfiSize bhi
            (idxHi,idxLow) = ddwordToDwords $ bhfiFileIndex bhi

    peek buf = do
        attr <- (#peek BY_HANDLE_FILE_INFORMATION, dwFileAttributes)     buf
        ctim <- (#peek BY_HANDLE_FILE_INFORMATION, ftCreationTime)       buf
        lati <- (#peek BY_HANDLE_FILE_INFORMATION, ftLastAccessTime)     buf
        lwti <- (#peek BY_HANDLE_FILE_INFORMATION, ftLastWriteTime)      buf
        vser <- (#peek BY_HANDLE_FILE_INFORMATION, dwVolumeSerialNumber) buf
        fshi <- (#peek BY_HANDLE_FILE_INFORMATION, nFileSizeHigh)        buf
        fslo <- (#peek BY_HANDLE_FILE_INFORMATION, nFileSizeLow)         buf
        link <- (#peek BY_HANDLE_FILE_INFORMATION, nNumberOfLinks)       buf
        idhi <- (#peek BY_HANDLE_FILE_INFORMATION, nFileIndexHigh)       buf
        idlo <- (#peek BY_HANDLE_FILE_INFORMATION, nFileIndexLow)        buf
        return $ BY_HANDLE_FILE_INFORMATION attr ctim lati lwti vser
            (dwordsToDdword (fshi,fslo)) link (dwordsToDdword (idhi,idlo))

----------------------------------------------------------------

data WIN32_FILE_ATTRIBUTE_DATA = WIN32_FILE_ATTRIBUTE_DATA
    { fadFileAttributes :: DWORD
    , fadCreationTime , fadLastAccessTime , fadLastWriteTime :: FILETIME
    , fadFileSize :: DDWORD
    } deriving (Show)

instance Storable WIN32_FILE_ATTRIBUTE_DATA where
    sizeOf = const (#size WIN32_FILE_ATTRIBUTE_DATA)
    alignment _ = #alignment WIN32_FILE_ATTRIBUTE_DATA
    poke buf ad = do
        (#poke WIN32_FILE_ATTRIBUTE_DATA, dwFileAttributes) buf (fadFileAttributes ad)
        (#poke WIN32_FILE_ATTRIBUTE_DATA, ftCreationTime)   buf (fadCreationTime ad)
        (#poke WIN32_FILE_ATTRIBUTE_DATA, ftLastAccessTime) buf (fadLastAccessTime ad)
        (#poke WIN32_FILE_ATTRIBUTE_DATA, ftLastWriteTime)  buf (fadLastWriteTime ad)
        (#poke WIN32_FILE_ATTRIBUTE_DATA, nFileSizeHigh)    buf sizeHi
        (#poke WIN32_FILE_ATTRIBUTE_DATA, nFileSizeLow)     buf sizeLo
        where
            (sizeHi,sizeLo) = ddwordToDwords $ fadFileSize ad

    peek buf = do
        attr <- (#peek WIN32_FILE_ATTRIBUTE_DATA, dwFileAttributes) buf
        ctim <- (#peek WIN32_FILE_ATTRIBUTE_DATA, ftCreationTime)   buf
        lati <- (#peek WIN32_FILE_ATTRIBUTE_DATA, ftLastAccessTime) buf
        lwti <- (#peek WIN32_FILE_ATTRIBUTE_DATA, ftLastWriteTime)  buf
        fshi <- (#peek WIN32_FILE_ATTRIBUTE_DATA, nFileSizeHigh)    buf
        fslo <- (#peek WIN32_FILE_ATTRIBUTE_DATA, nFileSizeLow)     buf
        return $ WIN32_FILE_ATTRIBUTE_DATA attr ctim lati lwti
            (dwordsToDdword (fshi,fslo))

----------------------------------------------------------------
-- File operations
----------------------------------------------------------------

-- | like failIfFalse_, but retried on sharing violations.
-- This is necessary for many file operations; see
--   http://support.microsoft.com/kb/316609
--
failIfWithRetry :: (a -> Bool) -> String -> IO a -> IO a
failIfWithRetry cond msg action = retryOrFail retries
  where
    delay   = 100*1000 -- in ms, we use threadDelay
    retries = 20 :: Int
      -- KB article recommends 250/5

    -- retryOrFail :: Int -> IO a
    retryOrFail times
      | times <= 0 = errorWin msg
      | otherwise  = do
         ret <- action
         if not (cond ret)
            then return ret
            else do
              err_code <- getLastError
              if err_code == (# const ERROR_SHARING_VIOLATION)
                then do threadDelay delay; retryOrFail (times - 1)
                else errorWin msg

failIfWithRetry_ :: (a -> Bool) -> String -> IO a -> IO ()
failIfWithRetry_ cond msg action = void $ failIfWithRetry cond msg action

failIfFalseWithRetry_ :: String -> IO Bool -> IO ()
failIfFalseWithRetry_ = failIfWithRetry_ not

deleteFile :: String -> IO ()
deleteFile name =
  withTString name $ \ c_name ->
    failIfFalseWithRetry_ (unwords ["DeleteFile",show name]) $
      c_DeleteFile c_name
foreign import WINDOWS_CCONV unsafe "windows.h DeleteFileW"
  c_DeleteFile :: LPCTSTR -> IO Bool

copyFile :: String -> String -> Bool -> IO ()
copyFile src dest over =
  withTString src $ \ c_src ->
  withTString dest $ \ c_dest ->
  failIfFalseWithRetry_ (unwords ["CopyFile",show src,show dest]) $
    c_CopyFile c_src c_dest over
foreign import WINDOWS_CCONV unsafe "windows.h CopyFileW"
  c_CopyFile :: LPCTSTR -> LPCTSTR -> Bool -> IO Bool

moveFile :: String -> String -> IO ()
moveFile src dest =
  withTString src $ \ c_src ->
  withTString dest $ \ c_dest ->
  failIfFalseWithRetry_ (unwords ["MoveFile",show src,show dest]) $
    c_MoveFile c_src c_dest
foreign import WINDOWS_CCONV unsafe "windows.h MoveFileW"
  c_MoveFile :: LPCTSTR -> LPCTSTR -> IO Bool

moveFileEx :: String -> Maybe String -> MoveFileFlag -> IO ()
moveFileEx src dest flags =
  withTString src $ \ c_src ->
  maybeWith withTString dest $ \ c_dest ->
  failIfFalseWithRetry_ (unwords ["MoveFileEx",show src,show dest]) $
    c_MoveFileEx c_src c_dest flags
foreign import WINDOWS_CCONV unsafe "windows.h MoveFileExW"
  c_MoveFileEx :: LPCTSTR -> LPCTSTR -> MoveFileFlag -> IO Bool

setCurrentDirectory :: String -> IO ()
setCurrentDirectory name =
  withTString name $ \ c_name ->
  failIfFalse_ (unwords ["SetCurrentDirectory",show name]) $
    c_SetCurrentDirectory c_name
foreign import WINDOWS_CCONV unsafe "windows.h SetCurrentDirectoryW"
  c_SetCurrentDirectory :: LPCTSTR -> IO Bool

createDirectory :: String -> Maybe LPSECURITY_ATTRIBUTES -> IO ()
createDirectory name mb_attr =
  withTString name $ \ c_name ->
  failIfFalseWithRetry_ (unwords ["CreateDirectory",show name]) $
    c_CreateDirectory c_name (maybePtr mb_attr)
foreign import WINDOWS_CCONV unsafe "windows.h CreateDirectoryW"
  c_CreateDirectory :: LPCTSTR -> LPSECURITY_ATTRIBUTES -> IO Bool

createDirectoryEx :: String -> String -> Maybe LPSECURITY_ATTRIBUTES -> IO ()
createDirectoryEx template name mb_attr =
  withTString template $ \ c_template ->
  withTString name $ \ c_name ->
  failIfFalseWithRetry_ (unwords ["CreateDirectoryEx",show template,show name]) $
    c_CreateDirectoryEx c_template c_name (maybePtr mb_attr)
foreign import WINDOWS_CCONV unsafe "windows.h CreateDirectoryExW"
  c_CreateDirectoryEx :: LPCTSTR -> LPCTSTR -> LPSECURITY_ATTRIBUTES -> IO Bool

removeDirectory :: String -> IO ()
removeDirectory name =
  withTString name $ \ c_name ->
  failIfFalseWithRetry_ (unwords ["RemoveDirectory",show name]) $
    c_RemoveDirectory c_name
foreign import WINDOWS_CCONV unsafe "windows.h RemoveDirectoryW"
  c_RemoveDirectory :: LPCTSTR -> IO Bool

getBinaryType :: String -> IO BinaryType
getBinaryType name =
  withTString name $ \ c_name ->
  alloca $ \ p_btype -> do
  failIfFalse_ (unwords ["GetBinaryType",show name]) $
    c_GetBinaryType c_name p_btype
  peek p_btype
foreign import WINDOWS_CCONV unsafe "windows.h GetBinaryTypeW"
  c_GetBinaryType :: LPCTSTR -> Ptr DWORD -> IO Bool

----------------------------------------------------------------
-- HANDLE operations
----------------------------------------------------------------

createFile :: String -> AccessMode -> ShareMode -> Maybe LPSECURITY_ATTRIBUTES -> CreateMode -> FileAttributeOrFlag -> Maybe HANDLE -> IO HANDLE
createFile name access share mb_attr mode flag mb_h =
  withTString name $ \ c_name ->
  failIfWithRetry (==iNVALID_HANDLE_VALUE) (unwords ["CreateFile",show name]) $
    c_CreateFile c_name access share (maybePtr mb_attr) mode flag (maybePtr mb_h)
foreign import WINDOWS_CCONV unsafe "windows.h CreateFileW"
  c_CreateFile :: LPCTSTR -> AccessMode -> ShareMode -> LPSECURITY_ATTRIBUTES -> CreateMode -> FileAttributeOrFlag -> HANDLE -> IO HANDLE

closeHandle :: HANDLE -> IO ()
closeHandle h =
  failIfFalse_ "CloseHandle" $ c_CloseHandle h
foreign import WINDOWS_CCONV unsafe "windows.h CloseHandle"
  c_CloseHandle :: HANDLE -> IO Bool

{-# CFILES cbits/HsWin32.c #-}
foreign import ccall "HsWin32.h &CloseHandleFinaliser"
    c_CloseHandleFinaliser :: FunPtr (Ptr a -> IO ())

foreign import WINDOWS_CCONV unsafe "windows.h GetFileType"
  getFileType :: HANDLE -> IO FileType
--Apparently no error code

flushFileBuffers :: HANDLE -> IO ()
flushFileBuffers h =
  failIfFalse_ "FlushFileBuffers" $ c_FlushFileBuffers h
foreign import WINDOWS_CCONV unsafe "windows.h FlushFileBuffers"
  c_FlushFileBuffers :: HANDLE -> IO Bool

setEndOfFile :: HANDLE -> IO ()
setEndOfFile h =
  failIfFalse_ "SetEndOfFile" $ c_SetEndOfFile h
foreign import WINDOWS_CCONV unsafe "windows.h SetEndOfFile"
  c_SetEndOfFile :: HANDLE -> IO Bool

setFileAttributes :: String -> FileAttributeOrFlag -> IO ()
setFileAttributes name attr =
  withTString name $ \ c_name ->
  failIfFalseWithRetry_ (unwords ["SetFileAttributes",show name])
    $ c_SetFileAttributes c_name attr
foreign import WINDOWS_CCONV unsafe "windows.h SetFileAttributesW"
  c_SetFileAttributes :: LPCTSTR -> FileAttributeOrFlag -> IO Bool

getFileAttributes :: String -> IO FileAttributeOrFlag
getFileAttributes name =
  withTString name $ \ c_name ->
  failIfWithRetry (== 0xFFFFFFFF) (unwords ["GetFileAttributes",show name]) $
    c_GetFileAttributes c_name
foreign import WINDOWS_CCONV unsafe "windows.h GetFileAttributesW"
  c_GetFileAttributes :: LPCTSTR -> IO FileAttributeOrFlag

getFileAttributesExStandard :: String -> IO WIN32_FILE_ATTRIBUTE_DATA
getFileAttributesExStandard name =  alloca $ \res -> do
  withTString name $ \ c_name ->
    failIfFalseWithRetry_ "getFileAttributesExStandard" $
      c_GetFileAttributesEx c_name getFileExInfoStandard res
  peek res
foreign import WINDOWS_CCONV unsafe "windows.h GetFileAttributesExW"
  c_GetFileAttributesEx :: LPCTSTR -> GET_FILEEX_INFO_LEVELS -> Ptr a -> IO BOOL

getFileInformationByHandle :: HANDLE -> IO BY_HANDLE_FILE_INFORMATION
getFileInformationByHandle h = alloca $ \res -> do
    failIfFalseWithRetry_ "GetFileInformationByHandle" $ c_GetFileInformationByHandle h res
    peek res
foreign import WINDOWS_CCONV unsafe "windows.h GetFileInformationByHandle"
    c_GetFileInformationByHandle :: HANDLE -> Ptr BY_HANDLE_FILE_INFORMATION -> IO BOOL

----------------------------------------------------------------
-- Read/write files
----------------------------------------------------------------

-- No support for this yet
data OVERLAPPED
  = OVERLAPPED { ovl_internal     :: ULONG_PTR
               , ovl_internalHigh :: ULONG_PTR
               , ovl_offset       :: DWORD
               , ovl_offsetHigh   :: DWORD
               , ovl_hEvent       :: HANDLE
               } deriving (Show)

instance Storable OVERLAPPED where
  sizeOf = const (#size OVERLAPPED)
  alignment _ = #alignment OVERLAPPED
  poke buf ad = do
      (#poke OVERLAPPED, Internal    ) buf (ovl_internal     ad)
      (#poke OVERLAPPED, InternalHigh) buf (ovl_internalHigh ad)
      (#poke OVERLAPPED, Offset      ) buf (ovl_offset       ad)
      (#poke OVERLAPPED, OffsetHigh  ) buf (ovl_offsetHigh   ad)
      (#poke OVERLAPPED, hEvent      ) buf (ovl_hEvent       ad)

  peek buf = do
      intnl      <- (#peek OVERLAPPED, Internal    ) buf
      intnl_high <- (#peek OVERLAPPED, InternalHigh) buf
      off        <- (#peek OVERLAPPED, Offset      ) buf
      off_high   <- (#peek OVERLAPPED, OffsetHigh  ) buf
      hevnt      <- (#peek OVERLAPPED, hEvent      ) buf
      return $ OVERLAPPED intnl intnl_high off off_high hevnt

type LPOVERLAPPED = Ptr OVERLAPPED

type MbLPOVERLAPPED = Maybe LPOVERLAPPED

--Sigh - I give up & prefix win32_ to the next two to avoid
-- senseless Prelude name clashes. --sof.

win32_ReadFile :: HANDLE -> Ptr a -> DWORD -> Maybe LPOVERLAPPED -> IO DWORD
win32_ReadFile h buf n mb_over =
  alloca $ \ p_n -> do
  failIfFalse_ "ReadFile" $ c_ReadFile h buf n p_n (maybePtr mb_over)
  peek p_n
foreign import WINDOWS_CCONV unsafe "windows.h ReadFile"
  c_ReadFile :: HANDLE -> Ptr a -> DWORD -> Ptr DWORD -> LPOVERLAPPED -> IO Bool

win32_WriteFile :: HANDLE -> Ptr a -> DWORD -> Maybe LPOVERLAPPED -> IO DWORD
win32_WriteFile h buf n mb_over =
  alloca $ \ p_n -> do
  failIfFalse_ "WriteFile" $ c_WriteFile h buf n p_n (maybePtr mb_over)
  peek p_n
foreign import WINDOWS_CCONV unsafe "windows.h WriteFile"
  c_WriteFile :: HANDLE -> Ptr a -> DWORD -> Ptr DWORD -> LPOVERLAPPED -> IO Bool

setFilePointerEx :: HANDLE -> LARGE_INTEGER -> FilePtrDirection -> IO LARGE_INTEGER
setFilePointerEx h dist dir =
  alloca $ \p_pos -> do
  failIfFalse_ "SetFilePointerEx" $ c_SetFilePointerEx h dist p_pos dir
  peek p_pos
foreign import WINDOWS_CCONV unsafe "windows.h SetFilePointerEx"
  c_SetFilePointerEx :: HANDLE -> LARGE_INTEGER -> Ptr LARGE_INTEGER -> FilePtrDirection -> IO Bool

----------------------------------------------------------------
-- File Notifications
--
-- Use these to initialise, "increment" and close a HANDLE you can wait
-- on.
----------------------------------------------------------------

findFirstChangeNotification :: String -> Bool -> FileNotificationFlag -> IO HANDLE
findFirstChangeNotification path watch flag =
  withTString path $ \ c_path ->
  failIfNull (unwords ["FindFirstChangeNotification",show path]) $
    c_FindFirstChangeNotification c_path watch flag
foreign import WINDOWS_CCONV unsafe "windows.h FindFirstChangeNotificationW"
  c_FindFirstChangeNotification :: LPCTSTR -> Bool -> FileNotificationFlag -> IO HANDLE

findNextChangeNotification :: HANDLE -> IO ()
findNextChangeNotification h =
  failIfFalse_ "FindNextChangeNotification" $ c_FindNextChangeNotification h
foreign import WINDOWS_CCONV unsafe "windows.h FindNextChangeNotification"
  c_FindNextChangeNotification :: HANDLE -> IO Bool

findCloseChangeNotification :: HANDLE -> IO ()
findCloseChangeNotification h =
  failIfFalse_ "FindCloseChangeNotification" $ c_FindCloseChangeNotification h
foreign import WINDOWS_CCONV unsafe "windows.h FindCloseChangeNotification"
  c_FindCloseChangeNotification :: HANDLE -> IO Bool

----------------------------------------------------------------
-- Directories
----------------------------------------------------------------

type WIN32_FIND_DATA = ()

newtype FindData = FindData (ForeignPtr WIN32_FIND_DATA)

getFindDataFileName :: FindData -> IO FilePath
getFindDataFileName (FindData fp) =
  withForeignPtr fp $ \p ->
    peekTString ((# ptr WIN32_FIND_DATAW, cFileName ) p)

findFirstFile :: String -> IO (HANDLE, FindData)
findFirstFile str = do
  fp_finddata <- mallocForeignPtrBytes (# const sizeof(WIN32_FIND_DATAW) )
  withForeignPtr fp_finddata $ \p_finddata -> do
    handle <- withTString str $ \tstr -> do
                failIf (== iNVALID_HANDLE_VALUE) "findFirstFile" $
                  c_FindFirstFile tstr p_finddata
    return (handle, FindData fp_finddata)
foreign import WINDOWS_CCONV unsafe "windows.h FindFirstFileW"
  c_FindFirstFile :: LPCTSTR -> Ptr WIN32_FIND_DATA -> IO HANDLE

findNextFile :: HANDLE -> FindData -> IO Bool -- False -> no more files
findNextFile h (FindData finddata) = do
  withForeignPtr finddata $ \p_finddata -> do
    b <- c_FindNextFile h p_finddata
    if b
       then return True
       else do
             err_code <- getLastError
             if err_code == (# const ERROR_NO_MORE_FILES )
                then return False
                else failWith "findNextFile" err_code
foreign import WINDOWS_CCONV unsafe "windows.h FindNextFileW"
  c_FindNextFile :: HANDLE -> Ptr WIN32_FIND_DATA -> IO BOOL

findClose :: HANDLE -> IO ()
findClose h = failIfFalse_ "findClose" $ c_FindClose h
foreign import WINDOWS_CCONV unsafe "windows.h FindClose"
  c_FindClose :: HANDLE -> IO BOOL

----------------------------------------------------------------
-- DOS Device flags
----------------------------------------------------------------

defineDosDevice :: DefineDosDeviceFlags -> String -> Maybe String -> IO ()
defineDosDevice flags name path =
  maybeWith withTString path $ \ c_path ->
  withTString name $ \ c_name ->
  failIfFalse_ "DefineDosDevice" $ c_DefineDosDevice flags c_name c_path
foreign import WINDOWS_CCONV unsafe "windows.h DefineDosDeviceW"
  c_DefineDosDevice :: DefineDosDeviceFlags -> LPCTSTR -> LPCTSTR -> IO Bool

----------------------------------------------------------------

-- These functions are very unusual in the Win32 API:
-- They dont return error codes

foreign import WINDOWS_CCONV unsafe "windows.h AreFileApisANSI"
  areFileApisANSI :: IO Bool

foreign import WINDOWS_CCONV unsafe "windows.h SetFileApisToOEM"
  setFileApisToOEM :: IO ()

foreign import WINDOWS_CCONV unsafe "windows.h SetFileApisToANSI"
  setFileApisToANSI :: IO ()

foreign import WINDOWS_CCONV unsafe "windows.h SetHandleCount"
  setHandleCount :: UINT -> IO UINT

----------------------------------------------------------------

getLogicalDrives :: IO DWORD
getLogicalDrives =
  failIfZero "GetLogicalDrives" $ c_GetLogicalDrives
foreign import WINDOWS_CCONV unsafe "windows.h GetLogicalDrives"
  c_GetLogicalDrives :: IO DWORD

-- %fun GetDriveType :: Maybe String -> IO DriveType

getDiskFreeSpace :: Maybe String -> IO (DWORD,DWORD,DWORD,DWORD)
getDiskFreeSpace path =
  maybeWith withTString path $ \ c_path ->
  alloca $ \ p_sectors ->
  alloca $ \ p_bytes ->
  alloca $ \ p_nfree ->
  alloca $ \ p_nclusters -> do
  failIfFalse_ "GetDiskFreeSpace" $
    c_GetDiskFreeSpace c_path p_sectors p_bytes p_nfree p_nclusters
  sectors <- peek p_sectors
  bytes <- peek p_bytes
  nfree <- peek p_nfree
  nclusters <- peek p_nclusters
  return (sectors, bytes, nfree, nclusters)
foreign import WINDOWS_CCONV unsafe "windows.h GetDiskFreeSpaceW"
  c_GetDiskFreeSpace :: LPCTSTR -> Ptr DWORD -> Ptr DWORD -> Ptr DWORD -> Ptr DWORD -> IO Bool

setVolumeLabel :: Maybe String -> Maybe String -> IO ()
setVolumeLabel path name =
  maybeWith withTString path $ \ c_path ->
  maybeWith withTString name $ \ c_name ->
  failIfFalse_ "SetVolumeLabel" $ c_SetVolumeLabel c_path c_name
foreign import WINDOWS_CCONV unsafe "windows.h SetVolumeLabelW"
  c_SetVolumeLabel :: LPCTSTR -> LPCTSTR -> IO Bool

----------------------------------------------------------------
-- File locks
----------------------------------------------------------------

-- | Locks a given range in a file handle, To lock an entire file
--   use 0xFFFFFFFFFFFFFFFF for size and 0 for offset.
lockFile :: HANDLE   -- ^ CreateFile handle
         -> LockMode -- ^ Locking mode
         -> DWORD64  -- ^ Size of region to lock
         -> DWORD64  -- ^ Beginning offset of file to lock
         -> IO BOOL  -- ^ Indicates if locking was successful, if not query
                     --   getLastError.
lockFile hwnd mode size f_offset =
  do let s_low = fromIntegral (size .&. 0xFFFFFFFF)
         s_hi  = fromIntegral (size `shiftR` 32)
         o_low = fromIntegral (f_offset .&. 0xFFFFFFFF)
         o_hi  = fromIntegral (f_offset `shiftR` 32)
         ovlp  = OVERLAPPED 0 0 o_low o_hi nullPtr
     with ovlp $ \ptr -> c_LockFileEx hwnd mode 0 s_low s_hi ptr

foreign import WINDOWS_CCONV unsafe "LockFileEx"
  c_LockFileEx :: HANDLE -> DWORD -> DWORD -> DWORD -> DWORD -> LPOVERLAPPED
               -> IO BOOL

-- | Unlocks a given range in a file handle, To unlock an entire file
--   use 0xFFFFFFFFFFFFFFFF for size and 0 for offset.
unlockFile :: HANDLE  -- ^ CreateFile handle
           -> DWORD64 -- ^ Size of region to unlock
           -> DWORD64 -- ^ Beginning offset of file to unlock
           -> IO BOOL -- ^ Indicates if unlocking was successful, if not query
                      --   getLastError.
unlockFile hwnd size f_offset =
  do let s_low = fromIntegral (size .&. 0xFFFFFFFF)
         s_hi  = fromIntegral (size `shiftR` 32)
         o_low = fromIntegral (f_offset .&. 0xFFFFFFFF)
         o_hi  = fromIntegral (f_offset `shiftR` 32)
         ovlp  = OVERLAPPED 0 0 o_low o_hi nullPtr
     with ovlp $ \ptr -> c_UnlockFileEx hwnd 0 s_low s_hi ptr

foreign import WINDOWS_CCONV unsafe "UnlockFileEx"
  c_UnlockFileEx :: HANDLE -> DWORD -> DWORD -> DWORD -> LPOVERLAPPED -> IO BOOL

----------------------------------------------------------------
-- End
----------------------------------------------------------------
