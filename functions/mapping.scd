(
~mapSegments = {arg in, sourceSegments, targetSegments, curves;
	var mapped = 0;
	sourceSegments.doAdjacentPairs({arg a, b, i;
		mapped = mapped + (
			InRange.ar(in,a,b) * 
			in.lincurve(a,b,targetSegments[i],targetSegments[i+1],curves.wrapAt(i))
		);
	});	
	mapped;
};

~map2Segments = {arg in, 
	p0=0, p1=0.5, p2=1.0,
	q0=0, q1=0.5, q2=1.0,
	c0= -4, c1=4;	
	~mapSegments.value(in, [p0,p1,p2], [q0,q1,q2],[c0,c1]);
};

~map3Segments = {arg in, 
	p0=0, p1=0.333, p2=0.666, p3=1.0,
	q0=0, q1=0.333, q2=0.666, q3=1.0,
	c0= -4, c1=4, c2 = -4;	
	~mapSegments.value(in, [p0,p1,p2,p3], [q0,q1,q2,q3],[c0,c1,c2]);
};

~map4Segments = {arg in, 
	p0=0, p1=0.25, p2=0.5, p3=0.75, p4=1.0,
	q0=0, q1=0.25, q2=0.5, q3=0.75, q4=1.0,
	c0= -4, c1=4, c2= -4, c3=4;	
	~mapSegments.value(in, [p0,p1,p2,p3,p4], [q0,q1,q2,q3,q4],[c0,c1,c2,c3]);
};
)

({
	var line;
	line = Line.ar(0,1,0.01);	
	~map2Segments.value(line, 0, 0.3, 1, 0, 0.2, 1, 4, -4);
}.plot)

({
	var line;
	line = Line.ar(0,1,0.01);	
	~map3Segments.value(line, 
		0, 0.3, 0.7, 1, 
		0, 0.2, 0.6, 1, 
		4, -4, 4);
}.plot)

({
	var line;
	line = Line.ar(0,1,0.01);	
	~map4Segments.value(line, 
		0, 0.3, 0.33, 0.9, 1, 
		0, 0.2, 0.22, 0.8, 1, 
		4, -2, 4, -2);
}.plot)
