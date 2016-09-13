#include "FFT.h"
#include <math.h>
#include <string.h>
#include <new>

#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "fft.h"


// Private function prototypes
static int reverse_bits(int x, unsigned int n);
static void *memdup(const void *src, int n);

#define SIZE_MAX ((int)-1)


int transform(double real[], double imag[], int n) {
    if (n == 0)
        return 1;
    else if ((n & (n - 1)) == 0)  // Is power of 2
        return transform_radix2(real, imag, n);
    else  // More complicated algorithm for arbitrary sizes
        return transform_bluestein(real, imag, n);
}


int inverse_transform(double real[], double imag[], int n) {
    return transform(imag, real, n);
}


int transform_radix2(double real[], double imag[], int n) {
    // Variables
    int status = 0;
    unsigned int levels;
    double *cos_table, *sin_table;
    int size;
    int i;
    
    // Compute levels = floor(log2(n))
    {
        int temp = n;
        levels = 0;
        while (temp > 1) {
            levels++;
            temp >>= 1;
        }
        if (1u << levels != n)
            return 0;  // n is not a power of 2
    }
    
    // Trignometric tables
    if (SIZE_MAX / sizeof(double) < n / 2)
        return 0;
    size = (n / 2) * sizeof(double);
    cos_table = (double*)malloc(size);
    sin_table = (double*)malloc(size);
    if (cos_table == NULL || sin_table == NULL)
        goto cleanup;
    for (i = 0; i < n / 2; i++) {
        cos_table[i] = cos(2 * M_PI * i / n);
        sin_table[i] = sin(2 * M_PI * i / n);
    }
    
    // Bit-reversed addressing permutation
    for (i = 0; i < n; i++) {
        int j = reverse_bits(i, levels);
        if (j > i) {
            double temp = real[i];
            real[i] = real[j];
            real[j] = temp;
            temp = imag[i];
            imag[i] = imag[j];
            imag[j] = temp;
        }
    }
    
    // Cooley-Tukey decimation-in-time radix-2 FFT
    for (size = 2; size <= n; size *= 2) {
        int halfsize = size / 2;
        int tablestep = n / size;
        for (i = 0; i < n; i += size) {
            int j;
            int k;
            for (j = i, k = 0; j < i + halfsize; j++, k += tablestep) {
                double tpre =  real[j+halfsize] * cos_table[k] + imag[j+halfsize] * sin_table[k];
                double tpim = -real[j+halfsize] * sin_table[k] + imag[j+halfsize] * cos_table[k];
                real[j + halfsize] = real[j] - tpre;
                imag[j + halfsize] = imag[j] - tpim;
                real[j] += tpre;
                imag[j] += tpim;
            }
        }
        if (size == n)  // Prevent overflow in 'size *= 2'
            break;
    }
    status = 1;
    
cleanup:
    free(cos_table);
    free(sin_table);
    return status;
}


