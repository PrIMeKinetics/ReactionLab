/*=================================================================
 * rxnrates.c    MEX function for ode solver
 *	     
 * The calling syntax is:
 *	[rSpe,rNet,rF,rR] = rxnrates(y,sForw,sRev,indRxn,indArr,kArr,kPres,eqK)
 *    0    1   2  3             0   1     2     3      4     5    6    7
 *     plhs[0:3]                              prhs[0:7]
 *
 * Copyright (c) 1999-2007 Michael Frenklach
 * $Last Modified January 12, 2007$
 *=================================================================*/
#include <math.h>
#include "mex.h"

/* Input Arguments */
/* #define	Y  prhs[0] */


void rates(
           double rSpe[], double rNet[], double rF[], double rR[], 
           double y[], double *sForw, double *sRev,  double *indRxn,
           double *indArr, double *kArr,  double *kPres, double *eqK,
           int nSpe, int nForw, int nRev, int nRxn, int nArr, int nPres, int nCoef
		    )
{
   int i, j, jMaxF, jMaxR, ind, indM, iCol, np, ia0, in0, ie0;
   int i2, i3, iF, iR, iRxn, indRev, indP;
   double T, lnT, ctot0, ctot, cFi, cRi, kFi,kRi, lnP, lnA, nn, E;
   double *cM;
   
   cM = mxGetPr(mxCreateDoubleMatrix(1,nRxn,mxREAL));  /* [M]-sum(coliders) */
   T = y[nSpe-1];
   lnT = log(T);
   ctot0 = 0.0;
   for (i = 0; i < nSpe-1; i++) {
      ctot0 += y[i];
      rSpe[i] = 0.0;  /* initialize species rate */
   }
   
   /* initialize array for reaction rate coefficients */
   for (i = 0; i < nRxn; i++) {
      rF[i] = 0.0;    /* will initially store sums of rate coefficients */
      cM[i] = ctot0;  /* for [M]-SUM(colliders)                         */
   }
   
   /* loop over arrhenius expressions */
   i3 = -3;
   for (i = 0; i < nArr; i++) {
      i3 += 3;
      iRxn = *(indArr + i3 + 2) + 0.1;
      kFi = exp(*(kArr+i3) + *(kArr+i3+1) * lnT - *(kArr+i3+2)/T);
      /* check on conc-dependence */
      indM = *(indArr + i3) + 0.1;
      if (indM == 0) {          /* mass action - no third-body collisions */
         rF[iRxn-1] += kFi;
      } else {                  /* third-body collision */   
         iCol = *(indArr + i3 + 1) + 0.1;
         if (iCol == 0) {       /* last record: collider = 'M' */
            rF[iRxn-1] += kFi * cM[iRxn-1];
         } else {
            rF[iRxn-1] += kFi * y[iCol-1];     /*   k*collider */
            cM[iRxn-1] -=       y[iCol-1];     /* [M]-collider */
         }
      }
   }

   /* loop over the reactions again - calculate reaction rates */
   np = nCoef/3;
   i2 = -2; i3 = -3;
   iF = -nForw; iR = -nRev;
   for (i = 0; i < nRxn; i++) {
      i3 += 3;
      /* concentration product for the forward direction */
		iF += nForw;  cFi = 1.0;
      jMaxF = *(sForw + iF) + 0.1;    /* convert from double to int */
      for (j = 1; j <= jMaxF; j++) {
         ind = *(sForw + iF + j) + 0.1;
         cFi *= y[ind - 1];
      }
      /* concentration product for the reverse direction */
      iR += nRev;  cRi = 1.0;
      jMaxR = *(sRev + iR) + 0.1;
      i2 += 2;
      indRev = *(indRxn + i2) + 0.1;
		if ( indRev == 1 ) {              /* skip if irreversible */
         for (j = 1; j <= jMaxR; j++) {
            ind = *(sRev + iR + j) + 0.1;
            cRi *= y[ind - 1];
			}
      }
      /* if reaction is unimolecular or chemical-activation type */
      indP = *(indRxn + i2 + 1) + 0.1;
      if (indP != 0) {
         ctot = rF[i] + cM[i];     /* adjusted total concentration */
         lnP = log(ctot) + 4.40733 + lnT;   /* 4.40733 = ln(82.05) */
         ia0 = (indP - 1) * nCoef;
         in0 = ia0 + np;
         ie0 = in0 + np;
         lnA = *(kPres + ia0);
         nn  = *(kPres + in0);
         E   = *(kPres + ie0);     
         for (j = 1; j < np; j++) {       /* np = nCoef/3 */
            lnA = lnA * lnP + *(kPres + ia0 + j);
            nn  =  nn * lnP + *(kPres + in0 + j);
            E   =   E * lnP + *(kPres + ie0 + j);
         }
         kFi = exp(lnA + nn*lnT - E/T);
         rF[i] = kFi * cFi;
      } else {
         kFi = rF[i];
         rF[i] *= cFi;
      }
      
      /* rate of the reverse direction */
      if ( indRev == 0 ) {
		   rR[i] = 0.0;           /* if reaction is irreversible */
		} else {
		   kRi = kFi/exp(*(eqK+i3) + *(eqK+i3+1) * lnT - *(eqK+i3+2)/T);
		   rR[i] = kRi * cRi;
      }
      
      /* net reaction rate  */
	   rNet[i] = rF[i] - rR[i];
      
      /* species rates */
      for (j = 1; j <= jMaxF; j++) {
         ind = *(sForw + iF + j) + 0.1;
         rSpe[ind-1] -= rNet[i];
      }
      for (j = 1; j <= jMaxR; j++) {
         ind = *(sRev + iR + j) + 0.1;
         rSpe[ind-1] += rNet[i];
      }
   }
   return;
}

