# Shell escape is disabled on purpose: the manuscript uses no package that needs
# a TeX subprocess (see docs/testing.md, "TeX subprocesses"), and untrusted
# manuscript text must not be able to run commands during a build.
$pdflatex = 'pdflatex -no-shell-escape %O %S';
$lualatex = 'lualatex -no-shell-escape %O %S';
$xelatex  = 'xelatex -no-shell-escape %O %S';
