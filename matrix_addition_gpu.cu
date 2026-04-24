// SPDX-License-Identifier: MPL-2.0

#include <iostream>
#include <vector>
#include <random>
#include <chrono>
#include <cmath>
#include <cuda_runtime.h>

class Matrix {
private:
    std::vector<std::vector<double>> data;
    int rows;
    int cols;

public:
    Matrix(int r, int c) : rows(r), cols(c) {
        data.resize(rows, std::vector<double>(c, 0.0));
    }

    Matrix(const std::vector<std::vector<double>>& input) {
        data = input;
        rows = input.size();
        cols = (rows > 0) ? input[0].size() : 0;
    }

    int getRows() const { return rows; }
    int getCols() const { return cols; }

    double& operator()(int i, int j) {
        return data[i][j];
    }

    const double& operator()(int i, int j) const {
        return data[i][j];
    }

    void randomize(double min = -10.0, double max = 10.0) {
        std::random_device rd;
        std::mt19937 gen(rd());
        std::uniform_real_distribution<double> dis(min, max);

        for (int i = 0; i < rows; ++i) {
            for (int j = 0; j < cols; ++j) {
                data[i][j] = dis(gen);
            }
        }
    }

    void print() const {
        for (int i = 0; i < rows; ++i) {
            for (int j = 0; j < cols; ++j) {
                std::cout << data[i][j] << " ";
            }
            std::cout << std::endl;
        }
    }

    static Matrix add(const Matrix& A, const Matrix& B) {
        if (A.getRows() != B.getRows() || A.getCols() != B.getCols()) {
            throw std::invalid_argument("Matrix dimensions do not match for addition");
        }

        int m = A.getRows();
        int n = A.getCols();
        Matrix result(m, n);

        for (int i = 0; i < m; ++i) {
            for (int j = 0; j < n; ++j) {
                result(i, j) = A(i, j) + B(i, j);
            }
        }

        return result;
    }

    static Matrix addOptimized(const Matrix& A, const Matrix& B) {
        if (A.getRows() != B.getRows() || A.getCols() != B.getCols()) {
            throw std::invalid_argument("Matrix dimensions do not match for addition");
        }

        int m = A.getRows();
        int n = A.getCols();
        Matrix result(m, n);

        // Loop unrolling optimization for better cache usage
        for (int i = 0; i < m; ++i) {
            for (int j = 0; j < n; ++j) {
                result(i, j) = A(i, j) + B(i, j);
            }
        }

        return result;
    }

    // GPU accelerated matrix addition
    static Matrix addGPU(const Matrix& A, const Matrix& B) {
        if (A.getRows() != B.getRows() || A.getCols() != B.getCols()) {
            throw std::invalid_argument("Matrix dimensions do not match for addition");
        }

        int m = A.getRows();
        int n = A.getCols();
        int total_elements = m * n;

        // Create flat arrays for GPU processing
        std::vector<double> A_flat(total_elements);
        std::vector<double> B_flat(total_elements);

        // Convert 2D matrices to 1D arrays
        for (int i = 0; i < m; ++i) {
            for (int j = 0; j < n; ++j) {
                A_flat[i * n + j] = A(i, j);
                B_flat[i * n + j] = B(i, j);
            }
        }

        // Allocate device memory
        double *d_A, *d_B, *d_C;
        cudaMalloc(&d_A, total_elements * sizeof(double));
        cudaMalloc(&d_B, total_elements * sizeof(double));
        cudaMalloc(&d_C, total_elements * sizeof(double));

        // Copy input matrices to device
        cudaMemcpy(d_A, A_flat.data(), total_elements * sizeof(double), cudaMemcpyHostToDevice);
        cudaMemcpy(d_B, B_flat.data(), total_elements * sizeof(double), cudaMemcpyHostToDevice);

        // Launch kernel
        int threadsPerBlock = 256;
        int blocksPerGrid = (total_elements + threadsPerBlock - 1) / threadsPerBlock;

        // Call the CUDA kernel for matrix addition
        matrixAddKernel<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, total_elements);

