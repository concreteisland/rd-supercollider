~splineMapper = ();
~splineMapper.spline = BezierSpline.new(
	[0,0],
	[
		(0.1,0.2..0.9),
		(0.1,0.2..0.9).pow(3)
	].flop,
	[1,1]
);

~splineMapper.spline = BezierSpline.new([ 0, 0 ], [ [ 0.0, 0.1675 ], [ 0.0, 0.2675 ], [ 0.2625, 0.03 ], [ 0.46, 0.1 ], [ 0.615, 0.2 ], [ 0.7525, 0.2575 ], [ 0.8, 0.405 ], [ 0.9675, 0.8 ], [ 0.6375, 0.9875 ] ], [ 1, 1 ], [  ], false);

~splineMapper.spline.gui;


~splineMapper.buffer  = Buffer.alloc(s, 1024);
~splineMapper.signal = Signal.new(c.numFrames/2);
~splineMapper.updater = Updater(~splineMapper.spline);
~splineMapper.isUpdating = false;
~splineMapper.updater.updateFunc_({|spline|	
	if(not(~splineMapper.isUpdating), {
		~splineMapper.isUpdating = true;
		~splineMapper.signal = Signal.newFrom(
			0.dup((~splineMapper.buffer.numFrames/4) + 1) 
			++ 
			~splineMapper.spline.bilinearInterpolate((~splineMapper.buffer.numFrames/4))
		);
		
		~splineMapper.buffer.sendCollection(~splineMapper.signal.asWavetableNoWrap, action: {
			~splineMapper.isUpdating = false;
			"updated".postln;
		});		
	}, {
		"don't update".postln;
	}) 
});

~splineMapper.buffer.plot
~splineMapper.signal.plot



({
	var line, mapped;
	
	line = Line.ar(0,200,0.1);

	mapped = Shaper.ar(
		~splineMapper.buffer.bufnum,
		line.clip(0,200).linlin(0,200,0,1)
	).linlin(0,1,12, 120);
	
	[line, mapped];
}.plot(0.1))
