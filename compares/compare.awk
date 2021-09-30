BEGIN {
	productTypesArr[1] = "monograph";
	productTypesArr[2] = "clinicals";
	productTypesArr[3] = "financial-administrative";
	productTypesArr[4] = "infrastructure";
	productTypesArr[5] = "vista-gui hybrids"
}

(FNR == 1) {
	split(FILENAME,arr,".");
	productTypeName = arr[1];
	productTypeNames[productTypeName] = productTypeName
}

{ 
	n = split($0,arr,"\t"); 
	for (i = 1; i <= n; i++) { 
		productName = arr[i]; 
		if (!index(productName,"ARCHIVE")) {
			productTypeFiles[productName][productTypeName] = "X"
		}
	} 
} 

END {
	print "Products|Status|Monograph|Clinical|Financial-Administrative|Infrastructure|VistA-GUI Hybrids";
	n = asorti(productTypeFiles,productNames);
	for (i = 1; i <= n; i++) {
		productName = productNames[i];
		status      = (productName ~ /(DECOMMISSION|commission)/) ? "Decommissioned": "";
		line        = productName "|" status;
		flags       = 0;
		for (j = 1; j <= 5; j++) {
			productTypeName = productTypesArr[j];
			entries[j]      = productTypeFiles[productName][productTypeName];
			if (j > 1) { flags++ }
		}
		line = (((flags) && (entries[1] == "")) ? "* " : "") productName "|" status
		for (j = 1; j <= 5; j++) {
			line = line "|" entries[j]
		}
		print line
	}
	print "";
	print "* - Not in Monograph"
}
