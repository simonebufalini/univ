/*
 * K-Means clustering algorithm - MPI + OpenMP Version
 *
 * Programmazione di sistemi embedded e multicore
 *
 * Compilation: mpicc -fopenmp KMEANS_mpi_omp.c -o KMEANS_mpi_omp -lm
 */
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <math.h>
#include <time.h>
#include <string.h>
#include <float.h>
#include <mpi.h>
#include <omp.h>

#define MAXLINE 2000
#define MAXCAD 200

//Macros
#define MIN(a,b) ((a) < (b) ? (a) : (b))
#define MAX(a,b) ((a) > (b) ? (a) : (b))

void showFileError(int error, char* filename) {
    printf("Error\n");
    switch (error) {
        case -1: fprintf(stderr,"\tFile %s has too many columns.\n", filename); break;
        case -2: fprintf(stderr,"Error reading file: %s.\n", filename); break;
        case -3: fprintf(stderr,"Error writing file: %s.\n", filename); break;
    }
    fflush(stderr);
}

int readInput(char* filename, int *lines, int *samples) {
    FILE *fp;
    char line[MAXLINE] = "";
    char *ptr;
    const char *delim = "\t";
    int contlines = 0, contsamples = 0;

    if ((fp=fopen(filename,"r"))!=NULL) {
        while(fgets(line, MAXLINE, fp)!= NULL) {
            if (strchr(line, '\n') == NULL) return -1;
            contlines++;
            ptr = strtok(line, delim);
            contsamples = 0;
            while(ptr != NULL) {
                contsamples++;
                ptr = strtok(NULL, delim);
            }
        }
        fclose(fp);
        *lines = contlines;
        *samples = contsamples;
        return 0;
    } else return -2;
}

int readInput2(char* filename, float* data) {
    FILE *fp;
    char line[MAXLINE] = "";
    char *ptr;
    const char *delim = "\t";
    int i = 0;

    if ((fp=fopen(filename,"rt"))!=NULL) {
        while(fgets(line, MAXLINE, fp)!= NULL) {
            ptr = strtok(line, delim);
            while(ptr != NULL) {
                data[i] = atof(ptr);
                i++;
                ptr = strtok(NULL, delim);
            }
        }
        fclose(fp);
        return 0;
    } else return -2;
}

int writeResult(int *classMap, int lines, const char* filename) {
    FILE *fp;
    if ((fp=fopen(filename,"wt"))!=NULL) {
        for(int i=0; i<lines; i++) fprintf(fp,"%d\n",classMap[i]);
        fclose(fp);
        return 0;
    } else return -3;
}

void initCentroids(const float *data, float* centroids, int* centroidPos, int samples, int K) {
    int i, idx;
    for(i=0; i<K; i++) {
        idx = centroidPos[i];
        memcpy(&centroids[i*samples], &data[idx*samples], (samples*sizeof(float)));
    }
}

float euclideanDistance(float *point, float *center, int samples) {
    float dist=0.0;
    for(int i=0; i<samples; i++) {
        dist+= (point[i]-center[i])*(point[i]-center[i]);
    }
    return sqrt(dist);
}

void zeroFloatMatriz(float *matrix, int rows, int columns) {
    int i,j;
    for (i=0; i<rows; i++)
        for (j=0; j<columns; j++)
            matrix[i*columns+j] = 0.0;
}

void zeroIntArray(int *array, int size) {
    int i;
    for (i=0; i<size; i++)
        array[i] = 0;
}

