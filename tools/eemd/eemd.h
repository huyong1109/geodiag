/*!
 @function eemd
 @abstract This function calculate ensembled EMD on the given signal.
 @param ns
    [Input] The sample number of signal
 @param s
    [Input] The given signal
 @param nr
    [Input] The ratio of standard deviation of added noise and signal
 @param ne
    [Input] The ensemble number
 @param nm
    [Output] The number of intrinsic mode functions (plus original signal)
 @param imf
    [Output] The decomposed intrinsic mode functions (2d matrix)
 */

void eemd(int ns, float *s, float nr, int ne, int *nm, float **imf);
