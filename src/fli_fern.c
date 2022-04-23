//-------------------------------------------------------------------------------------------------
// FLI Socket Fern Interface
//
// Set up socket, transmit string to Fern server.
//
// This library is free software; you can redistribute it and/or modify it 
// under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation; either version 2.1 of the License, or 
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.   See the GNU Lesser General Public 
// License for more details.   See http://www.gnu.org/copyleft/lesser.txt
//
//-------------------------------------------------------------------------------------------------
// Version   Author          Date          Changes
// 0.1       Hans Tiggeler   17 Feb 2003   Tested on Modelsim SE 5.7b
// 0.2       Hans Tiggeler   15 May 2014   Minor clean up, tested 10.3a
// 0.3       Hans Tiggeler   22 April 2022 Updated for 64bits Modelsim DE
//-------------------------------------------------------------------------------------------------
#include <stdio.h>
#include <math.h>
#include <fcntl.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>

#include "mti.h"                                    // MTI Headers & Prototypes

// Sockets Definitions 
#ifdef WIN32
    #include <winsock.h>
#else
    #include <unistd.h>
    #include <sys/time.h>
    #include <sys/param.h>
    #include <sys/socket.h>
    #include <netinet/in.h>
    #include <netdb.h>                              // defines gethostbyname()
#endif

#ifdef WIN32
    #define MAXHOSTNAMELEN MAXGETHOSTSTRUCT
#else
    #define SOCKET_ERROR -1
    #define INVALID_SOCKET -1
    typedef int SOCKET;
#endif


#define MAXCOOR     256                             // Maximum number of coordinates per packet

typedef enum {                                      // std_logic enumerated type
    STD_LOGIC_U,
    STD_LOGIC_X,
    STD_LOGIC_0,
    STD_LOGIC_1,
    STD_LOGIC_Z,
    STD_LOGIC_W,
    STD_LOGIC_L,
    STD_LOGIC_H,
    STD_LOGIC_D
} StdLogicType;

typedef struct {                                    // Entity ports 
     mtiSignalIdT clk ;                        
     mtiSignalIdT reset;                        
     mtiSignalIdT x;                        
     mtiSignalIdT y;
     SOCKET       sd;                               // Socket Descriptor         
} inst_rec;

static char *buffer;                                // Transmit buffer for coordinates

int debug=0;                                        // set to 1 to enable debug
static int end_fern=0;                              // controlled by endfern command

// Prototypes
static void fern_tester(void *param);       
mtiUInt32T conv_std_logic_vector(mtiSignalIdT stdvec);
SOCKET init_sockets(char *hostname, int port);
int     send_packet(SOCKET sd, char *buffer,int buffer_size); 
void    endfern(void *param);
void    close_socket(SOCKET sd);


void cif_init( mtiRegionIdT region, char *param, mtiInterfaceListT *generics, mtiInterfaceListT *ports)
{
    inst_rec    *ip;                                // Declare ports            
    mtiProcessIdT proc;                             // current process id
    char        hostname[80];
    int         port=2000;

    ip = (inst_rec *)mti_Malloc(sizeof(inst_rec));  // allocate memory for ports
    mti_AddRestartCB(mti_Free, ip);                 // restart entry point

    ip->clk         = mti_FindPort(ports, "clk");   // Get entity ports
    ip->reset       = mti_FindPort(ports, "reset");                        
    ip->x           = mti_FindPort(ports, "x");                        
    ip->y           = mti_FindPort(ports, "y");                         

    end_fern=0;                                     // Reset after elaboration

    proc = mti_CreateProcess("fern_tester", fern_tester, ip);
    mti_Sensitize(proc, ip->clk, MTI_EVENT);        // Add sensitivity signals
    mti_Sensitize(proc, ip->reset, MTI_EVENT);

    strcpy(hostname,"localhost");
    port=2000;

    mti_PrintFormatted("Opening socket %d on %s\n",port,hostname);

    if ((ip->sd=init_sockets(hostname,port))==SOCKET_ERROR) {   // Get socket descriptor
        mti_PrintMessage("*** Socket init error, is the server running? ***\n");
        mti_FatalError();                           // Do not continue if fail
    }                               
    
    // Allocate memory for coordinates buffer
    if ((buffer=(char *)mti_Malloc(MAXCOOR*sizeof(unsigned int)))==NULL) {
        mti_PrintMessage("*** MTI Memory Allocation failure ***\n");
        mti_FatalError();                           // Do not continue
    }

    mti_AddCommand("endfern", endfern);

    mti_PrintMessage("\ncif_init (socket version) called\n");
}

static void fern_tester(void *param)                // C version of vhdl_fern process
{
    inst_rec * ip = (inst_rec *)param;
    static unsigned int i=0;                        // Buffer pointer
    unsigned int x,y;                               // Pixel coordinates
    int len;

    if (mti_GetSignalValue(ip->clk)==STD_LOGIC_1) {
        if (mti_GetSignalValue(ip->reset)==STD_LOGIC_0) {   // Check reset negated
            x=conv_std_logic_vector(ip->x);
            y=conv_std_logic_vector(ip->y);
            if (debug) mti_PrintFormatted("\n X=%u Y=%u",x,y);
            buffer[i++]=x&0xFF; 
            buffer[i++]=(x>>8)&0xFF;
            buffer[i++]=y&0xFF;
            buffer[i++]=(y>>8)&0xFF;

            if (i>=MAXCOOR)  {                      // Buffer full?
                i=0;                                // Reset pointer and transmit packet
                len=send_packet(ip->sd,(char *)buffer,MAXCOOR*sizeof(int));
                mti_PrintFormatted("\nTransmitted %d coordinates",len/sizeof(int));
            }   
            
            if (end_fern) {
                close_socket(ip->sd);
                free(buffer);
            }               
        }           
    }
}

