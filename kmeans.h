#define malloc2D(name, xDim, yDim) do {               \
name = (float **)malloc(xDim * sizeof(float *));          \
name[0] = (float *)malloc(xDim * yDim * sizeof(float));   \
for (int i = 1; i < xDim; i++)                       \
name[i] = name[i-1] + yDim;                         \
} while (0)

#define calloc2D(name, xDim, yDim) do {               \
name = (float **)malloc(xDim * sizeof(float *));          \
name[0] = (float *)calloc(xDim * yDim * sizeof(float));   \
for (int i = 1; i < xDim; i++)                       \
name[i] = name[i-1] + yDim;                         \
} while (0)

inline void checkLastCudaError() {
    checkCuda(cudaGetLastError());
}

float** cuda_kmeans(float **data, int dimension, int numObjs, int numClusters, float threshold                 , int *membership, int *num_iterations)

double  wtime(void);