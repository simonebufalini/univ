/*
 * k-Means clustering algorithm - CUDA Version
 *
 * Programmazione di sistemi embedded e multicore
 *
 * Compilation: nvcc -O3 KMEANS_cuda.cu -o KMEANS_cuda
 */
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <string.h>
#include <float.h>
#include <cuda_runtime.h>

#define MAXLINE 2000
#define BLOCK_SIZE 256

/* CUDA Error Check Macro */
#define cudaCheckError(ans) { gpuAssert((ans), __FILE__, __LINE__); }
inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort=true) {
   if (code != cudaSuccess) {
      fprintf(stderr,"GPUassert: %s %s %d\n", cudaGetErrorString(code), file, line);
      if (abort) exit(code);
   }
}

// Host functions (Keep reference implementation logic for IO)
void showFileError(int error, char* filename) { /* Same as reference */
    printf("Error\n");
    if(error == -1) fprintf(stderr,"\tFile %s has too many columns.\n", filename);
    else if(error == -2) fprintf(stderr,"Error reading file: %s.\n", filename);
    else if(error == -3) fprintf(stderr,"Error writing file: %s.\n", filename);
}

int readInput(char* filename, int *lines, int *samples) { /* Same as reference */
    FILE *fp; char line[MAXLINE]=""; char *ptr; int contlines=0, contsamples=0;
    if ((fp=fopen(filename,"r"))!=NULL) {
        while(fgets(line, MAXLINE, fp)!= NULL) {
            if (strchr(line, '\n') == NULL) return -1;
            contlines++; ptr = strtok(line, "\t"); contsamples = 0;
            while(ptr != NULL) { contsamples++; ptr = strtok(NULL, "\t"); }
        }
        fclose(fp); *lines = contlines; *samples = contsamples; return 0;
    } else return -2;
}

int readInput2(char* filename, float* data) { /* Same as reference */
    FILE *fp; char line[MAXLINE]=""; char *ptr; int i=0;
    if ((fp=fopen(filename,"rt"))!=NULL) {
        while(fgets(line, MAXLINE, fp)!= NULL) {
            ptr = strtok(line, "\t");
            while(ptr != NULL) { data[i] = atof(ptr); i++; ptr = strtok(NULL, "\t"); }
        }
        fclose(fp); return 0;
    } else return -2;
}

int writeResult(int *classMap, int lines, const char* filename) {
    FILE *fp;
    if ((fp=fopen(filename,"wt"))!=NULL) {
        for(int i=0; i<lines; i++) fprintf(fp,"%d\n",classMap[i]);
        fclose(fp); return 0;
    } else return -3;
}

/* * CUDA KERNEL: Assign Clusters
 * Uses Shared Memory to cache centroids for faster access.
 */
__global__ void assign_clusters(float *data, float *centroids, int *classMap, int *changes, 
                                int lines, int samples, int K) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    
    // Dynamic Shared Memory for centroids
    extern __shared__ float s_centroids[];

    // Load centroids into shared memory
    // Threads collaborate to load K * samples floats
    for (int i = threadIdx.x; i < K * samples; i += blockDim.x) {
        s_centroids[i] = centroids[i];
    }
    __syncthreads();

    if (idx < lines) {
        float minDist = FLT_MAX;
        int bestClass = 1;

        for (int k = 0; k < K; k++) {
            float dist = 0.0;
            for (int d = 0; d < samples; d++) {
                float diff = data[idx * samples + d] - s_centroids[k * samples + d];
                dist += diff * diff;
            }
            // sqrt is monotonic, so we can compare squared distances to save cycles,
            // but for strict adherence to reference we check sqrt if needed. 
            // Here we compare squared dists then sqrt at end if value needed, 
            // but logic only needs comparison.
            if (dist < minDist) {
                minDist = dist;
                bestClass = k + 1;
            }
        }

        if (classMap[idx] != bestClass) {
            atomicAdd(changes, 1);
            classMap[idx] = bestClass;
        }
    }
}

