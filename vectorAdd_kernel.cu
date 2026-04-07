// SPDX-License-Identifier: MPL-2.0

/**
 * CUDA Kernel Device code
 *
 * Computes the vector addition of A and B into C. The 3 vectors have the same
 * number of elements numElements.
 */

extern "C" __global__ void vectorAdd(const float *A, const float *B, float *C,
                                     int numElements) {
  int i = blockDim.x * blockIdx.x + threadIdx.x;

  if (i < numElements) {
    C[i] = A[i] + B[i];
  }
}
