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

# Build the project
build_project() {
    print_info "Building the project..."
    
    if make; then
        print_success "Build completed successfully"
    else
        print_error "Build failed"
        exit 1
    fi
}

# Build debug version
build_debug() {
    print_info "Building debug version..."
    
    if make debug; then
        print_success "Debug build completed successfully"
    else
        print_error "Debug build failed"
        exit 1
    fi
}

# Run basic tests
run_tests() {
    print_info "Running basic tests..."
    
    if [ -f "matrix_multiply" ]; then
        ./matrix_multiply
        if [ $? -eq 0 ]; then
            print_success "Basic tests passed"
        else
            print_error "Basic tests failed"
            exit 1
        fi
    else
        print_error "Executable not found. Please build the project first."
        exit 1
    fi
}

# Run debug tests
run_debug_tests() {
    print_info "Running debug tests..."
    
    if [ -f "matrix_multiply_debug" ]; then
        ./matrix_multiply_debug
        if [ $? -eq 0 ]; then
            print_success "Debug tests passed"
        else
            print_error "Debug tests failed"
            exit 1
    fi
    else
        print_error "Debug executable not found. Please build debug version first."
        exit 1
    fi
}

# Run performance test
run_performance_test() {
    print_info "Running performance test..."
    
    if [ -f "matrix_multiply" ]; then
        time ./matrix_multiply
        print_success "Performance test completed"
    else
        print_error "Executable not found. Please build the project first."
        exit 1
    fi
}

# Check for memory leaks (if valgrind is available)
check_memory_leaks() {
    if command -v valgrind &> /dev/null; then
        print_info "Checking for memory leaks with valgrind..."
        
        if [ -f "matrix_multiply_debug" ]; then
            valgrind --leak-check=full --error-exitcode=1 ./matrix_multiply_debug
            if [ $? -eq 0 ]; then
                print_success "No memory leaks detected"
            else
                print_error "Memory leaks detected"
                exit 1
            fi
        else
            print_warning "Debug executable not found. Skipping memory leak check."
        fi
    else
        print_warning "valgrind not found. Skipping memory leak check."
    fi
}

# Static analysis (if cppcheck is available)
run_static_analysis() {
    if command -v cppcheck &> /dev/null; then
        print_info "Running static analysis..."
        cppcheck --enable=all matrix_multiply.cpp
        print_success "Static analysis completed"
    else
        print_warning "cppcheck not found. Skipping static analysis."
    fi
}

# Main function
main() {
    echo "=== Matrix Multiplication Test Suite ==="
    echo ""
    
    # Check dependencies
    check_dependencies
    
    # Clean previous builds
    clean_build
    
    # Build project
    build_project
    
    # Run basic tests
    run_tests
    
    # Build debug version
    build_debug
    
    # Run debug tests
    run_debug_tests
    
    # Check for memory leaks
    check_memory_leaks
    
    # Run static analysis
    run_static_analysis
    
    # Run performance test
    run_performance_test
    
    echo ""
    print_success "All tests completed successfully!"
    echo ""
    echo "Available executables:"
    echo "  - matrix_multiply (release version)"
    echo "  - matrix_multiply_debug (debug version)"
    echo ""
    echo "You can run the program manually with: ./matrix_multiply"
}

# Handle command line arguments
case "$1" in
    "clean")
        clean_build
        ;;
    "build")
        build_project
        ;;
    "debug")
        build_debug
        ;;
    "test")
        run_tests
        ;;
    "perf")
        run_performance_test
        ;;
    "memcheck")
        check_memory_leaks
        ;;
    "analyze")
        run_static_analysis
        ;;
    "")
        main
        ;;
    *)
        echo "Usage: $0 [clean|build|debug|test|perf|memcheck|analyze]"
        echo "  clean     - Clean build artifacts"
        echo "  build     - Build release version"
        echo "  debug     - Build debug version"
        echo "  test      - Run basic tests"
        echo "  perf      - Run performance test"
        echo "  memcheck  - Check for memory leaks"
        echo "  analyze   - Run static analysis"
        echo "  (no args) - Run full test suite"
        exit 1
        ;;
esac