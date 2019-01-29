//CS-4370 Parallel Programming for many core GPUs
//Name: Gesu Bal
/*
this is a simple cuda program calculating vector add for 2 dimensions on GPU device
I added two two-dimensional matrices A, B on the device GPU. 
After the device matrix addition kernel function is invoked, and the addition result is transferred back to the CPU. 
The program will also compute the  sum matrix of matrices A and B using the CPU.  
Then the program compares the device-computed result with the CPU-computed result. 
If it matches, it prints out Test PASSED to the screen before exiting.
*/
#include<stdio.h>
#include<cuda.h>
int N,blocksize;

//gpu function for addition
__global__ void add_gpu(int *d_a, int *d_b, int *d_c, int N)
{
     
     int row=blockIdx.y*blockDim.y+threadIdx.y;
     int col=blockIdx.x*blockDim.x+threadIdx.x;
     //int index =i+(j*N); 
     if((row <N) && (col <N))
     {
       
           d_c[row*N+col]=d_a[row*N+col]+d_b[row*N+col];
	   
      }
      
      
}

//cpu function for addition
void add_matrix_cpu(int *a, int *b, int *cpu_c, int N)
{ 
int i, j; 
for (i=0;i<N;i++) { 
       for (j=0;j<N;j++) {
             
             cpu_c[i*N+j]=a[i*N+j]+b[i*N+j];
     } 
  } 
} 

//match cpu and gpu results
int verify(int * a, int * b, int N)
{   
    int i,j;
    int error=0;
	for(i=0;i<N;i++)
	{
		for(j=0;j<N;j++)
		{
		    if(a[i*N+j]!=b[i*N+j])
		    {
		     error++; 
		    }
		}
	}
	
	if(error==0)
	{
	  printf("CPU and GPU results matched: Test Passed \n");
	}
	else
	{
	  printf("CPU and GPU results did not match");
	}
    return 1;
    
}

//print matrix fucntion
int printMatrix(int *a,int N)
{
  int i,j;
  for (i=0;i<N;i++)
    {
        for (j=0;j<N;j++)
        {
          printf("%d\t",a[i*N+j]);
        }
        printf("\n");
    }
return 1;
  
}

int main()
{
    //user input    
    int r, col;
	printf("Select one of the following options for vector addition: \n");
	printf("Press a for matrix size 8 * 8 \n");
	printf("Press b for matrix size 64 * 64 \n");
	printf("Press c for matrix size 128 * 128 \n");
	printf("Press d for matrix size 500 * 500 \n");
	printf("Press e for matrix size 1000 * 1000 \n");
    printf("Press any other key for exiting \n");
	char ch;
	scanf("%c",&ch);
	switch(ch)
        {
            case 'a':
                r=8;
		col=8;
		N=8;
		blocksize=4;
		printf("Array size is 8 * 8 \n");
		
                break;
            case 'b':
                r=64;
		col=64;
		N=64;
		blocksize=16;
		printf("Array size is 64 * 64 \n");
		
                break;
            case 'c':
                r=128;
		col=128;
		N=128;
		blocksize=16;
		printf("Array size is 128 * 128 \n");
		
                break;
	    case 'd':
                r=500;
		col=500;
		N=500;
		blocksize=16;
		printf("Array size is 500 * 500 \n");
		
                break;
            case 'e':
                r=1000;
		col=1000;
		N=1000;
		blocksize=16;
		printf("Array size is 1000 * 1000 \n");
		
                break;
	    default:
		exit(1);
                break;            
	}
  
    //vector initialization
	int *a, *b, *c, *cpu_c, *d_a, *d_b, *d_c;
	
	int a_size=r*col;
	int b_size=r*col;
	int c_size=r*col;
	int cpu_c_size=r*col;
	
    
    //memory allocation for vectors on host	
	a=(int*)malloc(sizeof(int)*a_size);
	b=(int*)malloc(sizeof(int)*b_size);
	c=(int*)malloc(sizeof(int)*c_size);
	cpu_c=(int*)malloc(sizeof(int)*cpu_c_size);
		
	
	//matrix initialization
    int i,j;
	int init=1325;
        for (i=0;i<N;i++)
	{
		for (j=0;j<N;j++)
		{
		    init=3125*init%65536;
		    a[i*col+j]=((init-32768)/16384);
		    b[i*col+j]=(init%1000);
		}
	}

	int cudaret=cudaMalloc((void **)(&d_a),(N*N)*sizeof(int));
	if(cudaret!=cudaSuccess)
	{printf("memory was not allocated on device \n");}
	
	cudaMalloc((void **)(&d_b),(N*N)*sizeof(int));
	cudaMalloc((void **)(&d_c),(N*N)*sizeof(int));
	

	//copying contents of a and b to device arrays
	cudaMemcpy(d_a,a,(N*N)*sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(d_b,b,(N*N)*sizeof(int),cudaMemcpyHostToDevice);
	
	//Initializing block count and block size
	dim3 dimBlock(blocksize,blocksize,1); 
	int blockCount_x = (N - 1)/(double(blocksize))+1;//Get number of blocks needed per direction.
	int blockCount_y = (N - 1)/(double(blocksize))+1;
	printf("the number of the thread blocks in x direction will be %d\n", blockCount_x);
	printf("the number of the thread blocks in y direction will be %d\n", blockCount_y);
	dim3 dimGrid(blockCount_x,blockCount_y,1);
        
	//calling CPU program
	printf("calculating results for CPU vector addition \n");
	printf("---------\n");
	add_matrix_cpu(a,b,cpu_c,N);
    
    //printMatrix(a,N);
    //pritnMatrix(b,N);
    //printMatrix(cpu_c,N);
	
	//call kernel for gpu functioning
	printf("calling kernel for gpu computations for vector addition \n");
	printf("---------\n");
	add_gpu<<<dimGrid,dimBlock>>>(d_a,d_b,d_c,N);
	printf("calculating results for gpu \n");
	printf("---------\n");
	
    //copying resulting back to cpu from gpu
    cudaMemcpy(c,d_c,(N*N)*sizeof(int),cudaMemcpyDeviceToHost);
        
	//matching cpu and gpu results
	printf("comparing results for CPU and GPU computations \n");
	printf("---------\n");
	verify(c,cpu_c,N);
	//printMatrix(c,N);
	
    //Deallocating memory
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
	
    return 0;
}