void mexFunction( int nlhs, mxArray *plhs[], 
		            int nrhs, const mxArray *prhs[] )
{
    double *rSpe, *rNet, *rF, *rR;
    double *kArr, *indArr, *kPres, *eqK;
    double *y, *sForw, *sRev, *indRxn;
    int nSpe, nForw, nRev, nRxn, nArr, nPres, nCoef;
    
  /* Check for proper number of arguments */
    if (nrhs != 8) { 
	   mexErrMsgTxt("Incorrect number of input arguments"); 
    }
    
  /* Get the dimensions */
    nSpe  = mxGetM(prhs[0]);    /* length of y  (# rows)     */
    nForw = mxGetM(prhs[1]);    /* dimension of reactants    */
    nRev  = mxGetM(prhs[2]);    /* dimension of products     */
    nRxn  = mxGetN(prhs[3]);    /* No. of reactions          */
    nArr  = mxGetN(prhs[4]);    /* length of arrhenius array */
    nPres = mxGetN(prhs[6]);    /* No. of P-depnd reactions  */
    nCoef = mxGetM(prhs[6]);    /* No. of coefficients       */
   
    
  /* Create arrays for the return arguments */ 
    plhs[0] = mxCreateDoubleMatrix(nSpe,1,mxREAL);
    plhs[1] = mxCreateDoubleMatrix(nRxn,1,mxREAL);
    plhs[2] = mxCreateDoubleMatrix(nRxn,1,mxREAL);
    plhs[3] = mxCreateDoubleMatrix(nRxn,1,mxREAL);
    
    
  /* Assign pointers to the various parameters */ 
    rSpe = mxGetPr(plhs[0]);
    rNet = mxGetPr(plhs[1]);
    rF   = mxGetPr(plhs[2]);
    rR   = mxGetPr(plhs[3]);
    
    y      = mxGetPr(prhs[0]);
    sForw  = mxGetPr(prhs[1]);
    sRev   = mxGetPr(prhs[2]);
    indRxn = mxGetPr(prhs[3]);
    indArr = mxGetPr(prhs[4]);
    kArr   = mxGetPr(prhs[5]);
    kPres  = mxGetPr(prhs[6]);
    eqK    = mxGetPr(prhs[7]);
        
    
  /* perform calculations */
    rates(rSpe,rNet,rF,rR,
          y,sForw,sRev,indRxn,
          indArr,kArr,kPres,eqK,
          nSpe,nForw,nRev,nRxn,nArr,nPres,nCoef);
    
    return;
}