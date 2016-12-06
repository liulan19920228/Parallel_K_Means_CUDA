#include <stdio.h>
#include <stdlib.h>
#include "kmeans.h"


__global__ static
void find_nearest_cluster(int dimension,
                          int numObjs,
                          int numClusters,
                          float *data,
                          float *DEVICEcenter,
                          int *newmembership)
{
    
    int datatId = blockDim.x * blockIdx.x + threadIdx.x;
    
    if (objectId < numObjs) {
        int   i;
        float distance, min_dist = 0.0;
        
        for(i=0; i<dimension; i++)
        {
            min_dist +=(data[numObjs * i + dataId] - DEVICEcenter[numClusters * i]) *
            (data[numObjs * i + dataId] - DEVICEcenter[numClusters * i]);
        }
            
        for (j=1; j<numClusters; j++) {
            distance = 0.0;
            for(i=0; i<dimension; i++)
            {
                distance +=(data[numObjs * i + dataId] - DEVICEcenter[numClusters * i + j]) *
                (data[numObjs * i + dataId] - DEVICEcenter[numClusters * i + j]);
            }
            if (distance < min_dist) {
                min_dist = distance;
                newmembership[dataId] = i;
            }
        }
    
         __syncthreads();
    }
}

float** cuda_kmeans(float **data, int dimension, int numObjs, int numClusters, float threshold                 , int *membership, int *num_iterations)
{
    int      i, j, num_iterations=0;
    int     *clustersize;
    float    delta, **center, **clustersum;
    float  **datatranspose;
    float  **centertranspose;
    float *DEVICEdata;
    float *DEVICEcenter;
    int *DEVICEmembership;
    int *newmembership

    center    = (float**) malloc(numClusters *sizeof(float*));
    malloc2D(datatranspose, dimension, numObjs, float);
    for (i = 0; i < dimension; i++) {
        for (j = 0; j < numObjs; j++) {
            datatranspose[i][j] = data[j][i];
        }
    }
    
    malloc2D(centertranspose, dimension, numClusters, float);
    for (i = 0; i < dimension; i++) {
        for (j = 0; j < numClusters; j++) {
            centertranspose[i][j] = datatranspose[i][j];
        }
    }
    
    clustersize = (int*) calloc(numClusters, sizeof(int));
    calloc2D(clustersum, numClusters, dimension);
    newmembership = (int*) calloc(numObjs, sizeof(int));
    
    const unsigned int numThreadsPerClusterBlock = 128;
    const unsigned int numClusterBlocks =(numObjs + numThreadsPerClusterBlock - 1) /numThreadsPerClusterBlock;

    cudaMalloc(&DEVICEdata, numObjs*dimension*sizeof(float));
    cudaMalloc(&DEVICEcenter, numClusters*dimension*sizeof(float));
    cudaMalloc(&DEVICEmembership, numObjs*sizeof(int));
    cudaMemcpy(DEVICEdata, datatranspose[0],
                         numObjs*dimension*sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(DEVICEmembership, membership,
                         numObjs*sizeof(int), cudaMemcpyHostToDevice);
    
    do {
        cudaMemcpy(DEVICEcenter, centertranspose[0],
                             numClusters*dimension*sizeof(float), cudaMemcpyHostToDevice);
        
        find_nearest_cluster
        <<< numClusterBlocks, numThreadsPerClusterBlock>>>
        (dimension, numObjs, numClusters,
         DEVICEdata, DEVICEcenter, DEVICEmembership);
        
        cudaDeviceSynchronize();
        checkLastCudaError();
        
        delta=0.0;
        
        cudaMemcpy(newmembership, DEVICEmembership,
                   numObjs*sizeof(int), cudaMemcpyDeviceToHost)
        
        for(i=0; i<numObjs; i++)
        {
            if(numiteration == 0){
                delta =float(numObjs);
                membership[i]=newmembership[i];
                clustersize[membership[i]]++;
                clustersum[membership[i]] += data[i];
            }
            
            else if(membership[i] != newmembership[i]){
                delta += 1.0;
                clustersize[newmembership[i]] ++;
                clustersize[membership[i]] --;
                for(j=0; j<dimension; j++){
                    clustersum[newmembership][j] -= data[i][j];
                    clustersum[membership[i]][j] -= data[i][j];
                }
                membership[i] = newmembership[i];
            }
        }
        
        
        /* average the sum to compute new cluster centers*/
        for (i=0; i<numClusters; i++) {
            for (j=0; j<dimension; j++) {
                if (clustersize[i] > 0)
                    centertranspose[j][i] = clustersum[i][j] / clustersize[i];
            }
        }        
        delta /= numObjs;
    } while (delta > threshold && numiterations++ < 500);//Max number of iteration
    
    *num_iterations = numiterations + 1;
    
    for (i = 0; i < numClusters; i++) {
        for (j = 0; j < dimension; j++) {
            clusters[i][j] = clustertranspose[j][i];
        }
    }
    
    cudaFree(DEVICEdata);
    cudaFree(DEVICEcenter);
    cudaFree(DEVICEmembership);
    
    free(datatranspose[0]);
    free(datatranspose);
    free(centertranspose[0]);
    free(centertranspose);
    free(clustersum[0]);
    free(clustersum);
    free(clustersize);
    free(newmembership)
    return center;
}
