# Run w32tm /query /source and capture the output
$source = w32tm /query /source

# Check if the output contains the word "CMOS"
if ($source -match "CMOS") {
    # Exit with code 1 if CMOS is found
    exit 1
} else {
    # Exit with code 0 if CMOS is not found
    exit 0
}