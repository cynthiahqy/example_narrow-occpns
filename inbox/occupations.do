/*use "C:\Users\binder\Dropbox\brett folders\Census 2015\Unit Record Data files\merged data.dta", clear*/
/* merged data occupation*/
/* professional, manager, teacher, assprofclerk, svcsales, armforces, 
xefe, farmer, craftrademach, labourer, driver, notclass */

gen farmer=0
replace farmer=1 if occupn>6000 & occupn<7000
gen teacher=0
replace teacher=1 if occupn>2400 & occupn<2500
gen professional=0
replace professional=1 if occupn>2000 & occupn<3000 & teacher==0
gen manager=0
replace manager=1 if occupn>1000 & occupn<1129
replace manager=1 if occupn>1131 & occupn<2000
gen armforces=0
replace armforces=1 if occupn<200 
gen xefe=0
replace xefe=1 if occupn==1130
gen assprofclerk=0
replace assprofclerk=1 if occupn>3000 & occupn<5000
gen svcsales=0
replace svcsales=1 if occupn>5000 & occupn<6000
replace svcsales=1 if occupn>9000 & occupn<9200
gen labourer=0
replace labourer=1 if occupn>9200 & occupn<9320
gen driver=0
replace driver=1 if occupn>8320 & occupn<8330
replace driver=1 if occupn>9330 & occupn<9340
gen craftrademach=0
replace craftrademach=1 if occupn>7000 & occupn<9000 & driver==0
gen notclass=0
replace notclass=1 if occupn>9990 & occupn<10000

sum professional manager teacher assprofclerk svcsales armforces xefe farmer craftrademach labourer driver notclass if p3p30_school_level==6
