Calculate (number of a values in a variable)/(number of distinct names) by id;.

Same results in SAS and WPS

also see Paul Dorfmans response on the end of this message

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
   
   
   
   *____             _
|  _ \ __ _ _   _| |
| |_) / _` | | | | |
|  __/ (_| | |_| | |
|_|   \__,_|\__,_|_|

;

Re: SAS Forum: Calculate (number of a values in a variable)/(number of distinct names) by id;.
From:
Paul Dorfman <sashole@BELLSOUTH.NET>
Reply-To:
Paul Dorfman <sashole@BELLSOUTH.NET>
Date:
Mon, 19 Mar 2018 23:37:18 -0400

Roger,

In general, I agree with your take on it, I'd rather reverse the transposition
and aggregation and eliminate hard coding for better robustness, e.g.:

data have;
  input id name$ var1$;
cards;
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
;
run;

proc sql noprint ;
  create table aggr as
  select a.ID, divide(qv, qn) as _r, var1 as _v
  from   (select ID, count(distinct name) as qn from have group 1) a
       , (select ID, var1, count(*) as qv from have group 1, 2) b
  where  a.ID = b.ID ;
  select distinct (catx('_',_v,'ratio')) into :ratios separated by " " from aggr order 1 ;
quit ;

data want (drop = _:) ;
  do until (last.ID) ;
    set aggr ;
    by  ID ;
    array arr &ratios ;
    do over arr ;
      if compare(vname(arr),_v) > 1 then arr = _r ;
    end ;
  end ;
run ;

OTOH, using a combo of a hash and call execute, this can also be managed in one step (though two are actually executed, anyway):

data aggr (drop = name q:) ;
  if _n_ = 1 then do ;
    dcl hash h() ;
    h.definekey ('_v') ;
    h.definedata ('_v', 'qv') ;
    h.definedone () ;
    dcl hiter i ("h") ;
    dcl hash v() ;
    v.definekey ('_v') ;
    v.definedone () ;
    call execute ("data want(drop=_:);do until(last.id);set aggr; by id;array arr") ;
  end ;
  if end then call execute (";do over arr;if compare(vname(arr),_v)>1 then arr=_r;end;end;run;") ;
  do until (last.id) ;
    set have (rename=(var1=_v)) end = end ;
    by id name ;
    qn = sum (qn, first.name) ;
    if h.find() ne 0 then qv = 1 ;
    else qv = qv + 1 ;
    h.replace() ;
    if v.check() = 0 then continue ;
    call execute (catx ("_", _v, "ratio")) ;
    v.add() ;
  end ;
  do while (i.next() = 0) ;
    _r = divide (qv, qn) ;
    output ;
  end ;
  h.clear() ;
run ;

Best
Paul Dorfman



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

