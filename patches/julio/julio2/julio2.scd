(
~julio2 = ();
~julio2.path = PathName.new(PathName.new(thisProcess.nowExecutingPath).pathOnly);

s.waitForBoot({
	(~julio2.path +/+ "traveller.scd").fullPath.openTextFile;

});

)

