//
//  main.cpp
//  BackupMinderHelper
//
//  Created by Christopher Thompson on 9/23/12.
//
// Simple little program the execute the launchctl command
// Usage: BackupMinderHelper [-l | -u] plist_file_path
//
// Use the -l and -u flags so that I don't allow any args to be run

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char** argv)
{
    // Make sure I have 3 and only 3 arguments
    if (argc != 3)
    {
        printf( "Usage: BackupMinderHelper [-l | -u] plist_file_path\n");
        return -1;
    }
    
    bool load = true;
    //Check for load or unload
    if (strcmp(argv[1], "-l") == 0)
    {
        load = true;
    }
    else if (strcmp(argv[1], "-u") == 0)
    {
        load = false;
    }
    else
    {
        printf ("Unknown option %s\n", argv[1]);
        printf( "Usage: BackupMinderHelper [-l | -u] plist_file_path\n");
        return -1;
    }
    
    if (0 != setuid(0))
    {
        printf ("Failed to set UID to 0\n");
        return -3;
    }
    
    char* launchCmd = "/bin/launchctl";
    char* loadOption = "load";
    char* unloadOption = "unload";
    
    char** argvz = (char**)malloc(sizeof(char*) * argc);
    argvz[0] = launchCmd;
    argvz[1] = load ? loadOption : unloadOption;
    argvz[2] = argv[2];
    
    execv(argvz[0], argvz);
    return 0;
}