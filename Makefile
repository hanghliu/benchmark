# Compiler and flags
CXX = g++
CXXFLAGS = -std=c++11 -Wall -Wextra -O2
DEBUG_FLAGS = -g -DDEBUG
RELEASE_FLAGS = -O3 -DNDEBUG

# Target executable
TARGET = matrix_multiply

# Source files
SRC = matrix_multiply.cpp

# Default target
all: $(TARGET)

# Build the target
$(TARGET): $(SRC)
	$(CXX) $(CXXFLAGS) $(RELEASE_FLAGS) -o $(TARGET) $(SRC)

# Debug build
debug: $(SRC)
	$(CXX) $(CXXFLAGS) $(DEBUG_FLAGS) -o $(TARGET)_debug $(SRC)

# Clean build artifacts
clean:
	rm -f $(TARGET) $(TARGET)_debug *.o

# Run the program
run: $(TARGET)
	./$(TARGET)

# Run debug version
run-debug: debug
	./$(TARGET)_debug

# Test with valgrind (if available)
valgrind: debug
	valgrind --leak-check=full ./$(TARGET)_debug

# Performance test
perf: $(TARGET)
	time ./$(TARGET)

# Static analysis (if cppcheck is available)
check:
	cppcheck --enable=all $(SRC)

.PHONY: all debug clean run run-debug valgrind perf check