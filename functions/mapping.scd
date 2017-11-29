({
	var line, mapped;
	var segments, curves;
	
	segments = [0.0, 0.4,1.0];	
	curves =      [-3,1];
	
	line = Line.ar(0,1,0.01);	
	
	mapped = 0;
	segments.doAdjacentPairs({arg a, b, i;
		mapped = mapped + (
			InRange.ar(line,a,b) * 
			line.lincurve(a,b,a,b,curves.wrapAt(i))
		);
	});	
	[line, mapped];
}.plot)

