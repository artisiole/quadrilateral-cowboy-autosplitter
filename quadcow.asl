state("qc") {
	string32 map : 0x002BC4B0, 0x4;
	float mapTime: 0x0008E8D0, 0x0;
}

init {
	vars.loading = false;
	vars.resetable = false; // Need to keep track of this to make sure the attempt count doesn't get ran up
	vars.totalIGT = 0.0;
}

split {
	return current.map != old.map;
}

reset {
	if (current.map.Equals("/train.map") && current.mapTime < 1 && vars.resetable) {
		vars.totalIGT = 0.0;
		return true;
	}
}

start {
	if (current.map.Equals("/train.map") && current.mapTime < 1) {
		vars.totalIGT = 0.0;
		vars.resetable = false;
		return true;
	}
}

update {
	// mapTime jumps up a large number during loads
	// it seems to be the total uptime of the game
	// so if the time jumps up more than like 5 (this is a magic number), the game is loading
	if (current.mapTime - old.mapTime > 5){
		vars.loading = true;
	} else if (current.mapTime - old.mapTime < 0){ // if the time is negative, we are back to gameplay
		vars.loading = false;
	}
	
	if(current.mapTime > 1){
		vars.resetable = true;
	}
}

gameTime {
	// if we're not in a loading screen, increment our igt by mapTime difference
	// also make sure we don't subtract any time from our igt
	if(!vars.loading && current.mapTime - old.mapTime > 0) {
		vars.totalIGT += current.mapTime - old.mapTime;
	}

	return TimeSpan.FromSeconds(vars.totalIGT);
}
