#Script to add the .mem files to VIVADO
set current_directory [file normalize [pwd]]
puts $current_directory

# File type to search for
set file_type_pattern "*.mem"

# Use glob to search for files matching the pattern in the directory
set file_list [glob -nocomplain -directory $current_directory/util $file_type_pattern]

# Print the list of matching files and add it to VIVADO
foreach file $file_list {
    puts "Found file: $file"
    add_files -norecurse $file
}