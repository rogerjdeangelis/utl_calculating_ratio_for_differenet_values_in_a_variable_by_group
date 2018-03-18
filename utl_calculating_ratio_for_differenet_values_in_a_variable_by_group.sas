Calculate (number of a values in a variable)/(number of distinct names) by id;.

Same results in SAS and WPS

see github
https://tinyurl.com/ya9qqn6j
https://github.com/rogerjdeangelis/utl_calculating_ratio_for_differenet_values_in_a_variable_by_group

https://tinyurl.com/ya9qqn6j
https://communities.sas.com/t5/Base-SAS-Programming/Calculating-ratio-for-differenet-values-in-a-variable-by-group/m-p/446570


INPUT
=====

 WORK.HAVE total obs=11

  ID    NAME    VAR1

   1     a       x
   1     a       y
   1     b       y
   1     c       x
   1     c       y
   1     d       z   x_ratio=(number Xs(2))/count distinct name(4) = 2/4
                     y_ratio=(number Ys(3))/count distinct name(4) = 3/4
   2     e       x
   2     e       y
   2     f       x
   2     f       z
   2     g       z

EXAMPLE OUTPUT

  ID    X_RATIO    Y_RATIO    Z_RATIO

   1    0.50000    0.75000    0.25000
   2    0.66667    0.33333    0.66667


PROCESS
=======

proc transpose data=have out=havXpo;
  by id name;
  var var1;
  id var1;
run;quit;


/*
WORK.HAVXPO total obs=7

Obs    ID   NAME   X    Y    Z

 1      1    a     x    y
 2      1    b          y
 3      1    c     x    y
 4      1    d               z

 5      2    e     x    y
 6      2    f     x         z
 7      2    g               z
*

proc sql;
  create
    table want as
  select
    id
   ,sum(X ne "")/count(*) as x_ratio
   ,sum(Y ne "")/count(*) as y_ratio
   ,sum(Z ne "")/count(*) as z_ratio
  from
   havXpo
  group
   by id
;quit;


OUTPUT
======

 WORK.WANT total obs=2

 ID    X_RATIO    Y_RATIO    Z_RATIO

  1    0.50000    0.75000    0.25000
  2    0.66667    0.33333    0.66667

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

data have;
  input id name$ var1$;
cards4;
1 a x
1 a y
1 b y
1 c x
1 c y
1 d z
2 e x
2 e y
2 f x
2 f z
2 g z
;;;;
run;quit;
*          _       _   _ _
 ___  ___ | |_   _| |_(_|_) ___  _ __
/ __|/ _ \| | | | | __| | |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | | (_) | | | |
|___/\___/|_|\__,_|\__|_|_|\___/|_| |_|

;
proc transpose data=have out=havXpo;
  by id name;
  var var1;
  id var1;
run;quit;


/*
Up to 40 obs WORK.HAVXPO total obs=7

Obs    ID   NAME   X    Y    Z

 1      1    a     x    y
 2      1    b          y
 3      1    c     x    y
 4      1    d               z

 5      2    e     x    y
 6      2    f     x         z
 7      2    g               z
*

proc sql;
  create
    table want as
  select
    id
   ,sum(X ne "")/count(*) as x_ratio
   ,sum(Y ne "")/count(*) as y_ratio
   ,sum(Z ne "")/count(*) as z_ratio
  from
   havXpo
  group
   by id
;quit;


* WPS;
%utl_submit_wps64('
libname wrk sas7bdat "%sysfunc(pathname(work))";
proc transpose data=wrk.have out=havXpo;
  by id name;
  var var1;
  id var1;
run;quit;
proc sql;
  create
    table wrk.want as
  select
    id
   ,sum(X ne "")/count(*) as x_ratio
   ,sum(Y ne "")/count(*) as y_ratio
   ,sum(Z ne "")/count(*) as z_ratio
  from
   havXpo
  group
   by id
;quit;
run;quit;
');

