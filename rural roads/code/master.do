/**************************************************************************************************/
/* Create directories and set folder paths   */
/**************************************************************************************************/
gl maindir "..."  // replace with appropriate directory path
gl dodir "${maindir}/code"
gl rawdta "${maindir}/raw"
gl dtadir "${maindir}/data"
gl outdir "${maindir}/outputs"
cap mkdir "${outdir}"
gl tmp "${maindir}/tmp"
cap mkdir "${tmp}"

gl PYTHONPATH "$dodir/stata-tex" //place path to location where stata-tex folder is located

/**************************************************************************************************/
/* Install user-written programs from SSC used in scripts   */
/**************************************************************************************************/

clear all
set more off

program main
    * *** Add required packages from SSC to this list ***
    local ssc_packages "estout reghdfe ivreghdfe schemepack blindschemes binsreg coefplot ftools"
    * *** Add required packages from SSC to this list ***

    if !missing("`ssc_packages'") {
        foreach pkg in `ssc_packages' {
        * install using ssc, but avoid re-installing if already present
            capture which `pkg'
            if _rc == 111 {                 
               dis "Installing `pkg'"
               quietly ssc install `pkg', replace
               }
        }
    }

    * Install packages using net, but avoid re-installing if already present
    capture which binsreg
       if _rc == 111 {
        quietly cap ado uninstall binsreg
        quietly net install binsreg, from(https://raw.githubusercontent.com/nppackages/binsreg/master/stata)
       }
    * Install complicated packages : moremata (which cannot be tested for with which)
    capture confirm file $adobase/plus/m/moremata.hlp
        if _rc != 0 {
        cap ado uninstall moremata
        ssc install moremata
        }

end

main

* define additional programs used in analysis

do "$dodir/00_setup.do"
do "$dodir/stata-tex/stata-tex.do"


/**************************************************************************************************/
/* Scripts to replicate results 
Note: In addition to the .do files, the following R scripts generate Figure 1, F.1, and Table H.2
code/fig_maps.R
code/appendic_H_tabH2.R */
/**************************************************************************************************/

* run all scripts:
*create analysis data files
do "${dodir}/merge_analysis_files.do"

*Table 1 *
do "$dodir/main_01.do"

*Figure 2 and Tables 2,3*
do "$dodir/main_02.do"

*Figure 3 and Table 4*
do "$dodir/main_03.do"

*Figure 4 and Table 5*
do "$dodir/main_04.do"

* Appendix A *
do "$dodir/appendix_A.do"

* Appendix B *
do "$dodir/appendix_B.do"

* Appendix C *
do "$dodir/appendix_C.do"

* Appendix D *
do "$dodir/appendix_D.do"

* Appendix E *
do "$dodir/appendix_E.do"

* Appendix F *
do "$dodir/appendix_F.do"

* Appendix G *
do "$dodir/appendix_G.do"

* Appendix H *
do "$dodir/appendix_H.do"