void endfern(void * param)
{
    char * command = param;

    end_fern=1;
    mti_PrintFormatted("**** Command %s issued, Fern simulation canceled ****\n",command);
}

void close_socket(SOCKET sd)
{
#ifdef WIN32
    closesocket(sd);
#else
    close(sd);
#endif
    mti_PrintMessage("**** Socket removed ****\n");
}

int send_packet(SOCKET sd, char *buffer,int buffer_size) 
{ 
    int len; 
    int i=0; 

    do { 
        len=send(sd,&buffer[i],buffer_size-i,0); 
        i+=len; 
    } while(i<buffer_size && len>0); 

    return i; 
} 

SOCKET init_sockets(char *hostname, int port)
{
    SOCKET  sd;
    struct  sockaddr_in pin;
    struct  hostent *hp;
    int     status;

    // Do some windows stuff, copied from FLI manual
    #ifdef WIN32
        WORD wVersionRequested;
        WSADATA wsaData;
        int err;

        wVersionRequested = MAKEWORD( 1, 1 );
        err = WSAStartup( wVersionRequested, &wsaData );
        if ( err != 0 ) {
            mti_PrintMessage("**** Cannot find a usable winsock.dll ***\n" );
            return SOCKET_ERROR;
        }

        /* Confirm that the Windows Sockets DLL supports 1.1. Note that if
         * the DLL supports versions greater than 1.1 in addition to 1.1,
         * it will still return 1.1 in wVersion since that is the version
         * we requested. */
        if ( (LOBYTE( wsaData.wVersion ) != 1) || (HIBYTE( wsaData.wVersion ) != 1) ) {
            mti_PrintMessage("*** Cannot find a usable winsock.dll ***\n" );
            WSACleanup();
            return SOCKET_ERROR;
        }
        /* The Windows Sockets DLL is acceptable. Proceed. */
    #endif


    // Request Stream socket from OS using default protocol
    if ((sd = socket(AF_INET, SOCK_STREAM, 0)) == INVALID_SOCKET) {
        #ifdef WIN32
            DWORD le = GetLastError();
            mti_PrintFormatted("*** Error opening socket. Error=%d ***\n", le );
        #else
            mti_PrintMessage("*** Error opening socket ***\n" );
        #endif
        return SOCKET_ERROR;
    }

    // get host machine info
    if ((hp = gethostbyname(hostname)) == 0) {
        mti_PrintFormatted( "%s: Unknown host.\n", hostname );
        #ifdef WIN32
            closesocket(sd);
        #else
            close(sd);
        #endif
        return SOCKET_ERROR;
    }

    // fill in the socket structure with host information 
    memset(&pin, 0, sizeof(pin));                   // Clear Structure
    pin.sin_family = AF_INET;                       // Specify Address format
    pin.sin_addr.s_addr = ((struct in_addr *)(hp->h_addr))->s_addr;
    pin.sin_port = htons((unsigned short)port);                     // set port number

    // connect to PORT on HOSTNAME
    if (connect(sd,(struct sockaddr *)  &pin, sizeof(pin)) == -1) {
        mti_PrintFormatted( "Error connecting to server %s:%d\n",hostname, port );
        #ifdef WIN32
            closesocket(sd);
        #else
            close(sd);
        #endif
        return SOCKET_ERROR;
    }

    // Change socket status to blocking!!   
    #ifdef WIN32
    {
        unsigned long non_blocking = 0;             // Change to 0 for non-blocking
        status = ioctlsocket( sd, FIONBIO, &non_blocking );
        if ( status == SOCKET_ERROR ) {
           mti_PrintMessage("*** Error: Setting socket status ***\n");
           return SOCKET_ERROR;
        }
    }
    #else
        statusFlags = fcntl( sd, F_GETFL );         // get socket status
        if ( statusFlags == -1 ) {
            mti_PrintMessage(" *** Error: Getting socket status\n ***");
            return SOCKET_ERROR;
        } else {
            int ctlValue;
            statusFlags |= O_SYNC;                  // Change to O_NONBLOCK for non-blocking
            ctlValue = fcntl( sd, F_SETFL, statusFlags );
            if ( ctlValue == -1 ) {
                mti_PrintMessage("*** Error: Setting socket status ***\n");
                return SOCKET_ERROR;
            }
        }
    #endif

    return (sd);                                    // Return Socket Descriptor
}


// Convert std_logic_vector into an integer
mtiUInt32T conv_std_logic_vector(mtiSignalIdT stdvec)
{
    mtiSignalIdT *  elem_list;
    mtiTypeIdT      sigtype;
    mtiInt32T       i,num_elems;
    mtiUInt32T      retvalue,shift; 

    sigtype = mti_GetSignalType(stdvec);            // signal type
    num_elems = mti_TickLength(sigtype);            // Get number of elements
    if (debug) mti_PrintFormatted("\nSignal X has %d elements\n",num_elems);

    elem_list = mti_GetSignalSubelements(stdvec, 0);

    shift=(mtiUInt32T) pow(2.0,(double)num_elems-1);// start position
    
    retvalue=0;
    for (i=0; i < num_elems; i++ ) {
        if (mti_GetSignalValue(elem_list[i])==3) {
            retvalue=retvalue+shift;
        } 
        shift=shift>>1;
    }

    mti_VsimFree(elem_list);

    return(retvalue);
}

