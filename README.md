# parallelProgramming1
System requirements: CUDA 7.5 environment

Path setup for running cuda programs:
These two commands need to be executed in console for setting up the CUDA envirionment path.
            

	$export PATH=/usr/local/cuda-7.5/bin:$PATH

        $export LD_LIBRARY_PATH=/usr/local/cuda-7.5/lib64:$LD_LIBRARY_PATH

Path setup can be confirmed using command:
	
	nvcc --version

The output should be like this:

nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2015 NVIDIA Corporation
Built on Tue_Aug_11_14:27:32_CDT_2015
Cuda compilation tools, release 7.5, V7.5.17

Tasks:

1. Vector addition for two dimensional vectors:

Description: 
For this task, i developed a complete CUDA program with a name "GesuVecAdd.cu" for integer matrix addition. 

Program compilation:
For program compilation we need to be in same folder where all the files are present which can done using "cd /path/" command.
program can be compiled using the make file "Makefile" and typing the following command in terminal:

	make

Program Execution:
After successful compilation, program can be executed using command:

	./VecAdd
  On execution: program would ask user to enter the array size for the vector from a list.
Enter a if you want 8*8 matrix
Enter b if you want 64*64 matrix
Enter c if you want 128*128 matrix
Enter d if you want 500*500 matrix
Enter e if you want 1000*1000 matrix

After entering the letter, program would calculate addition results for both GPU and CPU and then compare them and display"CPU and GPU results matched: Test PASSED" if both the results match.
