//==============================================================================
// FLI Socket Fern Server
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
//------------------------------------------------------------------------------
// Version   Author          Date          Changes
// 0.1       Hans Tiggeler   17 Feb 2003   Tested on Modelsim SE 5.7b
// 0.2       Hans Tiggeler   15 May 2014   Updated to SDL 2.0
// 	g++  -ID:/Emulation/SDL2-2.0.0_not_used/include ferndisp.cpp -o ferndisp 
//       D:/Emulation/SDL2-2.0.0_not_used/VisualC/SDLmain/Win32/Release/SDL2main.lib 
//       D:/Emulation/SDL2-2.0.0_not_used/VisualC/SDL/Win32/Release/SDL2.lib -lwsock32  -Wall 
//==============================================================================

#include <SDL.h>
#include <winsock2.h>
#include <stdio.h>
#include <math.h>

// Change for host computer
#define PORT_NUMBER 2000
#define HOST_NAME 	"localhost"


#define MAX_QUEUE 	32
#define MAX_BUFFER 	2048


//Screen dimension constants
const int SCREEN_WIDTH = 512;
const int SCREEN_HEIGHT = 512;

//The window we'll be rendering to
SDL_Window* gWindow = NULL;
//The window renderer
SDL_Renderer* gRenderer = NULL;

bool init_sdl();
void close_sdl();
double iFIX(unsigned long x);
double power(int p);
unsigned long inv16(unsigned long x);

// Do not change, hardcoded into fern hardware
#define  INT_BITS 	4      						// Integer part
#define  FRAC_BITS 	11     						// Fraction
#define  BITS 		16     						// FRAC_BITS+INT_BITS+1; 

int main(int argc, char *argv[])
{

	
	SDL_Event event;
	unsigned int x, y;
	unsigned int lx,ly; 
	unsigned int a,b;
	
	struct sockaddr_in addr;
	struct hostent *host;
	int descriptor;
	int result;
	int sockets;
	char buffer[MAX_BUFFER];
	bool quit=false;
	int n=0;
	
	
	//---------------------------------------------------------------------------------------------
	// Initialise sockets first
	//---------------------------------------------------------------------------------------------
	
	printf("Initialise socket \"localhost\" port=2000\n");
	
	// Initialise Winsock library
	// Minimum winsock librar version 2
	WSADATA wsaData;		
	if (WSAStartup(MAKEWORD(2, 2), &wsaData)!=0) {	
		perror("init winsock library");
		return 1;
	}
	// create a new socket and return handle 
	// Use TCP
	//descriptor = socket(PF_INET, SOCK_STREAM, 0); // Use AF_INET?
	descriptor = socket(AF_INET, SOCK_STREAM, 0); 
	if (descriptor == -1) {
		perror("socket");
		return 1;
	}
 
	// get information about the host  (localhost in our case)
	memset(&addr, 0, sizeof(addr));
	host = gethostbyname(HOST_NAME);
	if (host == NULL) {
		perror("gethostbyname");
		closesocket(descriptor);
		WSACleanup();
		return 1;
	}
 
	// bind the socket to an address and port 
	memcpy(&addr.sin_addr, host->h_addr_list[0], sizeof(host->h_addr_list[0]));
	addr.sin_family = AF_INET;
	addr.sin_port = htons(PORT_NUMBER); 		// Convert a u_short from host to TCP/IP network byte order
	result = bind(descriptor, (struct sockaddr *)&addr, sizeof(addr));
	if (result == -1) {
		perror("bind");
		closesocket(descriptor);
		WSACleanup();		
		return 1;
	}
 
	// listen for connections 
	result = listen(descriptor, MAX_QUEUE);
	if (result == -1) {
		perror("listen");
		closesocket(descriptor);
		WSACleanup();
		return 1;
	}
 
	sockets = accept(descriptor, NULL, NULL);
	if (sockets == -1) {
		perror("accept");
		closesocket(descriptor);
		WSACleanup();
		return 1;
	} 
	
	
	//---------------------------------------------------------------------------------------------
	// Initialize SDL Video
	//---------------------------------------------------------------------------------------------
	printf("Initialise SDL video\n");
	if (!init_sdl()) return -1;
		
	//Clear screen
	SDL_SetRenderDrawColor( gRenderer, 0x8F, 0x8F, 0x80, 0x8F );
	SDL_RenderClear( gRenderer );	
		
	SDL_SetRenderDrawColor(gRenderer, 0xFF, 0xFF, 0xFF, 0xFF);
	SDL_RenderClear(gRenderer);
		
	while (!quit) { 			// Poll for events
		while (SDL_PollEvent(&event)) {
			switch( event.type ){
				case SDL_KEYUP:
					if(event.key.keysym.sym == SDLK_ESCAPE) quit=true;
					break;
				case SDL_QUIT:
					quit=true;
					break;
				default:
					break;
			}
		}
			

		memset(buffer,0,sizeof(buffer));
		result = recv(sockets, buffer, sizeof(buffer), 0); // blocking?
		if (result == -1) {
			perror("recv");
			quit=true;
		} else {	
		
			SDL_SetRenderDrawColor( gRenderer, 0xFF, 0, 0, 0xFF );
			n=0;
			while (n<result) {							// Plot the Pixels				
	
				a=(unsigned int)buffer[n++];
				b=(unsigned int)buffer[n++];
				x=a | ((b<<8)&0xFF00);
				
				a=(unsigned int)buffer[n++];
				b=(unsigned int)buffer[n++];
				y=a | ((b<<8)&0xFF00);
							
				lx=(unsigned)(iFIX(x)*(float)(SCREEN_WIDTH/6)) + (SCREEN_WIDTH/2);
				ly=(unsigned)(iFIX(y)*(float)(SCREEN_WIDTH/10)); // 0..400

				// Bodge for rounding error
				if (lx<(SCREEN_WIDTH/2)-5 || lx>(SCREEN_WIDTH/2)) {
					SDL_RenderDrawPoint(gRenderer, lx,ly);
				}
			}			
			SDL_RenderPresent(gRenderer);				//Update screen			
		}

	}

	//---------------------------------------------------------------------------------------------
	// Close SDL
	//---------------------------------------------------------------------------------------------
	close_sdl();
	
	//---------------------------------------------------------------------------------------------
	// Close sockets
	//---------------------------------------------------------------------------------------------
	closesocket(sockets);
	closesocket(descriptor);	
	
	// Clean winsock library calls
	if (WSACleanup()!=0) {
		printf("winsock cleanup failed\n");
	}

	return 0;
}


