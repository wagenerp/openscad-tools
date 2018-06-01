
module pp(pass,args) {
  if ($pp_pass==pass) {
    echo("PPbegin");
    echo(args);
    echo("PPend");
  }
}