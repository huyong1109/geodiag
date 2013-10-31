#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <time.h>
#include <ncarg/ngmath.h>

float randn()
{
    float U1, U2, W, mult;
    static float X1, X2;
    static int call = 0;

    if (call == 1)
    {
        call = !call;
        return X2;
    }

    do {
        U1 = -1+((float)rand()/RAND_MAX)*2;
        U2 = -1+((float)rand()/RAND_MAX)*2;
        W = pow(U1, 2)+pow(U2, 2);
    } while (W >= 1 || W == 0);

    mult = sqrt((-2*log(W))/W);
    X1 = U1*mult;
    X2 = U2*mult;

    call = !call;
    return X1;
}

/*!
 @function emd
 @abstract This function does EMD on the given signal.
 @param ns
    [Input] The sample number of the signal
 @param s
    [Input] The given signal
 @param nm
    [Output] The actual number of intrinsic mode functions
 @param imf
    [Output] The decomposed intrinsic mode functions (2d matrix)
    [Note]: Assume the first column has already been filled with s.
 */

void emd(int ns, float *s, int nm, float *imf) {
    int numMax, numMin, ret, i, m, iter;
    const int numIter = 10;
    float *max = malloc(sizeof(float)*ns);
    float *maxLoc = malloc(sizeof(float)*ns);
    float *min = malloc(sizeof(float)*ns);
    float *minLoc = malloc(sizeof(float)*ns);
    float *maxEnv = malloc(sizeof(float)*ns);
    float *minEnv = malloc(sizeof(float)*ns);
    float *x = malloc(sizeof(float)*ns); /* coordinates for spline */
    float *y = malloc(sizeof(float)*ns); /* working variable */
    float *r = malloc(sizeof(float)*ns); /* residual signal */

    for (i = 0; i < ns; ++i) {
        x[i] = (float)i;
        r[i] = s[i];
    }

    for (m = 1; m < nm-1; ++m) {
        for (i = 0; i < ns; ++i) {
            y[i] = r[i];
        }
        /* TODO: Some comments on iteration here! */
        for (iter = 0; iter < numIter; ++iter) {
            /* -------------------------------------------------------------- */
            /* find out the local extrema */
            /* NOTE: The first and last samples are considered as extrema. */
            numMax = 1; numMin = 1;
            max[0] = y[0]; maxLoc[0] = 0.0;
            min[0] = y[0]; minLoc[0] = 0.0;
            for (i = 1; i < ns-1; ++i) {
                if (y[i] > y[i-1] && y[i] > y[i+1]) {
                    max[numMax] = y[i]; maxLoc[numMax] = (float)i; numMax++;
                } else if (y[i] < y[i-1] && y[i] < y[i+1]) {
                    min[numMin] = y[i]; minLoc[numMin] = (float)i; numMin++;
                }
            }
            max[numMax] = y[ns-1]; maxLoc[numMax] = (float)(ns-1);
            min[numMin] = y[ns-1]; minLoc[numMin] = (float)(ns-1);
            numMax++; numMin++;
            /* -------------------------------------------------------------- */
            /* calculate cubic spline of the envelope */
            c_ftsetr("sig", 0.0);
            ret = c_ftcurv(numMax, maxLoc, max, ns, x, maxEnv);
            if (ret != 0) {
                printf("Error: c_ftcurv return %d for maxima!\n", ret);
                exit(-1);
            }
            ret = c_ftcurv(numMin, minLoc, min, ns, x, minEnv);
            if (ret != 0) {
                printf("Error: c_ftcurv return %d for minima!\n", ret);
                exit(-1);
            }
            /* -------------------------------------------------------------- */
            /* calculate the difference between envelope mean and signal */
            for (i = 0; i < ns; ++i) {
                y[i] -= (maxEnv[i]+minEnv[i])*0.5;
            }
        }
        /* ------------------------------------------------------------------ */
        /* calculate the intrinsic mode function and residue */
        for (i = 0; i < ns; ++i) {
            imf[m*ns+i] = y[i];
            r[i] -= y[i];
        }
    }
    /* ---------------------------------------------------------------------- */
    /* record the residual */
    for (i = 0; i < ns; ++i) {
        imf[(nm-1)*ns+i] = r[i];
    }

    free(max); free(maxLoc); free(maxEnv);
    free(min); free(minLoc); free(minEnv);
    free(x); free(y); free(r);
}

/*!
 @function eemd
 @abstract This function calculate ensembled EMD on the given signal.
 @param ns
    [Input] The sample number of signal
 @param s
    [Input] The given signal
 @param ne
    [Input] The ensemble number
 @param nr
    [Input] The ratio of standard deviation of added noise and signal
 @param nm
    [Output] The number of intrinsic mode functions (plus original signal)
 @param imf
    [Output] The decomposed intrinsic mode functions (2d matrix)
 */

void eemd(int ns, float *s, int ne, float nr, int *nm, float **imf) {
    int i, m, e;
    /* ---------------------------------------------------------------------- */
    /* turn standard deviation of signal to one */
    float mean, sd;
    mean = 0.0;
    for (i = 0; i < ns; ++i) {
        mean += s[i];
    }
    mean /= ns;
    sd = 0.0;
    for (i = 0; i < ns; ++i) {
        sd += pow(s[i]-mean, 2);
    }
    sd = sqrt(sd/(ns-1));
    for (i = 0; i < ns; ++i) {
        s[i] /= sd;
    }
    /* ---------------------------------------------------------------------- */
    /* allocate memory for results */
    /* NOTE: The first column is the original signal */
    *nm = (int)(log2(ns))-1+2;
    *imf = calloc((*nm)*ns, sizeof(float));
    /* ---------------------------------------------------------------------- */
    /* run ensemble and add white-noise */
    for (e = 0; e < ne; ++e) {
        float *se = malloc(sizeof(float)*ns);
        float *imfe = malloc(sizeof(float)*(*nm)*ns);
        /* add white-noise to original signal */
        srand(time(NULL));
        for (i = 0; i < ns; ++i) {
            se[i] = s[i]+nr*randn();
            /* record the original signal into the first column */
            imfe[i] = s[i];
        }
        /* call EMD */
        emd(ns, se, *nm, imfe);
        /* accumulate results */
        for (m = 0; m < *nm; ++m) {
            for (i = 0; i < ns; ++i) {
                (*imf)[m*ns+i] += imfe[m*ns+i];
            }
        }
        free(se); free(imfe);
    }
    /* ---------------------------------------------------------------------- */
    /* convert signal and IMFs back */
    for (i = 0; i < ns; ++i) {
        s[i] *= sd;
    }
    for (m = 0; m < *nm; ++m) {
        for (i = 0; i < ns; ++i) {
            (*imf)[m*ns+i] *= sd/ne;
        }
    }
}
