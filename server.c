#define _GNU_SOURCE

#include <sys/time.h>
#include <stdio.h>
#include <stdlib.h>
#include "../ssocket/ssocket.h"

#include <sched.h>
#include <unistd.h>

//Definiciones
#define BUF_SIZE 10
#define FIRST_PORT 1820

//Variables
int first_pack = 0;
struct timeval dateInicio, dateFin;
pthread_mutex_t lock;
int mostrarInfo = 0;
int distribuiteCPUs = 1;
int MAX_PACKS = 1;
int NTHREADS = 1;
int DESTINATION_PORT = FIRST_PORT;
double segundos;

llamadaHilo(int socket_fd){
	char buf[BUF_SIZE];
	int lectura;

	int actualCPU = sched_getcpu();
	if(mostrarInfo) printf("Socket Operativo: %d, \t CPU: %d\n", socket_fd, actualCPU);

	int i;
	int paquetesParaAtender = MAX_PACKS/NTHREADS;

	for(i = 0; i < paquetesParaAtender; i++) {
		//lectura = recv(socket_fd, buf, BUF_SIZE, 0);
		lectura = read(socket_fd, buf, BUF_SIZE);
		if(lectura <= 0) {
			fprintf(stderr, "Error en el read del socket (%d)\n", lectura);
			exit(1);
		}
		if(first_pack==0) { 
			pthread_mutex_lock(&lock);
			if(first_pack == 0) {
				if(mostrarInfo)	printf("got first pack\n");
				first_pack = 1;
				//Medir Inicio
				gettimeofday(&dateInicio, NULL);
			}
			pthread_mutex_unlock(&lock);
		}
	}

	actualCPU = sched_getcpu();
	if(mostrarInfo) printf("Fin Socket Operativo: %d, \t CPU: %d\n", socket_fd, actualCPU);
}

int main(int argc, char **argv){
	//Verificar Parametros Entrada
	if(argc <4){
		fprintf(stderr,"Syntax Error: Esperado: ./server MAX_PACKS NTHREADS DESTINATION_PORT\n");
		exit(1);
	}

	//Recuperar PID
	int pid = getpid();	
	if(mostrarInfo)	printf("El pid es %d\n", pid);

	//Recuperar total de paquetes a enviar
	MAX_PACKS = atoi(argv[1]);

	//Recuperar numero de Threads
	NTHREADS = atoi(argv[2]);
	pthread_t pids[NTHREADS];

	//Recuperar puerto destino
	DESTINATION_PORT = atoi(argv[3]);

	//Info
	int totalCPUs = sysconf(_SC_NPROCESSORS_ONLN);
	if(mostrarInfo) printf("Total de Procesadores disponibles: %d\n", totalCPUs);	

	//Crear Socket
	int socket_fd;
	char ports[10];
	sprintf(ports, "%d", DESTINATION_PORT);
	socket_fd = udp_bind(ports);
	if(socket_fd < 0) {
		fprintf(stderr, "Error de bind al tomar el puerto\n");
		exit(1);
	}

	pthread_mutex_init(&lock, NULL);
	if(mostrarInfo)	printf("Usando %d threads, %d packs\n", NTHREADS, MAX_PACKS);

	//Configurar Threads
    pthread_attr_t attr;
    cpu_set_t cpus;
    pthread_attr_init(&attr);	

	//Lanzar Threads
	int i;
	for(i=0; i < NTHREADS; i++) {
		CPU_ZERO(&cpus);
		CPU_SET(i%totalCPUs, &cpus);
		pthread_attr_setaffinity_np(&attr, sizeof(cpu_set_t), &cpus);
		
		if(distribuiteCPUs){
			pthread_create(&pids[i], &attr, llamadaHilo, socket_fd);
		}else{
			pthread_create(&pids[i], NULL, llamadaHilo, socket_fd);
		}		
	}

	//Esperar Threads
	for(i=0; i < NTHREADS; i++) 
		pthread_join(pids[i], NULL);

	//Medir Fin
	gettimeofday(&dateFin, NULL);

	//Cerrar Socket
	close(socket_fd);

	segundos=(dateFin.tv_sec*1.0+dateFin.tv_usec/1000000.)-(dateInicio.tv_sec*1.0+dateInicio.tv_usec/1000000.);
	if(mostrarInfo){
		printf("Tiempo Total = %g\n", segundos);
		printf("QPS = %g\n", MAX_PACKS*1.0/segundos);
	}else{
		printf("%g, \n", segundos);
	}
	exit(0);
}