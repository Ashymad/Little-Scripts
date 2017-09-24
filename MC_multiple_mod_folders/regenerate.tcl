#!/bin/env tclsh

puts {Regenerating mods...}

set dir [file dirname [file normalize [info script]]]
cd $dir
cd ..
set mcdir [pwd]
file delete -force mods
file mkdir mods

cd $dir
set sdirs [glob -type d *]

foreach sdir $sdirs {
    foreach item [glob -nocomplain -directory $sdir -tails *] {
	puts "mods/$item -> [file tail $dir]/$sdir/$item"
	file link $mcdir/mods/$item $dir/$sdir/$item
    }
}
