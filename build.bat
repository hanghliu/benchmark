@echo off
echo === Building Matrix Multiplication Project ===

rem Check if g++ is available
g++ --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: g++ compiler not found. Please install MinGW or TDM-GCC.
    exit /b 1
)

echo Building release version...
g++ -std=c++11 -Wall -Wextra -O3 -DNDEBUG -o matrix_multiply.exe matrix_multiply.cpp
if errorlevel 1 (
    echo ERROR: Build failed!
    exit /b 1
)

echo Building debug version...
g++ -std=c++11 -Wall -Wextra -g -DDEBUG -o matrix_multiply_debug.exe matrix_multiply.cpp
if errorlevel 1 (
    echo ERROR: Debug build failed!
    exit /b 1
)

echo Build completed successfully!
echo.
echo Available executables:
echo   - matrix_multiply.exe (release version)
echo   - matrix_multiply_debug.exe (debug version)
echo.
echo Run the program with: matrix_multiply.exe