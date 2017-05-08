(Instr(\nine, {arg freq = 100, phasorFreq=1;
	var clock;
	var phasorTrigger;
	var phasor;

	clock = Impulse.ar(freq);
	phasorTrigger = PulseDivider.ar(clock, 11, -1);
	phasor = Phasor.ar(phasorTrigger, 1/SampleRate.ir * freq * (phasorFreq.reciprocal), 0, 1, 0);

	[
		Decay.ar(clock,0.001),
		Decay.ar(phasorTrigger,0.001),
		phasor,
	]
}))

{Instr(\nine).func.value(300, 10); }.plot(0.1)