/*
 * CUDA KERNEL: Reset Accumulators
 */
__global__ void reset_accumulators(float *auxCentroids, int *pointsPerClass, int size_aux, int K) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < size_aux) auxCentroids[idx] = 0.0;
    if (idx < K) pointsPerClass[idx] = 0;
}

/* * CUDA KERNEL: Accumulate New Centroids
 * Each thread (point) adds its coordinates to the respective centroid accumulator.
 */
__global__ void accumulate_centroids(float *data, int *classMap, float *auxCentroids, int *pointsPerClass, 
                                     int lines, int samples) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < lines) {
        int class_id = classMap[idx] - 1; // 0-indexed
        
        // Count points per class
        // Note: atomicAdd on global memory can be slow with high contention.
        // Optimization: Use shared memory reduction if K is small, 
        // but for general case this is robust.
        atomicAdd(&pointsPerClass[class_id], 1);

        for (int d = 0; d < samples; d++) {
            atomicAdd(&auxCentroids[class_id * samples + d], data[idx * samples + d]);
        }
    }
}

/*
 * CUDA KERNEL: Compute Average
 * One thread per centroid dimension
 */
__global__ void compute_average(float *auxCentroids, int *pointsPerClass, int samples, int K) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int total_elements = K * samples;
    
    if (idx < total_elements) {
        int k = idx / samples; // Cluster index
        int count = pointsPerClass[k];
        if (count > 0) {
            auxCentroids[idx] /= count;
        }
    }
}

