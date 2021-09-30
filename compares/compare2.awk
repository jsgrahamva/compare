(FNR == 1) {
	split(FILENAME,arr,".");
	productTypeName = toupper(substr(arr[1],1,1)) substr(arr[1],2)
}

{ 
	n = split($0,arr,"\t"); 
	for (i = 1; i <= n; i++) { 
		productName = arr[i]; 
		if (!index(productName,"ARCHIVE")) {
			if (productTypeName == "Monograph") {
				productTypeFileMonograph[productName] = 1
			}
			else { 
				productTypeFiles[productName] = productTypeName
			}
			productNames[productName] = ""
		}
	} 
} 

END {
	print "|||||Data Source|||Data Location||VA Programs 2019-2024"
	print "Products|Status|Type|VA POC|Cerner|VistA|CDW|Other|VistA|Local||EHRM|DMLSS|FMBT"

	n = asorti(productNames,productNames2);
	for (i = 1; i <= n; i++) {
		productName     = productNames2[i];
		status          = (productName ~ /(DECOMMISSION|commission)/) ? "Decommissioned": "";
		productTypeName = productTypeFiles[productName]
		if ((productTypeFileMonograph[productName] == 1) && (productTypeName == "")) {
			productName2 = "- " productName
		}
		else if ((productTypeFileMonograph[productName] == "") && (productTypeName != "")) {
			productName2 = "+ " productName
		}
		else {
			productName2 = "  " productName
		}
		print productName2 "|" status "|" productTypeName
	}
	print "";
	print "- Only in Monograph"
	print "+ Not in Monograph"
}
