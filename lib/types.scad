visicut_scale=195.856/51.953*195.856/208.52;
inkscape_scale=100/26.458;

function subvec(v,len,start=0) = [ for(i=[start:1:start+len-1]) v[i] ];

function lookups(a,b,i=0) =
  (!(i<len(b))||(b==undef)) ? undef : (
    (b[i][0]==a) ? b[i][1] : lookups(a,b,i+1)
  );

