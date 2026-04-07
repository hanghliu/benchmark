// SPDX-License-Identifier: MPL-2.0

#include <iostream>
#include <vector>
#include <random>
#include <chrono>

class Matrix {
private:
    std::vector<std::vector<double>> data;
    int rows;
    int cols;

public:
    Matrix(int r, int c) : rows(r), cols(c) {
        data.resize(rows, std::vector<double>(cols, 0.0));
    }

    Matrix(const std::vector<std::vector<double>>& input) {
        rows = input.size();
        if (rows > 0) {
            cols = input[0].size();
            data = input;
        } else {
            cols = 0;
        }
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

    static Matrix multiplyOptimized(const Matrix& A, const Matrix& B) {
        if (A.getCols() != B.getRows()) {
            throw std::invalid_argument("Matrix dimensions do not match for multiplication");
        }

        int m = A.getRows();
        int n = A.getCols();
        int p = B.getCols();
        Matrix result(m, p);

        for (int i = 0; i < m; ++i) {
            for (int k = 0; k < n; ++k) {
                double a_ik = A(i, k);
                for (int j = 0; j < p; ++j) {
                    result(i, j) += a_ik * B(k, j);
                }
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

void testBasicMultiplication() {
    std::cout << "=== Testing Basic Matrix Multiplication ===" << std::endl;
    
    Matrix A({{1, 2, 3}, {4, 5, 6}});
    Matrix B({{7, 8}, {9, 10}, {11, 12}});
    
    std::cout << "Matrix A (2x3):" << std::endl;
    A.print();
    std::cout << "Matrix B (3x2):" << std::endl;
    B.print();
    
    Matrix C = Matrix::multiply(A, B);
    std::cout << "Result C (2x2):" << std::endl;
    C.print();
    
    std::cout << std::endl;
}

void testRandomMatrices() {
    std::cout << "=== Testing Random Matrix Multiplication ===" << std::endl;
    
    Matrix A(3, 4);
    Matrix B(4, 2);
    
    A.randomize();
    B.randomize();
    
    std::cout << "Matrix A (3x4):" << std::endl;
    A.print();
    std::cout << "Matrix B (4x2):" << std::endl;
    B.print();
    
    auto start = std::chrono::high_resolution_clock::now();
    Matrix C1 = Matrix::multiply(A, B);
    auto end = std::chrono::high_resolution_clock::now();
    auto duration1 = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
    
    start = std::chrono::high_resolution_clock::now();
    Matrix C2 = Matrix::multiplyOptimized(A, B);
    end = std::chrono::high_resolution_clock::now();
    auto duration2 = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
    
    std::cout << "Standard multiplication result (3x2):" << std::endl;
    C1.print();
    std::cout << "Optimized multiplication result (3x2):" << std::endl;
    C2.print();
    
    std::cout << "Standard multiplication time: " << duration1.count() << " microseconds" << std::endl;
    std::cout << "Optimized multiplication time: " << duration2.count() << " microseconds" << std::endl;
    std::cout << "Results are equal: " << (C1.isEqual(C2) ? "Yes" : "No") << std::endl;
    
    std::cout << std::endl;
}

void testPerformance() {
    std::cout << "=== Performance Testing ===" << std::endl;
    
    int sizes[] = {10, 50, 100};
    
    for (int size : sizes) {
        Matrix A(size, size);
        Matrix B(size, size);
        A.randomize();
        B.randomize();
        
        auto start = std::chrono::high_resolution_clock::now();
        Matrix C = Matrix::multiply(A, B);
        auto end = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
        
        std::cout << "Matrix size: " << size << "x" << size << std::endl;
        std::cout << "Multiplication time: " << duration.count() << " ms" << std::endl;
    }
    
    std::cout << std::endl;
}

int main() {
    try {
        testBasicMultiplication();
        testRandomMatrices();
        testPerformance();
        
        std::cout << "All tests completed successfully!" << std::endl;
        return 0;
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
}