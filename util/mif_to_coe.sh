NAME=program

#File containing the memory initialization data
file_from="${NAME}.mif"

# Check if the file exists
if [ ! -f "$file_from" ]; then
    echo "File not found: $file_from"
    #exit 1
    
fi


#This part generates the .coe file
#File to be written
file_to="memory_initialization_${NAME}.coe"
# Check if the file exists. If not, create it
if [ ! -f "$file_to" ]; then
    touch memory_initialization_${NAME}.coe
fi

#Delete current values of the coe file
echo -n "" > "$file_to"


#Copy the values from the mif file into the coe file
sed 's/.*://g' "$file_from" >> "$file_to"

# Delete useless lines of the .mif
sed -i "1,14d" "$file_to" 

#Modify the header accordingly
search_text="DATA_RADIX=HEX;"
replace_text="MEMORY_INITIALIZATION_RADIX=16;"
sed -i "s/$search_text/$replace_text/g" "$file_to"

search_text="CONTENT BEGIN"
replace_text="MEMORY_INITIALIZATION_VECTOR="
sed -i "s/$search_text/$replace_text/g" "$file_to"

#Change semicolon for comma
search_text=";"
replace_text=","
sed -i "s/$search_text/$replace_text/g" "$file_to"

#Delete the last line of the file
sed -i '$d' "$file_to"

#Modify the new last element because it should have a semicolon instead of a comma
# Search and replace the last occurrence of ',' with ';'
sed -i '$s/,/;/' "$file_to"
# Search and replace the first occurrence of ',' with ';'
sed -i '1s/,/;/' "$file_to"