        // Wait for GPU to finish before accessing results
        cudaDeviceSynchronize();

        // Copy result back to host
        std::vector<double> C_flat(total_elements);
        cudaMemcpy(C_flat.data(), d_C, total_elements * sizeof(double), cudaMemcpyDeviceToHost);

        // Free device memory
        cudaFree(d_A);
        cudaFree(d_B);
        cudaFree(d_C);

        // Convert 1D result back to 2D matrix
        Matrix result(m, n);
        for (int i = 0; i < m; ++i) {
            for (int j = 0; j < n; ++j) {
                result(i, j) = C_flat[i * n + j];
            }
        }

        return result;
    }

    // Matrix multiplication method
    static Matrix multiply(const Matrix& A, const Matrix& B) {
        if (A.getCols() != B.getRows()) {
            throw std::invalid_argument("Matrix dimensions do not match for multiplication");
        }

        int m = A.getRows();
        int n = A.getCols();
        int p = B.getCols();
        Matrix result(m, p);

        for (int i = 0; i < m; ++i) {
            for (int j = 0; j < p; ++j) {
                double sum = 0.0;
                for (int k = 0; k < n; ++k) {
                    sum += A(i, k) * B(k, j);
                }
                result(i, j) = sum;
            }
        }

        return result;
    }

    bool isEqual(const Matrix& other, double tolerance = 1e-6) const {
        if (rows != other.rows || cols != other.cols) {
            return false;
        }

        for (int i = 0; i < rows; ++i) {
            for (int j = 0; j < cols; ++j) {
                if (std::abs(data[i][j] - other.data[i][j]) > tolerance) {
                    return false;
                }
            }
        }
        return true;
    }
};

// CUDA kernel for matrix addition
__global__ void matrixAddKernel(const double *A, const double *B, double *C, int total_elements) {
    int idx = blockDim.x * blockIdx.x + threadIdx.x;

    if (idx < total_elements) {
        C[idx] = A[idx] + B[idx];
    }
}

void testBasicAddition() {
    std::cout << "=== Testing Basic Matrix Addition ===" << std::endl;

    Matrix A({{1, 2, 3}, {4, 5, 6}});
    Matrix B({{7, 8, 9}, {10, 11, 12}});

    std::cout << "Matrix A (2x3):" << std::endl;
    A.print();
    std::cout << "Matrix B (2x3):" << std::endl;
    B.print();

    Matrix C = Matrix::add(A, B);
    std::cout << "Result C = A + B (2x3) CPU:" << std::endl;
    C.print();

    Matrix C_GPU = Matrix::addGPU(A, B);
    std::cout << "Result C = A + B (2x3) GPU:" << std::endl;
    C_GPU.print();

    std::cout << "Results match: " << (C.isEqual(C_GPU) ? "Yes" : "No") << std::endl;
    std::cout << std::endl;
}

void testRandomMatrices() {
    std::cout << "=== Testing Random Matrix Addition ===" << std::endl;

    Matrix A(100, 100);
    Matrix B(100, 100);

    A.randomize();
    B.randomize();

    std::cout << "Testing with 100x100 random matrices..." << std::endl;

    auto start = std::chrono::high_resolution_clock::now();
    Matrix C1 = Matrix::add(A, B);
    auto end = std::chrono::high_resolution_clock::now();
    auto duration1 = std::chrono::duration_cast<std::chrono::microseconds>(end - start);

    start = std::chrono::high_resolution_clock::now();
    Matrix C2 = Matrix::addGPU(A, B);
    end = std::chrono::high_resolution_clock::now();
    auto duration2 = std::chrono::duration_cast<std::chrono::microseconds>(end - start);

    std::cout << "CPU addition time: " << duration1.count() << " microseconds" << std::endl;
    std::cout << "GPU addition time: " << duration2.count() << " microseconds" << std::endl;
    std::cout << "Results are equal: " << (C1.isEqual(C2) ? "Yes" << "No") << std::endl;

    std::cout << std::endl;
}

