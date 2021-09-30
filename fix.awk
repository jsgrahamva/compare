# Get date and time
#
#
BEGIN {
	mons["Jan"] = "01"
	mons["Feb"] = "02"
	mons["Mar"] = "03"
	mons["Apr"] = "04"
	mons["May"] = "05"
	mons["Jun"] = "06"
	mons["Jul"] = "07"
	mons["Aug"] = "08"
	mons["Sep"] = "09"
	mons["Oct"] = 10
	mons["Nov"] = 11
	mons["Dec"] = 12
}

{
	mon     = mons[$2];
	day     = $3;
	if (day < 10) {
		day = "0" day
	}
	yr      = $6;
	date    = yr mon day;
	time    = $4;
	split(time,arr,":");
	time    = arr[1] arr[2] arr[3];
	dtm     = date "-" time;
	# 
	# routine is defined by fix
	#
	cmd1    = "git checkout -b " dtm;
	cmd2    = "git add " routine;
	cmd3    = "vim " routine;
	cmd4    = "git commit -a";
	cmd     = cmd1 "; " cmd2 "; " cmd3 "; " cmd4;
	system(cmd)
}