int main(int argc, char* argv[]) {

    // MPI Initialization
    int rank, nprocs;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &nprocs);

    clock_t start, end;
    if (rank == 0) start = clock();

    if(argc != 7) {
        if (rank == 0) fprintf(stderr,"EXECUTION ERROR K-MEANS: Parameters are not correct.\n");
        MPI_Finalize();
        exit(-1);
    }

    int lines = 0, samples = 0;
    float *data = NULL;
    int error;

    // Rank 0 reads the file
    if (rank == 0) {
        error = readInput(argv[1], &lines, &samples);
        if(error != 0) { showFileError(error,argv[1]); MPI_Abort(MPI_COMM_WORLD, error); }

        data = (float*)calloc(lines*samples,sizeof(float));
        if (data == NULL) { fprintf(stderr,"Memory allocation error.\n"); MPI_Abort(MPI_COMM_WORLD, -4); }
        
        error = readInput2(argv[1], data);
        if(error != 0) { showFileError(error,argv[1]); MPI_Abort(MPI_COMM_WORLD, error); }
    }

    // Broadcast global dimensions to all ranks
    MPI_Bcast(&lines, 1, MPI_INT, 0, MPI_COMM_WORLD);
    MPI_Bcast(&samples, 1, MPI_INT, 0, MPI_COMM_WORLD);

    int K=atoi(argv[2]);
    int maxIterations=atoi(argv[3]);
    int minChanges= (int)(lines*atof(argv[4])/100.0);
    float maxThreshold=atof(argv[5]);

    /* DATA DISTRIBUTION STRATEGY (Scatterv) */
    int *sendcounts = malloc(nprocs * sizeof(int));
    int *displs = malloc(nprocs * sizeof(int));
    int rem = lines % nprocs;
    int sum = 0;
    
    // Calculate how many points each rank gets
    for (int i = 0; i < nprocs; i++) {
        sendcounts[i] = (lines / nprocs) + (i < rem ? 1 : 0);
        displs[i] = sum;
        sum += sendcounts[i];
    }
    
    int local_lines = sendcounts[rank];
    float *local_data = (float*)malloc(local_lines * samples * sizeof(float));
    int *local_classMap = (int*)calloc(local_lines, sizeof(int));

    // Convert counts/displs to element-wise for float array scatter
    int *sendcounts_f = malloc(nprocs * sizeof(int));
    int *displs_f = malloc(nprocs * sizeof(int));
    for(int i=0; i<nprocs; i++) {
        sendcounts_f[i] = sendcounts[i] * samples;
        displs_f[i] = displs[i] * samples;
    }

    // Scatter the data points
    MPI_Scatterv(data, sendcounts_f, displs_f, MPI_FLOAT, 
                 local_data, local_lines * samples, MPI_FLOAT, 
                 0, MPI_COMM_WORLD);

    // Centroids are small enough to be replicated on all ranks
    float *centroids = (float*)calloc(K*samples,sizeof(float));
    int *centroidPos = (int*)calloc(K,sizeof(int));
    
    if (rank == 0) {
        srand(0);
        for(int i=0; i<K; i++) centroidPos[i]=rand()%lines;
        initCentroids(data, centroids, centroidPos, samples, K);
        printf("\n\tData file: %s \n\tPoints: %d\n\tDimensions: %d\n", argv[1], lines, samples);
        printf("\tNumber of clusters: %d\n", K);
        printf("\tMPI Ranks: %d\n", nprocs);
    }

    // Broadcast initial centroids
    MPI_Bcast(centroids, K*samples, MPI_FLOAT, 0, MPI_COMM_WORLD);

    int *classMap = NULL;
    if(rank == 0) classMap = (int*)calloc(lines, sizeof(int));

    if (rank == 0) {
        end = clock();
        printf("\nMemory allocation & Dist: %f seconds\n", (double)(end - start) / CLOCKS_PER_SEC);
        start = clock();
    }

    int j, class;
    float dist, minDist;
    int it=0;
    int global_changes = 0;
    float maxDist;

    // Local accumulators
    int *local_pointsPerClass = (int *)malloc(K*sizeof(int));
    float *local_auxCentroids = (float*)malloc(K*samples*sizeof(float));
    
    // Global accumulators
    int *global_pointsPerClass = (int *)malloc(K*sizeof(int));
    float *global_auxCentroids = (float*)malloc(K*samples*sizeof(float));
    float *distCentroids = (float*)malloc(K*sizeof(float));

    char *outputMsg = (char *)calloc(10000,sizeof(char));
    char lineBuf[100];

    do {
        it++;
        int local_changes = 0;

        // 1. ASSIGNMENT STEP (Parallelized with OpenMP)
        // Each rank processes its local slice of data
        #pragma omp parallel for private(j, dist, minDist, class) reduction(+:local_changes)
        for(int i=0; i<local_lines; i++) {
            class=1;
            minDist=FLT_MAX;
            for(j=0; j<K; j++) {
                dist = euclideanDistance(&local_data[i*samples], &centroids[j*samples], samples);
                if(dist < minDist) {
                    minDist=dist;
                    class=j+1;
                }
            }
            if(local_classMap[i] != class) {
                local_changes++;
            }
            local_classMap[i] = class;
        }

        // Aggregate total changes from all ranks
        MPI_Allreduce(&local_changes, &global_changes, 1, MPI_INT, MPI_SUM, MPI_COMM_WORLD);

        // 2. UPDATE STEP
        zeroIntArray(local_pointsPerClass, K);
        zeroFloatMatriz(local_auxCentroids, K, samples);

        // Calculate local partial sums (Parallelized with OpenMP)
        // Using atomic to safely update the shared accumulation arrays
        #pragma omp parallel for private(j, class)
        for(int i=0; i<local_lines; i++) {
            class = local_classMap[i];
            
            #pragma omp atomic
            local_pointsPerClass[class-1]++;
            
            for(j=0; j<samples; j++){
                #pragma omp atomic
                local_auxCentroids[(class-1)*samples+j] += local_data[i*samples+j];
            }
        }

        // Reduce partial sums to get global sums
        MPI_Allreduce(local_pointsPerClass, global_pointsPerClass, K, MPI_INT, MPI_SUM, MPI_COMM_WORLD);
        MPI_Allreduce(local_auxCentroids, global_auxCentroids, K*samples, MPI_FLOAT, MPI_SUM, MPI_COMM_WORLD);

        // Calculate new centroids (Replicated calculation on all ranks)
        // This is fast enough to not need extreme parallelism
        maxDist=FLT_MIN;
        for(int i=0; i<K; i++) {
            // Avoid division by zero if a cluster is empty (though rare in K-means)
            if(global_pointsPerClass[i] > 0) {
                for(j=0; j<samples; j++){
                    global_auxCentroids[i*samples+j] /= global_pointsPerClass[i];
                }
            }
            
            float d = euclideanDistance(&centroids[i*samples], &global_auxCentroids[i*samples], samples);
            if(d > maxDist) maxDist = d;
        }

        // Update centroids for next iteration
        memcpy(centroids, global_auxCentroids, (K*samples*sizeof(float)));

        if (rank == 0) {
            sprintf(lineBuf,"\n[%d] Cluster changes: %d\tMax. centroid distance: %f", it, global_changes, maxDist);
            strcat(outputMsg, lineBuf);
        }

        // Need to broadcast maxDist? No, because all ranks have identical centroids/global_aux, 
        // so they computed identical maxDist. However, global_changes was reduced properly.
        // The condition check needs to be consistent.

    } while((global_changes > minChanges) && (it < maxIterations) && (maxDist > maxThreshold));


    if (rank == 0) {
        printf("%s", outputMsg);
        end = clock();
        printf("\nComputation: %f seconds", (double)(end - start) / CLOCKS_PER_SEC);
        start = clock();
        
        if (global_changes <= minChanges) printf("\n\nTermination: Min changes reached.");
        else if (it >= maxIterations) printf("\n\nTermination: Max iterations reached.");
        else printf("\n\nTermination: Precision reached.");
    }

    // Gather results back to Rank 0 for file writing
    // Gatherv is needed because counts vary
    MPI_Gatherv(local_classMap, local_lines, MPI_INT, 
                classMap, sendcounts, displs, MPI_INT, 
                0, MPI_COMM_WORLD);

    if (rank == 0) {
        error = writeResult(classMap, lines, argv[6]);
        if(error != 0) showFileError(error, argv[6]);
        
        free(data);
        free(classMap);
        free(centroidPos);
        free(outputMsg);
        end = clock();
        printf("\n\nMemory deallocation: %f seconds\n", (double)(end - start) / CLOCKS_PER_SEC);
    }

    free(local_data);
    free(local_classMap);
    free(centroids);
    free(local_pointsPerClass);
    free(local_auxCentroids);
    free(global_pointsPerClass);
    free(global_auxCentroids);
    free(distCentroids);
    free(sendcounts);
    free(displs);
    free(sendcounts_f);
    free(displs_f);

    MPI_Finalize();
    return 0;
}
