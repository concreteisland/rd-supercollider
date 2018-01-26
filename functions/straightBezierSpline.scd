(
f = {arg segments = 1, controlPointsPerSegment = 1;
	var numberOfPoints = (segments+1) + (segments * controlPointsPerSegment);
	var x;
	var allPoints, points, controlPoints;

	x = Array.series(numberOfPoints, 0, 1/(numberOfPoints-1));
	allPoints = x.dup.lace(numberOfPoints*2).clump(2);
	
	points = allPoints.select({arg point, index;
		index.mod(controlPointsPerSegment + 1) == 0;
	});
	
	controlPoints = allPoints.reject({arg point, index;
		index.mod(controlPointsPerSegment + 1) == 0;
	}).clump(controlPointsPerSegment);	
	
	[points,controlPoints].lace(((segments+1)*2)-1);
}


b = BezierSpline(*f.value(2, 3))
b.gui;
)
