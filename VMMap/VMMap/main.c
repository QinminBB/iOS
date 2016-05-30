//
//  main.c
//  VMMap
//
//  Created by fanren on 16/5/30.
//  Copyright © 2016年 Qinmin. All rights reserved.
//

#include <stdio.h>
#include <mach/mach.h>

int main(int argc, const char * argv[]) {
    
    char test[14]   = "Hello World! "; //0x7fff5fbff82a
    
    char value[14]  = "Hello Hacker!";
    
    char test1[14];
    
    pointer_t buf;
    uint32_t sz;
    
    task_t task;
    
    task_for_pid(current_task(), getpid(), &task);
    
    if (vm_write(current_task(), 0x7fff5fbff82a, (pointer_t)value, 14) == KERN_SUCCESS) {
        
        printf("%s\n", test);
        //getchar();
    }
    
    if (vm_read(task, 0x7fff5fbff82a, sizeof(char) * 14, &buf, &sz) == KERN_SUCCESS) {
        
        memcpy(test1, (const void *)buf, sz);
        printf("%s", test1);
    }
    
    ioctl()
    
    return 0;
}
