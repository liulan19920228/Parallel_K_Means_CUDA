#define malloc2D(name, xDim, yDim) do {               \
name = (float **)malloc(xDim * sizeof(float *));          \
name[0] = (float *)malloc(xDim * yDim * sizeof(float));   \
for (int i = 1; i < xDim; i++)                       \
name[i] = name[i-1] + yDim;                         \
} while (0)


float** cuda_kmeans(float**, int, int, int, float, int*, int*);
float** seq_kmeans(float**, int, int, int, float, int*, int*);

double  wtime(void);
