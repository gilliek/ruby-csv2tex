#!/usr/bin/env ruby

=begin
	                  ____  _
      ___ _____   _|___ \| |_ _____  __
     / __/ __\ \ / / __) | __/ _ \ \/ /
    | (__\__ \\ V / / __/| ||  __/>  <
     \___|___/ \_/ |_____|\__\___/_/\_\

	Simple tool for converting CSV table to LaTeX table.

	Copyright (c) 2012, Kevin Gillieron <kevin.gillieron@gw-computing.net>
	All rights reserved.

	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions
	are met:

	1. Redistributions of source code must retain the above copyright
		 notice, this list of conditions and the following disclaimer.
	2. Redistributions in binary form must reproduce the above copyright
		 notice, this list of conditions and the following disclaimer in the
		 documentation and/or other materials provided with the distribution.
	4. Neither the name of the author nor the names of its contributors
		 may be used to endorse or promote products derived from this software
		 without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
	ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
	FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
	DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
	OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
	HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
	LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
	OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
	SUCH DAMAGE.
=end

### CONFIGURATION #############################################################
LATEX_TABLE_OPEN  = %Q{\\begin{table}[h]
	\\begin{ruledtabular}
		\\begin{tabular}{%s}}
LATEX_TABLE_CLOSE = %Q{		\\end{tabular}
	\\end{ruledtabular}
\\end{table}}
# LATEX_ROW_SEP     = "\\hline"
LATEX_ROW_SEP     = "\\hline"
LATEX_COL_ALIGN   = "c"
###############################################################################

module Utils
	class Logger
		@@verbose = false

		# enable verbose mode
		def self.enable
			@@verbose = true
		end

		# disable verbose mode
		def self.disable
			@@verbose = false
		end

		# display a given message into the stdout
		def self.write(mess="")
			puts mess if @@verbose
		end

		# display a given message into the stderr
		def self.warn(mess="")
			STDERR.puts mess if @@verbose
		end
	end
end

include Utils

module Csv2Tex
	DEFAULT_SEP = ","  # default column separator
	DEFAULT_STR = ""   # default character that surrounds string

	def convert(filename, sep, str, output="")
		out    = (output.empty?) ? STDOUT : open_output(output)
		csv    = File.open(filename)
		i      = 1
		regexp = Regexp.new("^#{str}.*#{str}$") unless str.empty?

		# verbose message
		Logger.write("VERBOSE: Converting the CSV using the following paramters :")
		Logger.write("\tCSV separator: #{sep}")
		Logger.write("\tCSV string delimiter: #{str}")
		Logger.write("\tOutput: #{(output.empty?) ? "stdout" : output}")

		csv.each do |line|
			# verbose message
			Logger.write("VERBOSE: Processing the line #{i}")
			Logger.write("\t#{line}")

			# don't really know why I need to create a regexp to make it works...
			columns = line.split(Regexp.new(sep))
			columns.each { |e| e.gsub!(str, "") if e =~ regexp } unless str.empty?

			# verbose message
			Logger.write("VERBOSE: Writing the LaTeX table starting tag") if i == 1

			# write the starting tag if first iter
			out.puts LATEX_TABLE_OPEN % [gen_align(columns.length)] if i == 1

			# write the table row
			out.puts columns.join(" & ")

			# write the new line LaTeX symbol
			out.puts "\\\\"
			out.puts LATEX_ROW_SEP unless LATEX_ROW_SEP.empty?

			# increment line counter
			i += 1
		end

		# verbose message
		Logger.write("VERBOSE: Writing the LaTeX table closing tag")
		out.puts LATEX_TABLE_CLOSE

		out.close unless output.empty?
		csv.close

		puts "The CSV has been successfuly converted to LaTeX !"
	end

	private
		def open_output(output)
			# verbose message
				Logger.write("VERBOSE: Verifying that the outpute file does " +
				             "not already exist")

			if File.exists?(output)
				print "The ouput file already exists. " +
				      "Would you like to overwrite it ? (y/n) "
				answer = gets.gsub("\n", "")

				# verbose message
				Logger.write("VERBOSE: Received a positive answer, then continue the " +
				             "program execution") if answer == "y"
				Logger.write("VERBOSE: Received a negative answer, then the program " +
										 "will stop") if answer != "y"

				exit unless answer == "y"
			end

			return File.open(output, "w+")
		end

		def gen_align(num_cols)
			tmp = Array.new
			num_cols.times { tmp << LATEX_COL_ALIGN }
			return tmp.join(" ")
		end
end

require 'optparse'

include Csv2Tex

begin
	sep = DEFAULT_SEP
	str = DEFAULT_STR
	out = ""

	# Parse options
	opts = OptionParser.new do |o|
    o.banner = "usage: #{File.basename $0} [options] [csv_file]\n"
    o.separator(nil)
    o.separator "options:"
    o.on("-h", "--help", "show this help") { puts o ; exit }
    o.on("-s", "--separator COLUMN_SEPARATOR", String,
				 "Set the CSV column separator. The default separator is a coma ' , '") do |value|
			sep = value
		end
    o.on("-d", "--delimiter STRING_DELIMITER", String,
				 "Set the CSV string delimiter. By default there is no string " +
				 "delimiter") do |value|
			str = value
		end
		o.on("-o", "--output OUTPUT", String,
				 "if you don't sepecify an output file, the converted CSV will be " +
				 "display in stdout") do |value|
			out = value
    end
    o.on("-v", "--verbose", "enable verbose mode") do
			Logger.enable

			# verbose message
			Logger.write("VERBOSE: verbose mode enabled")
		end
  end
  opts.parse!

	if ARGV.length != 1
		STDERR.puts "Invalid # of arguments !"
		STDERR.puts "See '#{File.basename $0} -h' for further details !"
		exit 1
	end

	# get the csv filename
	csv = ARGV.pop

	# convert the csv into LaTeX file !
	Csv2Tex.convert(csv, sep, str, out)
end

# vim: set ts=2 sw=2 noet:
