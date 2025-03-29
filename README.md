# 4*4-Systolic-Array-For-Matrix-Multiplication
This project implements matrix multiplication on an FPGA using a systolic array architecture with SystemVerilog. The design uses parallel processing capabilities of FPGAs, providing high-performance results. 
This project can be used for deep learning accelerators.

**Description of each module:**

top: The main module for interfacing input and output signals and managing the processing unit.

Activation: Implementation of the activation function that compares the input value against a threshold.

Array: Matrix processing module for parallel computations.

FIFO: Queue memory for storing and managing input and output data.

MAC: Multiply-Accumulate unit for performing computational operations.

Quantization: Quantization module for limiting values to 8 bits.

tb (Testbench): Test module for evaluating the overall performance of the project.
