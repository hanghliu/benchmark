# Compiler and flags
CXX = g++
NVCC = nvcc
CXXFLAGS = -std=c++11 -Wall -Wextra -O2
NVCCFLAGS = -std=c++11 -O3 -DNDEBUG
DEBUG_FLAGS = -g -DDEBUG
RELEASE_FLAGS = -O3 -DNDEBUG

# Target executables
MATRIX_MULTIPLY_TARGET = matrix_multiply
MATRIX_ADDITION_TARGET = matrix_addition
MATRIX_ADDITION_GPU_TARGET = matrix_addition_gpu

# Source files
MATRIX_MULTIPLY_SRC = matrix_multiply.cpp
MATRIX_ADDITION_SRC = matrix_addition.cpp
MATRIX_ADDITION_GPU_SRC = matrix_addition_gpu.cu

# Default target
all: $(MATRIX_MULTIPLY_TARGET) $(MATRIX_ADDITION_TARGET) $(MATRIX_ADDITION_GPU_TARGET)

# Build the targets
$(MATRIX_MULTIPLY_TARGET): $(MATRIX_MULTIPLY_SRC)
	$(CXX) $(CXXFLAGS) $(RELEASE_FLAGS) -o $(MATRIX_MULTIPLY_TARGET) $(MATRIX_MULTIPLY_SRC)

$(MATRIX_ADDITION_TARGET): $(MATRIX_ADDITION_SRC)
	$(CXX) $(CXXFLAGS) $(RELEASE_FLAGS) -o $(MATRIX_ADDITION_TARGET) $(MATRIX_ADDITION_SRC)

$(MATRIX_ADDITION_GPU_TARGET): $(MATRIX_ADDITION_GPU_SRC)
	$(NVCC) $(NVCCFLAGS) -o $(MATRIX_ADDITION_GPU_TARGET) $(MATRIX_ADDITION_GPU_SRC)

# Debug build
debug: $(MATRIX_MULTIPLY_SRC) $(MATRIX_ADDITION_SRC) $(MATRIX_ADDITION_GPU_SRC)
	$(CXX) $(CXXFLAGS) $(DEBUG_FLAGS) -o $(MATRIX_MULTIPLY_TARGET)_debug $(MATRIX_MULTIPLY_SRC)
	$(CXX) $(CXXFLAGS) $(DEBUG_FLAGS) -o $(MATRIX_ADDITION_TARGET)_debug $(MATRIX_ADDITION_SRC)
	$(NVCC) -g -G $(MATRIX_ADDITION_GPU_SRC) -o $(MATRIX_ADDITION_GPU_TARGET)_debug

# Clean build artifacts
clean:
	rm -f $(MATRIX_MULTIPLY_TARGET) $(MATRIX_ADDITION_TARGET) $(MATRIX_ADDITION_GPU_TARGET) $(MATRIX_MULTIPLY_TARGET)_debug $(MATRIX_ADDITION_TARGET)_debug $(MATRIX_ADDITION_GPU_TARGET)_debug *.o *.cu.o

# Run the programs
run: $(MATRIX_MULTIPLY_TARGET)
	./$(MATRIX_MULTIPLY_TARGET)

run-addition: $(MATRIX_ADDITION_TARGET)
	./$(MATRIX_ADDITION_TARGET)

run-addition-gpu: $(MATRIX_ADDITION_GPU_TARGET)
	./$(MATRIX_ADDITION_GPU_TARGET)

# Run debug versions
run-debug: debug
	./$(MATRIX_MULTIPLY_TARGET)_debug
	./$(MATRIX_ADDITION_TARGET)_debug

# Run specific debug versions
run-multiply-debug: debug
	./$(MATRIX_MULTIPLY_TARGET)_debug

run-addition-debug: debug
	./$(MATRIX_ADDITION_TARGET)_debug

run-addition-gpu-debug: debug
	./$(MATRIX_ADDITION_GPU_TARGET)_debug

# Test with valgrind (if available)
valgrind: debug
	valgrind --leak-check=full ./$(MATRIX_MULTIPLY_TARGET)_debug
	valgrind --leak-check=full ./$(MATRIX_ADDITION_TARGET)_debug

# Run specific valgrind tests
valgrind-multiply: debug
	valgrind --leak-check=full ./$(MATRIX_MULTIPLY_TARGET)_debug

valgrind-addition: debug
	valgrind --leak-check=full ./$(MATRIX_ADDITION_TARGET)_debug

# Performance test
perf: $(MATRIX_MULTIPLY_TARGET) $(MATRIX_ADDITION_TARGET)
	time ./$(MATRIX_MULTIPLY_TARGET)
	time ./$(MATRIX_ADDITION_TARGET)

perf-multiply: $(MATRIX_MULTIPLY_TARGET)
	time ./$(MATRIX_MULTIPLY_TARGET)

perf-addition: $(MATRIX_ADDITION_TARGET)
	time ./$(MATRIX_ADDITION_TARGET)

# Static analysis (if cppcheck is available)
check:
	cppcheck --enable=all $(MATRIX_MULTIPLY_SRC) $(MATRIX_ADDITION_SRC)

.PHONY: all debug clean run run-addition run-debug run-multiply-debug run-addition-debug valgrind valgrind-multiply valgrind-addition perf perf-multiply perf-addition check