({
	var line, mapped;
	var sourceSegments, targetSegments, curves;
	
	sourceSegments = [0.0, 0.2, 0.5, 0.9, 1.0];	
	targetSegments =  [0.0, 0.5, 0.55, 0.7, 1.0];
	curves =                [    -3,   1,     0,    5];
	
	line = Line.ar(0,1,0.01);	
	
	mapped = 0;
	sourceSegments.doAdjacentPairs({arg a, b, i;
		mapped = mapped + (
			InRange.ar(line,a,b) * 
			line.lincurve(a,b,targetSegments[i],targetSegments[i+1],curves.wrapAt(i))
		);
	});	
	[line, mapped];
}.plot)



