README
======

csv2tex is simple tool for converting CSV file to LaTeX table.

INSTALL
-------

Simply copy the script into one of your *bin/* folder. For example :

      $ git clone https://github.com/gilliek/ruby-csv2tex.git
      $ cd ruby-csv2tex
      $ sudo cp csv2tex.rb /usr/local/bin/csv2tex

Make sure that your *bin/* folder is in *$PATH*

HOW TO USE IT
-------------

Well...

      $ csv2tex -h

CONFIGURATION
-------------

You can easily change the LaTeX table tag by editing the "CONFIGURATION" 
section at the begining of the script (after the license). Make sure that 
you have escaped the "\" like this "\\\\" because Ruby interpret the "\".
