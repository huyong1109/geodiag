#include <stdio.h>
#include <stdlib.h>
#include <math.h>

void solve_tridiag(int n, float *a0, float *a1, float *a2, float *b, float *s) {
    float c;
    int i;
    /* ---------------------------------------------------------------------- */
    /* eliminate the lower diagonal elements a0, and update a1 and b */
    for (i = 0; i < n-1; ++i) {
        c = a0[i+1]/a1[i];
        a1[i+1] -= c*a2[i];
        if (a1[i+1] == 0.0) {
            printf("[Error]: cubic_spline: Encounter zero coefficient!\n");
            printf("i = %d\n", i);
            printf("a1[i] = %f\n", a1[i]);
            printf("a0[i+1] = %f\n", a0[i+1]);
            printf("c = a0[i+1]/a1[i] = %f\n", c);
            printf("a2[i] = %f\n", a2[i]);
            exit(-1);
        }
        b[i+1] -= c*b[i];
    }
    /* ---------------------------------------------------------------------- */
    /* eliminate the upper diagonal elements a2, and update b */
    for (i = n-1; i > 0; --i) {
        c = a2[i-1]/a1[i];
        b[i-1] -= c*b[i];
    }
    /* ---------------------------------------------------------------------- */
    /* solve s */
    for (i = 0; i < n; ++i) {
        s[i] = b[i]/a1[i];
    }
}

void cubic_spline(int ni, float *xi, float *yi, int no, float *xo, float *yo) {
    int i, j;
    float *h = malloc(sizeof(float)*(ni-1)); /* input data point spacings */
    float *d = malloc(sizeof(float)*(ni-1)); /* input data slopes */
    float *s = malloc(sizeof(float)*(ni)); /* second order derivative */
    float *a0 = malloc(sizeof(float)*ni);
    float *a1 = malloc(sizeof(float)*ni);
    float *a2 = malloc(sizeof(float)*ni);
    float *b = malloc(sizeof(float)*ni);
    float c0, c1, c2, c3;

    for (i = 0; i < ni-1; ++i) {
        h[i] = xi[i+1]-xi[i];
        d[i] = (yi[i+1]-yi[i])/h[i];
    }
    /* ---------------------------------------------------------------------- */
    /* calculate second order derivatives */
    /* set coefficients in internal region */
    for (i = 1; i < ni-1; ++i) {
        a0[i] = h[i];
        a1[i] = 2*(h[i-1]+h[i]);
        a2[i] = h[i-1];
        b[i] = 3*(h[i-1]*d[i]+h[i]*d[i-1]);
    }
    /* set coefficients in boundary according to not-a-knot condition */
    c0 = h[0]+h[1];
    a1[0] = h[1];
    a2[0] = c0;
    a0[0] = 0.0;
    b[0] = ((3*h[0]+2*h[1])*h[1]*d[0]+pow(h[0], 2)*d[1])/c0;
    c0 = h[ni-3]+h[ni-2];
    a0[ni-1] = 0.0;
    a1[ni-1] = c0;
    a2[ni-1] = h[ni-3];
    b[ni-1] = (pow(h[ni-2], 2)*d[ni-3]+(2*h[ni-3]+3*h[ni-2])*h[ni-3]*d[ni-2])/c0;
    /* solve the linear equation of second order derivative */
    solve_tridiag(ni, a0, a1, a2, b, s);
    free(a0); free(a1); free(a2); free(b);
    /* ---------------------------------------------------------------------- */
    /* interpolate */
    for (i = 0; i < no; ++i) {
        for (j = 0; j < ni-1; ++j) {
            if (xo[i] >= xi[j] && xo[i] <= xi[j+1]) {
                break;
            }
        }
        if (j == ni-1) {
            printf("[Error]: cubic_spline: Interplating point %f "
                   "is not in any data segment!\n", xo[i]);
            exit(-1);
        }
        float H = xi[j+1]-xi[j];
        float S = xo[i]-xi[j];
        float H2 = H*H;
        float H3 = H*H*H;
        float S2 = S*S;
        float S3 = S*S*S;
        float SmH = S-H;
        c1 = (3*H*S2-2*S3)/H3;
        c0 = 1-c1;
        c2 = S*SmH*SmH/H2;
        c3 = S2*SmH/H2;
        yo[i] = c0*yi[j]+c1*yi[j+1]+c2*s[j]*c3*s[j+1];
    }
    free(h); free(d); free(s);
}
