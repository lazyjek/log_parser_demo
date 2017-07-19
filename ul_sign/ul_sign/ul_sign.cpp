#include <string.h>
#include "ul_prime.h"

int creat_sign_fs64(char* psrc,int slen,unsigned int* sign1,unsigned int * sign2)
{
    *sign1=0;
    *sign2=0;
    if( slen <= 4 )
    {
        memcpy(sign1,psrc,slen);
        return 1;
    }
    else 
        if(slen<=8)
        {
            memcpy(sign1,psrc,4);
            memcpy(sign2,psrc+4,slen-4);
            return 1;
        }
        else
        {
            (*sign1)=getsigns_24_1(psrc,slen);
            (*sign2)=getsigns_24_2(psrc,slen);
            return 1;
        }
}

unsigned long int get_sign(char * key_buf)
{
    unsigned int signs[2];
    creat_sign_fs64(key_buf, strlen(key_buf), &signs[0], &signs[1]);
    unsigned long int result = (unsigned long int)signs[0] << 32 | (unsigned long int)signs[1];
    return result;
}
