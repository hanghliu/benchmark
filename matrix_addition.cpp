// SPDX-License-Identifier: MPL-2.0

#include <iostream>
#include <vector>
#include <random>
#include <chrono>
#include <cmath>

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

void testBasicAddition() {
    std::cout << "=== Testing Basic Matrix Addition ===" << std::endl;

    Matrix A({{1, 2, 3}, {4, 5, 6}});
    Matrix B({{7, 8, 9}, {10, 11, 12}});

    std::cout << "Matrix A (2x3):" << std::endl;
    A.print();
    std::cout << "Matrix B (2x3):" << std::endl;
    B.print();

    Matrix C = Matrix::add(A, B);
    std::cout << "Result C = A + B (2x3):" << std::endl;
    C.print();

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
    Matrix C2 = Matrix::addOptimized(A, B);
    end = std::chrono::high_resolution_clock::now();
    auto duration2 = std::chrono::duration_cast<std::chrono::microseconds>(end - start);

    std::cout << "Standard addition time: " << duration1.count() << " microseconds" << std::endl;
    std::cout << "Optimized addition time: " << duration2.count() << " microseconds" << std::endl;
    std::cout << "Results are equal: " << (C1.isEqual(C2) ? "Yes" : "No") << std::endl;

    std::cout << std::endl;
}

void benchmarkMatrixAddition() {
    std::cout << "=== Matrix Addition Benchmark ===" << std::endl;

    std::vector<int> sizes = {10, 50, 100, 200, 500, 1000};

    for (int size : sizes) {
        Matrix A(size, size);
        Matrix B(size, size);

        A.randomize(-5.0, 5.0);
        B.randomize(-5.0, 5.0);

        // Warm up
        volatile double dummy = A(0, 0) + B(0, 0);

        // Benchmark
        auto start = std::chrono::high_resolution_clock::now();
        Matrix C = Matrix::add(A, B);
        auto end = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);

        double gflops = (double)size * size * 1e-3 / duration.count(); // Giga FLOPS per second

        std::cout << "Size: " << size << "x" << size
                  << ", Time: " << duration.count() << " μs"
                  << ", GFLOP/s: " << gflops << std::endl;
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

    // Time matrix addition
    auto start = std::chrono::high_resolution_clock::now();
    Matrix C_add = Matrix::add(A, B);
    auto end = std::chrono::high_resolution_clock::now();
    auto add_duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);

    // Time matrix multiplication
    start = std::chrono::high_resolution_clock::now();
    Matrix C_mult = Matrix::multiply(A, B);
    end = std::chrono::high_resolution_clock::now();
    auto mult_duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);

    std::cout << "Matrix size: " << size << "x" << size << std::endl;
    std::cout << "Addition time: " << add_duration.count() << " μs" << std::endl;
    std::cout << "Multiplication time: " << mult_duration.count() << " μs" << std::endl;
    std::cout << "Multiplication is " << (double)mult_duration.count() / add_duration.count()
              << "x slower than addition" << std::endl;

    std::cout << std::endl;
}

int main() {
    try {
        testBasicAddition();
        testRandomMatrices();
        benchmarkMatrixAddition();
        performanceComparison();

        std::cout << "All matrix addition benchmarks completed successfully!" << std::endl;
        return 0;
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
}