//-------------------------------------------------------------------------------------------------
// Initialise SDL 2.0
// Return false if fails
//-------------------------------------------------------------------------------------------------
bool init_sdl()
{

	//Initialize SDL
	if (SDL_Init(SDL_INIT_VIDEO < 0)) {
		printf("SDL could not initialize! SDL Error: %s\n", SDL_GetError());
		return false;
	}

	// //Set texture filtering to linear
	// if (!SDL_SetHint( SDL_HINT_RENDER_SCALE_QUALITY, "1" )) {
		// printf("Warning: Linear texture filtering not enabled!");
	// }

	//Create window
	gWindow = SDL_CreateWindow( "Fern Server", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_SHOWN );
	if (gWindow == NULL) {
		printf("Window could not be created! SDL Error: %s\n", SDL_GetError());
		return false;
	}

	//Create renderer for window
	gRenderer = SDL_CreateRenderer( gWindow, -1, SDL_RENDERER_ACCELERATED);
	if (gRenderer == NULL) {
		printf("Renderer could not be created! SDL Error: %s\n", SDL_GetError());
		return false;
	}

	return true;
}

void close_sdl()
{
	//Destroy window	
	SDL_DestroyRenderer( gRenderer );
	SDL_DestroyWindow( gWindow );
	gWindow = NULL;
	gRenderer = NULL;

	//Quit SDL subsystems
	SDL_Quit();
}


// Convert from FIX
double iFIX(unsigned long x)
{
  int n;
  int neg=0;
  double res=0.0;
  double div;
  unsigned long shift;

  shift=0x80000000>>(32-BITS);
  x=x&(0xFFFFFFFF>>(32-BITS));
  
  div=pow(2.0,(double)INT_BITS-1);

  if ((x & shift)==shift)  {    // negative?
    x=inv16(x)+1;
    neg=1;                      // flag negative
  }

  shift=0x40000000>>(32-BITS);
  for (n=1;n<BITS;n++) {
    if ((x & shift)==shift) {
       res=res+div;
    }
    shift=shift>>1;
    div=div/2.0;
  }
  if (neg) return(res*(-1)); else return(res);
}


double power(int p)
{
  long n=1L;
  int b;

  for (b=0; b<p;b++) n=n*2;
  return (pow(2.0,(double)INT_BITS)/(double)n);
}

unsigned long inv16(unsigned long x)
{
 int n;
 unsigned long shift;

 shift=0x80000000>>(32-BITS);

 for (n=0;n<BITS;n++) {
   if ((x & shift)==shift) {
      x=x-shift;
   } else x=x+shift;
     shift=shift>>1;
   }
 return(x);
}
