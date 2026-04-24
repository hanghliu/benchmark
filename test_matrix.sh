#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are available
check_dependencies() {
    print_info "Checking dependencies..."

    if ! command -v g++ &> /dev/null; then
        print_error "g++ compiler not found. Please install g++"
        exit 1
    fi

    if ! command -v make &> /dev/null; then
        print_error "make not found. Please install make"
        exit 1
    fi

    print_success "All dependencies are available"
}

# Clean previous builds
clean_build() {
    print_info "Cleaning previous builds..."
    make clean
    print_success "Build cleaned"
}

# Build all projects
build_projects() {
    print_info "Building all projects..."

    if make; then
        print_success "All builds completed successfully"
    else
        print_error "Build failed"
        exit 1
    fi
}

# Build debug version of all projects
build_debug() {
    print_info "Building debug versions..."

    if make debug; then
        print_success "All debug builds completed successfully"
    else
        print_error "Debug build failed"
        exit 1
    fi
}

# Run matrix multiplication tests
run_matrix_multiply_tests() {
    print_info "Running matrix multiplication tests..."

    if [ -f "matrix_multiply" ]; then
        ./matrix_multiply
        if [ $? -eq 0 ]; then
            print_success "Matrix multiplication tests passed"
        else
            print_error "Matrix multiplication tests failed"
            exit 1
        fi
    else
        print_error "matrix_multiply executable not found. Please build the project first."
        exit 1
    fi
}

# Run matrix addition tests
run_matrix_addition_tests() {
    print_info "Running matrix addition benchmarks..."

    if [ -f "matrix_addition" ]; then
        ./matrix_addition
        if [ $? -eq 0 ]; then
            print_success "Matrix addition benchmarks passed"
        else
            print_error "Matrix addition benchmarks failed"
            exit 1
        fi
    else
        print_error "matrix_addition executable not found. Please build the project first."
        exit 1
    fi
}

# Run all tests
run_all_tests() {
    run_matrix_multiply_tests
    run_matrix_addition_tests
}

# Run debug tests for matrix multiplication
run_matrix_multiply_debug_tests() {
    print_info "Running matrix multiplication debug tests..."

    if [ -f "matrix_multiply_debug" ]; then
        ./matrix_multiply_debug
        if [ $? -eq 0 ]; then
            print_success "Matrix multiplication debug tests passed"
        else
            print_error "Matrix multiplication debug tests failed"
            exit 1
        fi
    else
        print_error "Matrix multiplication debug executable not found. Please build debug version first."
        exit 1
    fi
}

# Run debug tests for matrix addition
run_matrix_addition_debug_tests() {
    print_info "Running matrix addition debug benchmarks..."

    if [ -f "matrix_addition_debug" ]; then
        ./matrix_addition_debug
        if [ $? -eq 0 ]; then
            print_success "Matrix addition debug benchmarks passed"
        else
            print_error "Matrix addition debug benchmarks failed"
            exit 1
        fi
    else
        print_error "Matrix addition debug executable not found. Please build debug version first."
        exit 1
    fi
}

# Run all debug tests
run_all_debug_tests() {
    run_matrix_multiply_debug_tests
    run_matrix_addition_debug_tests
}

# Run performance test for matrix multiplication
run_matrix_multiply_performance_test() {
    print_info "Running matrix multiplication performance test..."

    if [ -f "matrix_multiply" ]; then
        time ./matrix_multiply
        print_success "Matrix multiplication performance test completed"
    else
        print_error "matrix_multiply executable not found. Please build the project first."
        exit 1
    fi
}

# Run performance test for matrix addition
run_matrix_addition_performance_test() {
    print_info "Running matrix addition performance test..."

    if [ -f "matrix_addition" ]; then
        time ./matrix_addition
        print_success "Matrix addition performance test completed"
    else
        print_error "matrix_addition executable not found. Please build the project first."
        exit 1
    fi
}

# Run all performance tests
run_all_performance_tests() {
    run_matrix_multiply_performance_test
    run_matrix_addition_performance_test
}

# Check for memory leaks in matrix multiplication (if valgrind is available)
check_matrix_multiply_memory_leaks() {
    if command -v valgrind &> /dev/null; then
        print_info "Checking matrix multiplication for memory leaks with valgrind..."

        if [ -f "matrix_multiply_debug" ]; then
            valgrind --leak-check=full --error-exitcode=1 ./matrix_multiply_debug
            if [ $? -eq 0 ]; then
                print_success "No memory leaks detected in matrix multiplication"
            else
                print_error "Memory leaks detected in matrix multiplication"
                exit 1
            fi
        else
            print_warning "Matrix multiplication debug executable not found. Skipping memory leak check."
        fi
    else
        print_warning "valgrind not found. Skipping matrix multiplication memory leak check."
    fi
}

