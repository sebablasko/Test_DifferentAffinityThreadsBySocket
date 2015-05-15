all: server client
prof: serverProfiling client

server: server.o ../ssocket/ssocket.o
	gcc server.o ../ssocket/ssocket.o -o server -lpthread

serverProfiling: server.o ../ssocket/ssocket.o
	gcc -g -o3 server.o ../ssocket/ssocket.o -o server -lpthread

rm_server:
	rm server server.o

client: client.o ../ssocket/ssocket.o
	gcc client.o ../ssocket/ssocket.o -o client -lpthread

rm_client:
	rm client client.o

clean: rm_client rm_server