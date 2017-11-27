(
Fdef(\rhythmSine8, {arg freq = 100, intervals = #[1,0,0,0,0,0,0,0], phase = 0;
	var onsetIndexes, nPulses;
	var delayTimes, delay, osc;
	
	intervals = intervals.select(_!=0);
	nPulses = intervals.sum;
	onsetIndexes = intervals.integrate - intervals.first;
	delayTimes = Array.fill(nPulses, {|i| K2A.ar(i)/nPulses})/freq;
	delay = Duty.ar(Dseq(intervals/freq/nPulses, inf), 0, Dseq(onsetIndexes, inf)); 
	osc = DelayC.ar(SinOsc.ar(freq,phase),nPulses/freq,Select.ar(delay, delayTimes));
	osc;	
})
)
({
	Fdef(\rhythmSine8).value(100, [4,2,3])
}.plot(0.02))
