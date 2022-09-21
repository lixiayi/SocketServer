//
//  SockService.m
//  Sock
//
//  Created by stoicer on 2022/9/21.
//

#import "SockService.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <sys/_select.h>
#import <sys/select.h>

static int serverfd;
static fd_set allfd;
static fd_set changefds;
static int maxfd = -1;

@implementation SockService

- (int)buildServer
{
    //open
    serverfd = socket(AF_INET, SOCK_STREAM, 0);
    if (serverfd == -1) {
        NSLog(@"[server]socket create failed!");
        return 0 ;
    }
    
    NSLog(@"[server]socket create sucess!");
    
    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = inet_addr("127.0.0.1");
    addr.sin_port = htons(8888) ;
    
    //bind
    int isreused = 0;
    setsockopt(serverfd, SOL_SOCKET, SO_REUSEADDR, &isreused, sizeof(int));
    int r = bind(serverfd, (struct sockaddr *)&addr, sizeof(addr));
    if (r == -1) {
        NSLog(@"[server]bind failed!");
        return 0;
    }
    
    NSLog(@"[server]bind success!");
    
    //listen
    r = listen(serverfd, 10);
    if (r == -1) {
        NSLog(@"[server]listen failed!");
        return 0;
    }
    
    NSLog(@"[server]listen success!");
    
    while (1) {
        FD_ZERO(&changefds);
        FD_SET(serverfd,&changefds);
        maxfd = maxfd<serverfd ? serverfd : maxfd;
        for (int i=0; i<maxfd; i++) {
            if (FD_ISSET(i, &allfd)) {
                FD_SET(i,&changefds);
                maxfd = maxfd < i?i:maxfd;
            }
        }
        
        //select
        r = select(maxfd+1, &changefds, 0, 0, 0);
        if (FD_ISSET(serverfd, &changefds)) {
            NSLog(@"[server]have client connect");
            
            //accept
            int fd=accept(serverfd, 0, 0 );
            if (fd == -1) {
                NSLog(@"[server]connect failed!");
                break;
            }
            
            maxfd = maxfd<fd?fd:maxfd;
            FD_SET(fd,&allfd);
        }
        
        char buf[256];
        for (int i=0; i<=maxfd; i++) {
            if (FD_ISSET(i, &changefds) && FD_ISSET(i, &allfd)) {
                r = (int )recv(i, buf, 255, 0);
                if (r <= 0) {
                    NSLog(@"[server]clinet quit!");
                    FD_CLR(i, &allfd);
                }
                buf[r] = 0;
                
                NSLog(@"[server]from client data:%d, %s\n",r,buf);
                NSData *data = [[NSData alloc] initWithBytes:buf length:sizeof(buf)];
                NSString *str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                NSLog(@"[server]recvData:%@",str);
                if (self.receBock) {
                    self.receBock(str);
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"showStrNotify" object:str];
  
            }
            
            for (int j=0; j<maxfd; j++) {
                if (FD_ISSET(j, &allfd)) {
                    r = (int)send(j, buf, strlen(buf), 0);
                    NSLog(@"[server]send data:%d\n",r);
                }
            }
        }
        
        
    }
    
    //close
    close(serverfd);
    return 0;
}

@end