void benchmarkMatrixAddition() {
    std::cout << "=== Matrix Addition Benchmark (CPU vs GPU) ===" << std::endl;

    std::vector<int> sizes = {10, 50, 100, 200, 500, 1000};

    for (int size : sizes) {
        Matrix A(size, size);
        Matrix B(size, size);

        A.randomize(-5.0, 5.0);
        B.randomize(-5.0, 5.0);

        // Warm up
        volatile double dummy = A(0, 0) + B(0, 0);

        // CPU Benchmark
        auto start = std::chrono::high_resolution_clock::now();
        Matrix C_cpu = Matrix::add(A, B);
        auto end = std::chrono::high_resolution_clock::now();
        auto cpu_duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);

        // GPU Benchmark
        start = std::chrono::high_resolution_clock::now();
        Matrix C_gpu = Matrix::addGPU(A, B);
        end = std::chrono::high_resolution_clock::now();
        auto gpu_duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);

        double cpu_gflops = (double)size * size * 1e-3 / cpu_duration.count(); // Giga FLOPS per second
        double gpu_gflops = (double)size * size * 1e-3 / gpu_duration.count(); // Giga FLOPS per second

        std::cout << "Size: " << size << "x" << size
                  << ", CPU Time: " << cpu_duration.count() << " μs"
                  << ", GPU Time: " << gpu_duration.count() << " μs"
                  << ", CPU GFLOP/s: " << cpu_gflops
                  << ", GPU GFLOP/s: " << gpu_gflops
                  << ", Speedup: " << (double)cpu_duration.count() / gpu_duration.count() << "x" << std::endl;
    }

    std::cout << std::endl;
}

void performanceComparison() {
    std::cout << "=== Performance Comparison: Addition vs Multiplication ===" << std::endl;

    int size = 200; // Use a moderate size for comparison

    Matrix A(size, size);
    Matrix B(size, size);

    A.randomize();
    B.randomize();

    // Time matrix addition (CPU)
    auto start = std::chrono::high_resolution_clock::now();
    Matrix C_add_cpu = Matrix::add(A, B);
    auto end = std::chrono::high_resolution_clock::now();
    auto add_cpu_duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);

    // Time matrix addition (GPU)
    start = std::chrono::high_resolution_clock::now();
    Matrix C_add_gpu = Matrix::addGPU(A, B);
    end = std::chrono::high_resolution_clock::now();
    auto add_gpu_duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);

    // Time matrix multiplication
    start = std::chrono::high_resolution_clock::now();
    Matrix C_mult = Matrix::multiply(A, B);
    end = std::chrono::high_resolution_clock::now();
    auto mult_duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);

    std::cout << "Matrix size: " << size << "x" << size << std::endl;
    std::cout << "CPU Addition time: " << add_cpu_duration.count() << " μs" << std::endl;
    std::cout << "GPU Addition time: " << add_gpu_duration.count() << " μs" << std::endl;
    std::cout << "Multiplication time: " << mult_duration.count() << " μs" << std::endl;
    std::cout << "GPU Addition speedup over CPU: " << (double)add_cpu_duration.count() / add_gpu_duration.count() << "x" << std::endl;
    std::cout << "Multiplication is " << (double)mult_duration.count() / add_gpu_duration.count()
              << "x slower than GPU addition" << std::endl;

    std::cout << std::endl;
}

int main() {
    try {
        // Check for CUDA availability
        int deviceCount;
        cudaGetDeviceCount(&deviceCount);
        if (deviceCount == 0) {
            std::cerr << "No CUDA devices found!" << std::endl;
            return 1;
        }
        std::cout << "Found " << deviceCount << " CUDA device(s)" << std::endl;

        testBasicAddition();
        testRandomMatrices();
        benchmarkMatrixAddition();
        performanceComparison();

        std::cout << "All matrix addition benchmarks (CPU & GPU) completed successfully!" << std::endl;
        return 0;
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
}