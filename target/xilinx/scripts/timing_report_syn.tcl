# Script to generate timing reports


#Open the project(if it is not already open)
set project $::env(PROJECT)
set current_projects [get_projects]
if { ![string equal -nocase $current_projects $project]} { #If the project is not currently open, open it
	open_project ./Work_Dir/${project}
}

#Open synthesized design
open_run synth_1

# Path to current directory
set current_directory [file normalize [pwd]]

# Create the folder to save the reports
file mkdir $current_directory/reports/synthesis

# Create and open file timing_reports.txt
set fp [open "$current_directory/reports/synthesis/timing_report.txt" w]
puts $fp "-------------------------------This file shows the timing reports generated after synthesis------------------------------"
puts $fp "-----------------------Report of the 5 worst paths whose slack is less than 0 for hold time violation analysis and setup time violation------------------"
puts $fp "\n"
puts $fp "\n"
# Close the file
close $fp

# Analyze 5 worst slacks (hold) - Slack lesser than 0
report_timing -slack_lesser_than 0 -max_paths 5 -sort_by group -hold -file "$current_directory/reports/synthesis/timing_report.txt" -append

# Analyze 5 worst slacks (setup) - Slack lesser than 0
report_timing -slack_lesser_than 0 -max_paths 5 -sort_by group -setup -file "$current_directory/reports/synthesis/timing_report.txt" -append


# Create and open file methodology__report.txt
set fp [open "$current_directory/reports/synthesis/methodology_report.txt" w]
puts $fp "-------------------------------This file shows an analysis of the design to see it if follows the UltraFast design methodology------------------------------"
puts $fp "\n"
# Close the file
close $fp

report_methodology -file "$current_directory/reports/synthesis/methodology_report.txt" -append