# Check for memory leaks in matrix addition (if valgrind is available)
check_matrix_addition_memory_leaks() {
    if command -v valgrind &> /dev/null; then
        print_info "Checking matrix addition for memory leaks with valgrind..."

        if [ -f "matrix_addition_debug" ]; then
            valgrind --leak-check=full --error-exitcode=1 ./matrix_addition_debug
            if [ $? -eq 0 ]; then
                print_success "No memory leaks detected in matrix addition"
            else
                print_error "Memory leaks detected in matrix addition"
                exit 1
            fi
        else
            print_warning "Matrix addition debug executable not found. Skipping memory leak check."
        fi
    else
        print_warning "valgrind not found. Skipping matrix addition memory leak check."
    fi
}

# Check for memory leaks in all projects
check_all_memory_leaks() {
    check_matrix_multiply_memory_leaks
    check_matrix_addition_memory_leaks
}

# Static analysis for all files (if cppcheck is available)
run_static_analysis() {
    if command -v cppcheck &> /dev/null; then
        print_info "Running static analysis on all files..."
        cppcheck --enable=all matrix_multiply.cpp matrix_addition.cpp
        print_success "Static analysis completed"
    else
        print_warning "cppcheck not found. Skipping static analysis."
    fi
}

# Main function
main() {
    echo "=== Comprehensive Matrix Test Suite ==="
    echo ""

    # Check dependencies
    check_dependencies

    # Clean previous builds
    clean_build

    # Build all projects
    build_projects

    # Run all tests
    run_all_tests

    # Build debug versions
    build_debug

    # Run all debug tests
    run_all_debug_tests

    # Check for memory leaks
    check_all_memory_leaks

    # Run static analysis
    run_static_analysis

    # Run performance tests
    run_all_performance_tests

    echo ""
    print_success "All tests completed successfully!"
    echo ""
    echo "Available executables:"
    echo "  - matrix_multiply (release version)"
    echo "  - matrix_addition (release version)"
    echo "  - matrix_multiply_debug (debug version)"
    echo "  - matrix_addition_debug (debug version)"
    echo ""
    echo "You can run the programs manually with: ./matrix_multiply or ./matrix_addition"
}

# Handle command line arguments
case "$1" in
    "clean")
        clean_build
        ;;
    "build")
        build_projects
        ;;
    "debug")
        build_debug
        ;;
    "test")
        run_all_tests
        ;;
    "test-multiply")
        run_matrix_multiply_tests
        ;;
    "test-addition")
        run_matrix_addition_tests
        ;;
    "perf")
        run_all_performance_tests
        ;;
    "perf-multiply")
        run_matrix_multiply_performance_test
        ;;
    "perf-addition")
        run_matrix_addition_performance_test
        ;;
    "memcheck")
        check_all_memory_leaks
        ;;
    "memcheck-multiply")
        check_matrix_multiply_memory_leaks
        ;;
    "memcheck-addition")
        check_matrix_addition_memory_leaks
        ;;
    "analyze")
        run_static_analysis
        ;;
    "")
        main
        ;;
    *)
        echo "Usage: $0 [clean|build|debug|test|test-multiply|test-addition|perf|perf-multiply|perf-addition|memcheck|memcheck-multiply|memcheck-addition|analyze]"
        echo "  clean               - Clean build artifacts"
        echo "  build               - Build all projects"
        echo "  debug               - Build debug versions"
        echo "  test                - Run all tests"
        echo "  test-multiply       - Run matrix multiplication tests"
        echo "  test-addition       - Run matrix addition benchmarks"
        echo "  perf                - Run all performance tests"
        echo "  perf-multiply       - Run matrix multiplication performance test"
        echo "  perf-addition       - Run matrix addition performance test"
        echo "  memcheck            - Check all projects for memory leaks"
        echo "  memcheck-multiply   - Check matrix multiplication for memory leaks"
        echo "  memcheck-addition   - Check matrix addition for memory leaks"
        echo "  analyze             - Run static analysis"
        echo "  (no args)           - Run full test suite"
        exit 1
        ;;
esac