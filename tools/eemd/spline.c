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
            printf("a0[i] = %f\n", a0[i]);
            printf("a1[i] = %f\n", a1[i]);
            printf("a2[i] = %f\n", a2[i]);
            printf("b[i] = %f\n", b[i]);
            printf("a0[i+1] = %f\n", a0[i+1]);
            printf("a1[i+1] = %f\n", a1[i+1]);
            printf("a2[i+1] = %f\n", a2[i+1]);
            printf("b[i+1] = %f\n", b[i+1]);
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

    if (ni == 2) {
        /* use linear interpolation when there are only two input points */
        for (i = 0; i < no-1; ++i) {
            if (xo[i] < xi[0] || xo[i] > xi[1]) {
                printf("[Error]: cubic_spline: Use linear interpolation, "
                       "but output point is not inside the input segment!\n");
                exit(-1);
            }
            float c = (xi[1]-xo[i])/(xi[1]-xi[0]);
            yo[i] = c*yi[0]+(1.0-c)*yi[1];
        }
        return;
    }

    for (i = 0; i < ni-1; ++i) {
        h[i] = xi[i+1]-xi[i];
        if (h[i] == 0.0) {
            printf("[Error]: cubic_spline: Encounter zero interval!\n");
            for (j = 0; j < ni; ++j) {
                printf("xi[%d] = %f\n", j, xi[j]);
            }
            exit(-1);
        }
        d[i] = (yi[i+1]-yi[i])/h[i];
    }
    /* ---------------------------------------------------------------------- */
    /* calculate second order derivatives */
    /* set coefficients in internal region */
    for (i = 1; i < ni-1; ++i) {
        a0[i] = h[i-1];
        a1[i] = 2*(h[i-1]+h[i]);
        a2[i] = h[i];
        b[i] = 6*(d[i]-d[i-1]);
    }
    /* set coefficients in boundary according to not-a-knot condition */
    a0[0] = h[1];
    a1[0] = -(h[0]+h[1]);
    a2[0] = h[0];
    b[0] = 0.0;
    a0[ni-1] = h[ni-2];
    a1[ni-1] = -(h[ni-3]+h[ni-2]);
    a2[ni-1] = h[ni-3];
    b[ni-1] = 0.0;
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
        float c0 = pow(xi[j+1]-xo[i], 3)/(6.0*h[j]);
        float c1 = pow(xo[i]-xi[j], 3)/(6.0*h[j]);
        float c2 = (yi[j+1]-yi[j])/h[j]-(s[j+1]-s[j])*h[j]/6.0;
        float c3 = yi[j+1]-c2*xi[j+1]-pow(xi[j+1]-xi[j], 3)/(6.0*h[j])*s[j+1];
        yo[i] = c0*s[j]+c1*s[j+1]+c2*xo[i]+c3;
    }
    free(h); free(d); free(s);
}
