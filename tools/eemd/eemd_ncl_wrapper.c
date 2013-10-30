#include <ncarg/hlu/hlu.h>
#include <ncarg/hlu/NresDB.h>
#include <ncarg/ncl/defs.h>
#include <ncarg/ncl/NclDataDefs.h>
#include <ncarg/ncl/NclBuiltIns.h>
#include <ncarg/ncl/NclBuiltInSupport.h>

extern void eemd(int ns, float *s, int ne, float nr,
                 int *nm, float ***imf);

NhlErrorTypes eemd_ncl_wrapper(void) {
    /* parameter 1: original signal */
    float *s;
    int n_dims_s;
    ng_size_t dimsizes_s[NCL_MAX_DIMENSIONS];
    int has_missing_s;
    NclScalar missing_s;

    s = (float*)NclGetArgValue(
            0,
            3,
            &n_dims_s,
            dimsizes_s,
            &missing_s,
            &has_missing_s,
            NULL,
            2
        );

    if (n_dims_s != 1) {
        NhlPError(NhlFATAL, NhlEUNKNOWN,
                  "eemd: The dimension number of parameter s should be one!");
        return NhlFATAL;
    }

    /* parameter 2: ensemble number */
    int *ne;
    int n_dims_ne;
    ng_size_t dimsizes_ne[NCL_MAX_DIMENSIONS];
    
    ne = (int*)NclGetArgValue(
            1,
            3,
            &n_dims_ne,
            dimsizes_ne,
            NULL,
            NULL,
            NULL,
            2
        );

    if (n_dims_ne != 1) {
        NhlPError(NhlFATAL, NhlEUNKNOWN,
                  "eemd: The dimension number of parameter ne should be one!");
        return NhlFATAL;
    }
    if (dimsizes_ne[0] != 1) {
        NhlPError(NhlFATAL, NhlEUNKNOWN,
                  "eemd: The dimension size of parameter ne should be one!");
        return NhlFATAL;
    }

    /* parameter 3: ratio between standard deviation of noise and signal */
    float *nr;
    int n_dims_nr;
    ng_size_t dimsizes_nr[NCL_MAX_DIMENSIONS];

    nr = (float*)NclGetArgValue(
            2,
            3,
            &n_dims_nr,
            dimsizes_nr,
            NULL,
            NULL,
            NULL,
            2
        );

    if (n_dims_nr != 1) {
        NhlPError(NhlFATAL, NhlEUNKNOWN,
                  "eemd: The dimension of parameter nr should be one!");
        return NhlFATAL;
    }
    if (dimsizes_nr[0] != 1) {
        NhlPError(NhlFATAL, NhlEUNKNOWN,
                  "eemd: The dimension size of parameter nr should be one!");
        return NhlFATAL;
    }

    /* call real eemd function */
    int ns = dimsizes_s[0];
    int nm;
    float **imf;

    eemd(ns, s, *ne, *nr, &nm, &imf);

    ng_size_t dimsizes_imf[2] = { nm, ns };

    /* TODO: Figure out how to convert 2D array pointer to 1D. */
    float *tmp = malloc(sizeof(float)*nm*ns);
    for (int m = 0; m < nm; ++m) {
        for (int i = 0; i < ns; ++i) {
            tmp[m*ns+i] = imf[m][i];
        }
    }

    return NclReturnValue(
            (void*)tmp,
            2,
            dimsizes_imf,
            NULL,
            NCL_float,
            0
        );
}

void Init(void) {
    void *args;
    ng_size_t dimsizes[NCL_MAX_DIMENSIONS];
    int nargs = 0;

    args = NewArgs(3);

    SetArgTemplate(args, nargs, "float", 1, NclANY); nargs++;
    dimsizes[0] = 1;
    SetArgTemplate(args, nargs, "integer", 1, dimsizes); nargs++;
    SetArgTemplate(args, nargs, "float", 1, dimsizes); nargs++;

    NclRegisterFunc(eemd_ncl_wrapper, args, "eemd", nargs);
}