int transform_bluestein(double real[], double imag[], int n) {
    // Variables
    int status = 0;
    double *cos_table, *sin_table;
    double *areal, *aimag;
    double *breal, *bimag;
    double *creal, *cimag;
    int m;
    int size_n, size_m;
    int i;
    
    // Find a power-of-2 convolution length m such that m >= n * 2 + 1
    {
        int target;
        if (n > (SIZE_MAX - 1) / 2)
            return 0;
        target = n * 2 + 1;
        for (m = 1; m < target; m *= 2) {
            if (SIZE_MAX / 2 < m)
                return 0;
        }
    }
    
    // Allocate memory
    if (SIZE_MAX / sizeof(double) < n || SIZE_MAX / sizeof(double) < m)
        return 0;
    size_n = n * sizeof(double);
    size_m = m * sizeof(double);
    cos_table = (double*)malloc(size_n);
    sin_table = (double*)malloc(size_n);
    areal = (double*)calloc(m, sizeof(double));
    aimag = (double*)calloc(m, sizeof(double));
    breal = (double*)calloc(m, sizeof(double));
    bimag = (double*)calloc(m, sizeof(double));
    creal = (double*)malloc(size_m);
    cimag = (double*)malloc(size_m);
    if (cos_table == NULL || sin_table == NULL
        || areal == NULL || aimag == NULL
        || breal == NULL || bimag == NULL
        || creal == NULL || cimag == NULL)
        goto cleanup;
    
    // Trignometric tables
    for (i = 0; i < n; i++) {
        double temp = M_PI * (int)((unsigned long long)i * i % ((unsigned long long)n * 2)) / n;
        // Less accurate version if long long is unavailable: double temp = M_PI * i * i / n;
        cos_table[i] = cos(temp);
        sin_table[i] = sin(temp);
    }
    
    // Temporary vectors and preprocessing
    for (i = 0; i < n; i++) {
        areal[i] =  real[i] * cos_table[i] + imag[i] * sin_table[i];
        aimag[i] = -real[i] * sin_table[i] + imag[i] * cos_table[i];
    }
    breal[0] = cos_table[0];
    bimag[0] = sin_table[0];
    for (i = 1; i < n; i++) {
        breal[i] = breal[m - i] = cos_table[i];
        bimag[i] = bimag[m - i] = sin_table[i];
    }
    
    // Convolution
    if (!convolve_complex(areal, aimag, breal, bimag, creal, cimag, m))
        goto cleanup;
    
    // Postprocessing
    for (i = 0; i < n; i++) {
        real[i] =  creal[i] * cos_table[i] + cimag[i] * sin_table[i];
        imag[i] = -creal[i] * sin_table[i] + cimag[i] * cos_table[i];
    }
    status = 1;
    
    // Deallocation
cleanup:
    free(cimag);
    free(creal);
    free(bimag);
    free(breal);
    free(aimag);
    free(areal);
    free(sin_table);
    free(cos_table);
    return status;
}


int convolve_real(const double x[], const double y[], double out[], int n) {
    double *ximag, *yimag, *zimag;
    int status = 0;
    ximag = (double*)calloc(n, sizeof(double));
    yimag = (double*)calloc(n, sizeof(double));
    zimag = (double*)calloc(n, sizeof(double));
    if (ximag == NULL || yimag == NULL || zimag == NULL)
        goto cleanup;
    
    status = convolve_complex(x, ximag, y, yimag, out, zimag, n);
cleanup:
    free(zimag);
    free(yimag);
    free(ximag);
    return status;
}


int convolve_complex(const double xreal[], const double ximag[], const double yreal[], const double yimag[], double outreal[], double outimag[], int n) {
    int status = 0;
    int size;
    int i;
    double *xr, *xi, *yr, *yi;
    if (SIZE_MAX / sizeof(double) < n)
        return 0;
    size = n * sizeof(double);
    xr = (double*)memdup(xreal, size);
    xi = (double*)memdup(ximag, size);
    yr = (double*)memdup(yreal, size);
    yi = (double*)memdup(yimag, size);
    if (xr == NULL || xi == NULL || yr == NULL || yi == NULL)
        goto cleanup;
    
    if (!transform(xr, xi, n))
        goto cleanup;
    if (!transform(yr, yi, n))
        goto cleanup;
    for (i = 0; i < n; i++) {
        double temp = xr[i] * yr[i] - xi[i] * yi[i];
        xi[i] = xi[i] * yr[i] + xr[i] * yi[i];
        xr[i] = temp;
    }
    if (!inverse_transform(xr, xi, n))
        goto cleanup;
    for (i = 0; i < n; i++) {  // Scaling (because this FFT implementation omits it)
        outreal[i] = xr[i] / n;
        outimag[i] = xi[i] / n;
    }
    status = 1;
    
cleanup:
    free(yi);
    free(yr);
    free(xi);
    free(xr);
    return status;
}


static int reverse_bits(int x, unsigned int n) {
    int result = 0;
    unsigned int i;
    for (i = 0; i < n; i++, x >>= 1)
        result = (result << 1) | (x & 1);
    return result;
}


static void *memdup(const void *src, int n) {
    void *dest = malloc(n);
    if (dest != NULL)
        memcpy(dest, src, n);
    return dest;
}