int main(int argc, char* argv[]) {
    clock_t start, end;
    start = clock();

    if(argc != 7) {
        fprintf(stderr,"./KMEANS_cuda [Input] [K] [Iter] [Changes] [Thresh] [Output]\n");
        exit(-1);
    }

    // Host Variables
    int lines = 0, samples = 0;
    readInput(argv[1], &lines, &samples);
    
    float *h_data = (float*)calloc(lines*samples,sizeof(float));
    readInput2(argv[1], h_data);

    int K = atoi(argv[2]);
    int maxIterations = atoi(argv[3]);
    int minChanges = (int)(lines*atof(argv[4])/100.0);
    float maxThreshold = atof(argv[5]);

    int *h_classMap = (int*)calloc(lines,sizeof(int));
    int *h_centroidPos = (int*)malloc(K*sizeof(int));
    float *h_centroids = (float*)calloc(K*samples,sizeof(float));

    srand(0);
    for(int i=0; i<K; i++) h_centroidPos[i]=rand()%lines;
    
    // Init centroids (Host side)
    for(int i=0; i<K; i++) {
        int idx = h_centroidPos[i];
        memcpy(&h_centroids[i*samples], &h_data[idx*samples], (samples*sizeof(float)));
    }

    printf("\n\tCUDA K-Means\n\tPoints: %d\tDims: %d\tK: %d\n", lines, samples, K);
    
    // Device Variables
    float *d_data, *d_centroids, *d_auxCentroids;
    int *d_classMap, *d_pointsPerClass, *d_changes;

    // Allocate Device Memory
    cudaCheckError(cudaMalloc(&d_data, lines * samples * sizeof(float)));
    cudaCheckError(cudaMalloc(&d_centroids, K * samples * sizeof(float)));
    cudaCheckError(cudaMalloc(&d_auxCentroids, K * samples * sizeof(float)));
    cudaCheckError(cudaMalloc(&d_classMap, lines * sizeof(int)));
    cudaCheckError(cudaMalloc(&d_pointsPerClass, K * sizeof(int)));
    cudaCheckError(cudaMalloc(&d_changes, sizeof(int)));

    // Copy Input Data
    cudaCheckError(cudaMemcpy(d_data, h_data, lines * samples * sizeof(float), cudaMemcpyHostToDevice));
    cudaCheckError(cudaMemcpy(d_centroids, h_centroids, K * samples * sizeof(float), cudaMemcpyHostToDevice));
    cudaCheckError(cudaMemcpy(d_classMap, h_classMap, lines * sizeof(int), cudaMemcpyHostToDevice));

    // Calculate grid dimensions
    int threadsPerBlock = BLOCK_SIZE;
    int blocksPerGrid = (lines + threadsPerBlock - 1) / threadsPerBlock;
    int sharedMemSize = K * samples * sizeof(float);

    // Change this if the output is overflowed
    char *outputMsg = (char *)calloc(100000,sizeof(char));
    char lineBuf[100];
    int changes = 0;
    int it = 0;
    float maxDist = FLT_MAX;
    
    // Aux host buffers for convergence check
    float *h_auxCentroids = (float*)malloc(K*samples*sizeof(float));

    end = clock();
    printf("\nInit & MemCpy: %f seconds\n", (double)(end - start) / CLOCKS_PER_SEC);
    start = clock();

    do {
        it++;
        
        // 1. Assignment Step
        cudaCheckError(cudaMemset(d_changes, 0, sizeof(int)));
        assign_clusters<<<blocksPerGrid, threadsPerBlock, sharedMemSize>>>(d_data, d_centroids, d_classMap, d_changes, lines, samples, K);
        cudaCheckError(cudaMemcpy(&changes, d_changes, sizeof(int), cudaMemcpyDeviceToHost));

        // 2. Update Step
        int aux_threads = 256;
        int aux_blocks = (K * samples + aux_threads - 1) / aux_threads;
        reset_accumulators<<<aux_blocks, aux_threads>>>(d_auxCentroids, d_pointsPerClass, K*samples, K);
        
        accumulate_centroids<<<blocksPerGrid, threadsPerBlock>>>(d_data, d_classMap, d_auxCentroids, d_pointsPerClass, lines, samples);
        
        compute_average<<<aux_blocks, aux_threads>>>(d_auxCentroids, d_pointsPerClass, samples, K);

        // 3. Convergence Check (CPU calculates dist between old and new centroids)
        // We copy centroids back to host to check maxDist. 
        // Note: For massive K, this should be done on GPU via reduction, but for typical K, PCI transfer is negligible.
        cudaCheckError(cudaMemcpy(h_auxCentroids, d_auxCentroids, K * samples * sizeof(float), cudaMemcpyDeviceToHost));
        
        maxDist = FLT_MIN;
        for(int i=0; i<K; i++) {
            float dist = 0.0;
            for(int j=0; j<samples; j++) {
                float diff = h_centroids[i*samples+j] - h_auxCentroids[i*samples+j];
                dist += diff * diff;
            }
            dist = sqrt(dist);
            if(dist > maxDist) maxDist = dist;
        }

        // Update old centroids with new ones
        memcpy(h_centroids, h_auxCentroids, K*samples*sizeof(float));
        cudaCheckError(cudaMemcpy(d_centroids, d_auxCentroids, K * samples * sizeof(float), cudaMemcpyDeviceToDevice));

        sprintf(lineBuf,"\n[%d] Changes: %d\tMaxDist: %f", it, changes, maxDist);
        strcat(outputMsg, lineBuf);

    } while((changes > minChanges) && (it < maxIterations) && (maxDist > maxThreshold));

    printf("%s", outputMsg);
    end = clock();
    printf("\nComputation: %f seconds", (double)(end - start) / CLOCKS_PER_SEC);

    // Retrieve results
    cudaCheckError(cudaMemcpy(h_classMap, d_classMap, lines * sizeof(int), cudaMemcpyDeviceToHost));

    writeResult(h_classMap, lines, argv[6]);

    // Free Memory
    free(h_data); free(h_classMap); free(h_centroids); free(h_auxCentroids); free(outputMsg);
    cudaFree(d_data); cudaFree(d_centroids); cudaFree(d_auxCentroids); 
    cudaFree(d_classMap); cudaFree(d_pointsPerClass); cudaFree(d_changes);

    return 0;
}
