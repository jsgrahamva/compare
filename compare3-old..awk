# Process Monograph and other files
# 20210924-1619: Adding namespace logic!
#
# awk -f compare3.awk namespace.txt ./source-files/*
#
# Determine degree of equivalence between 2 product names
#
function equiv(productName1,productName2, arr1, arr2, i, len1, len2, max, min, n1, n2, pos) {
	len1 = index(productName1,": ");
	len2 = index(productName2,": ");
	if (len1) {
		if (len2) {
			if (substr(productName1,1,len1) == substr(productName2,1,len2)) {
				split(substr(productName1,len1+2),arr1);
				split(substr(productName2,len2+2),arr2);
				if (arr1[1] != arr2[1]) {
					return 0
				}
			}
		}
		else {
			return 0
		}
	}
	else {
		if (len2) {
			return 0
		}
	}
	n1 = split(productName1,arr1);
	n2 = split(productName2,arr2);
	min = (n1 > n2) ? n2 : n1;
	for (i = 1; i <= min; i++) {
		if (arr1[i] != arr2[i]) return 0
	}
	
	len1 = length(productName1);
	len2 = length(productName2);
	max  = (len1 > len2) ? len1 : len2;
	pos  = 0;
	for (i = 1; i <= max; i++) {
		if (substr(productName1,1,i) != substr(productName2,1,i)) {
			pos = i-1;
			break
		}
	}

	return pos
}

#
# Return line to be printed on report
#
function getLine(productName1,productName2, arr, decomDate, monographName, namespace, nComm, sectionName, sectionType) {
	if (productName1 != "") {
		if (productTypeFileMonograph[productName1]) {
			monographName = productName1;
			sectionName   = productName2
		}
		else if (productTypeFiles[productName1]) {
			monographName = productName2;
			sectionName   = productName1
		}
		if (namespaces[productName1] != "") {
			namespace = namespaces[productName1];
			if (productName2 != "") {
				if (namespaces[productName2] != "") {
					namespace = namespace "/" namespaces[productName2]
				}
			}
		}
	}
	else {
		if (productName2 != "") {
			if (productTypeFileMonograph[productName2]) {
				monographName = productName2;
				sectionName   = productName1
			}
			else if (productTypeFiles[productName2]) {
				monographName = productName1;
				sectionName   = productName2
			}
			if (namespaces[productName2] != "") {
				namespace = namespaces[productName2]
			}
		}
	}
	sectionType = productTypeFiles[sectionName];
	if (monographName != "") productTypeCount["Monograph"]++
	if (sectionType != "") productTypeCount[sectionType]++
	nComm       = index(sectionName,"DECOMMISSIONED");
	if (nComm) {
		decomDate   = substr(sectionName,nComm);
		sectionName = substr(sectionName,1,nComm - 1);
		if (sectionName ~ / - $/) {
			sectionName = substr(sectionName,1,length(sectionName) - 3)
		}
		else if (sectionName ~ /-$/) {
			sectionName = substr(sectionName,1,length(sectionName) - 1)
		}
	}
	else {
		decomDate = ""
	}

	return namespace "|" monographName "|" sectionType "|" sectionName "|" decomDate
}

#
# Store namespace from namespace.txt file
#
function getNamespace(str, arr, namespace, productName) {
	split(str,arr,"\t");
	productName             = arr[1];
	namespace               = arr[2];
	namespaces[productName] = namespace
}
		
#
# Ignore ARCHIVED products and determine if product is from Monograph or a section file
#
function processProductNames(str, arr, i, n, productName) {
	n = split(str,arr,"\t"); 
	for (i = 1; i <= n; i++) { 
		productName = arr[i]; 
		if (!index(productName,"ARCHIVE")) {
			if (productTypeName == "Monograph") {
				productTypeFileMonograph[productName] = 1
			}
			else { 
				productTypeFiles[productName] = productTypeName
			}
			productNames[productName] = 1
		}
	} 
}

#
# First file is namespace.txt:  Call getNamespace to get namespace
#
(NR == 1) {
	fileNum = 1;
	getNamespace($0);
	next
}

#
# Subsequent files are monograph/section files:
# Get productTypeName and call processProductNames to store product names and get type (i.e. Monograph, Clinicals, etc)
#
(FNR == 1) {
	fileNum++;
	split(FILENAME,arr,"/");
	split(arr[3],arr2,".")
	productTypeName = toupper(substr(arr2[1],1,1)) substr(arr2[1],2);
	processProductNames($0);
	next
}

#
# Get namespace for lines 2-End for namespace.txt
#
(fileNum == 1) {
	getNamespace($0);
	next
}

#
# For lines 2-End of monograph/section files:  Call processProductNames to store product names and get type
#
{
	processProductNames($0)
}

#
# Compile and print report
#
END {
	n = asorti(productNames,productNames2);
	#
	# Compile report
	# For each product name, find matching product name (if possible) and pair them together
	#
	for (i = 1; i <= n; i++) {
		productName1 = productNames2[i];
		#
		# If product name has not been used
		#
		if (productNames[productName1]) {
			max                 = 0;
			matchingProductName = "";
			for (j = 1; j <= n; j++) {
				if (i != j) {
					productName2 = productNames2[j];
					#
					# If product name has not been used
					#
					if (productNames[productName2]) {
						n2 = equiv(productName1,productName2);
						if (n2 > 5) {
							if (n2 > max) {
								max                 = n2;
								matchingProductName = productName2
							}
						}
					}
				}
			}
			#
			# Make product name as already used
			#
			productNames[productName1] = 0
			if (matchingProductName != "") {
				allNames[productName1]            = matchingProductName;
				#
				# Mark product name as already used
				#
				productNames[matchingProductName] = 0
			}
			else {
				allNames[productName1] = ""
			}
		}
	}
	#
	# Print report
	#
	n = asorti(allNames,allNames2);
	print "|||||Data Source|||Data Location||VA Programs 2019-2024";
	print "Namespace|Monograph Name|Section|Section Name|Status";
	for (i = 1; i <= n; i++) {
		productName1 = allNames2[i];
		productName2 = allNames[productName1];
		print getLine(productName1,productName2)
	}
	print "";
	print "Number of products:";
	print "Monograph: " productTypeCount["Monograph"]
	n = asorti(productTypeCount,productTypeCount2);
	for (i = 1; i <= n; i++) {
		productType = productTypeCount2[i];
		if (productType != "Monograph") {
			print productType ": " productTypeCount[productType]
		}
	}
}
