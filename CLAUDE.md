# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains two main projects:

1. **vectorAdd_nvrtc**: A CUDA sample demonstrating vector addition using NVRTC (NVIDIA Runtime Compilation) with the CUDA Driver API. It performs runtime compilation of CUDA kernels.

2. **matrix_multiply**: A C++ program implementing matrix multiplication with optimized algorithms and performance testing capabilities.

3. **matrix_addition**: A C++ program implementing matrix addition with benchmarks comparing performance against matrix multiplication, including optimized implementations and comprehensive testing.

## Architecture and Structure

The codebase consists of:
- CUDA-based vector addition example using driver API and NVRTC runtime compilation
- C++ matrix multiplication implementation with basic and optimized algorithms
- C++ matrix addition implementation with benchmarking capabilities
- Build system supporting both Make and CMake
- Comprehensive test scripts and license checking utilities

## Building and Running

### For the CUDA vectorAdd_nvrtc project:
```bash
# Using CMake:
mkdir build && cd build
cmake ..
make

# Run:
./vectorAdd_nvrtc
```

### For the matrix_multiply and matrix_addition projects:
```bash
# Using Make:
make                    # Build release versions of both programs
make debug             # Build debug versions of both programs
make run               # Run the matrix multiplication program
make run-addition      # Run the matrix addition benchmark
make perf              # Run performance tests for both programs
make valgrind          # Run memory leak detection for both programs
make check             # Run static analysis on both programs

# Using test script:
./test_matrix.sh       # Run full test suite for both programs
./test_matrix.sh build # Build all programs
./test_matrix.sh test  # Run all tests
./test_matrix.sh test-addition  # Run only matrix addition benchmarks
./test_matrix.sh test-multiply  # Run only matrix multiplication tests
./test_matrix.sh perf-addition  # Run only matrix addition performance test
./test_matrix.sh perf-multiply  # Run only matrix multiplication performance test
```

## Dependencies

- CUDA Toolkit 12.5 or later with NVRTC and CUDA driver libraries (for vectorAdd_nvrtc)
- GCC/G++ compiler (tested with C++11 and later)
- CMake 3.20+ for CMake builds
- Optional: valgrind, cppcheck for development

## Key Files

- `vectorAdd.cpp`: Main CUDA application using driver API
- `vectorAdd_kernel.cu`: CUDA kernel source compiled at runtime
- `matrix_multiply.cpp`: C++ matrix multiplication implementation
- `matrix_addition.cpp`: C++ matrix addition implementation with benchmarks
- `Makefile`: Build configuration for matrix multiplication and addition
- `CMakeLists.txt`: Build configuration for CUDA vector addition
- `test_matrix.sh`: Comprehensive test script for both matrix programs
- `check_license_headers.sh`: License header verification script

## Development Guidelines

- All source files must include the SPDX license header: `// SPDX-License-Identifier: MPL-2.0`
- CUDA code uses the driver API (CUfunction, cuMemAlloc, etc.) rather than runtime API
- Matrix multiplication and addition implementations include both basic and optimized algorithms
- Both debug (-g) and release (-O3) build configurations are supported
- Memory management follows CUDA best practices with proper allocation/free cycles