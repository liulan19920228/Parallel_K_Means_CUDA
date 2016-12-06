#include <stdio.h>
#include <stdlib.h>
#include "kmeans.h"

__inline static
int find_nearest_cluster(int numClusters,int dimension, float *data, float **center)
{
    int   index = 0, i;
    float min_dist=0.0, distance;
    for(i=0; i<dimension; i++){
        min_dist += (data[i]-center[0][i])*(data[i]-center[0][i]);
    }
    for (j=1; j<numClusters; j++)
    {
       distance = 0.0;
       for(i=0; i<dimension; i++)
       {
        distance += (data[i]-center[j][i])*(data[i]-center[j][i]);
       }
        if (distance < min_dist) {
            min_dist = distance;
            index    = j;
        }
    }
    return(index);
}

float** seq_kmeans(float **data, int dimension, int numObjs, int numClusters, float threshold, int  *membership, int  *num_iterations)
{
    int      i, j, index, numiterations=0;
    int     *clustersize;
    float    delta,**center,**clustersum;
    
    malloc2D(center, numClusters, dimensions);
    
    /* pick first numClusters elements of objects[] as initial cluster centers*/
    for (i=0; i<numClusters; i++)
        for (j=0; j<dimension; j++)
            center[i][j] = data[i][j];

    clustersize = (int*) calloc(numClusters, sizeof(int));
    calloc2D(clustersum, numClusters, dimension);
    
    do {
        delta = 0.0;
        for (i=0; i<numObjs; i++) {
            index = find_nearest_cluster(numClusters, dimension, data[i], center);
            if(numiteration == 0){
                delta = float(numObjs);
                membership[i] = index;
                clustersize[index]++;
                clustersum[index]+ = data[i];
            }
                
            else if(membership[i] != index){
                delta +=1.0;
                clustersize[index] ++;
                clustersize[membership[i]] --;
                for(j=0; j<dimension; j++){
                    clustersum[index][j] += data[i][j];
                    clustersum[membership[i]][j] -= data[i][j];
                }
                membership[i] = index;
            }
        }

        /* average the sum to compute new cluster centers*/
        for (i=0; i<numClusters; i++) {
            for (j=0; j<dimension; j++) {
                if (clustersize[i] > 0)
                    center[i][j] = clustersum[i][j] / clustersize[i];
            }
        }
        delta /= numObjs;
    } while (delta > threshold && numiterations++ < 500); /* Max number of iteration is 500 */
    
    *num_iterations = numiterations + 1;
    free(clustersum[0]);
    free(clustersum);
    free(clustersize);
    
    return center;
}