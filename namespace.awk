{ 
	# Store each line in lines at # NR
	lines[NR] = $0 
} 

# For each line that starts with Namespace:
($0 ~ /^Namespace:/) { 
	# Product is stored 4 lines before namespace
	product   = lines[NR-4];
	# Namespace is substring of line starting at 2 characters after :
	namespace = substr($0,index($0,":")+2);
	print product "\t" namespace
}
