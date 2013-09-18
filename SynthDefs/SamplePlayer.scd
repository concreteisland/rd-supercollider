(
SynthDef(\SamplePlayer, {arg out=0,bufNum = 0,
	amp = 1,pan = 0,rate = 1,t_trig = 1,run = 1,
	startPosition = 0,endPosition = 1,
	currentPositionBus;

	var phasor, bufRead;

	phasor = SweepWithEnd.ar(
		t_trig,
		startPosition,
		endPosition,
		(BufRateScale.kr(bufNum) * BufSampleRate.kr(bufNum)) * run * rate
	);
	bufRead = BufRd.ar(2, bufNum, phasor, 0);

	Out.kr(currentPositionBus, phasor);
	//Out.ar(out, Pan2.ar(bufRead,pan,amp));
	Out.ar(out,Balance2.ar(bufRead[0],bufRead[1],pan,amp));
}).store;
)


