
all:
nvcc -g -pg  -I. --ptxas-options=-v -o timer.o -c timer.cu
nvcc -g -pg  -I. --ptxas-options=-v -o cuda_kmeans.o -c cuda_kmeans.cu
nvcc -g -pg  -I. --ptxas-options=-v -o main.o -c main.cu
nvcc -g -pg -o main main.o timer.o cuda_kmeans.o
