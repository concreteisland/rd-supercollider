(
Instr(\duty, {arg freq=1;

	var seq, seq2;
	var durations, freqs;
	var pattern;
	var osc;
	var snd;

	seq   = [5,4,];
	seq2 = [3,2,3];
	durations = [
		Dseq(seq*freq.reciprocal,inf),
		Dseq(seq2*freq.reciprocal,inf),
	];
	freqs        = [
		Dseq((seq*freq.reciprocal).reciprocal,inf),
		Dseq((seq2*freq.reciprocal).reciprocal,inf),
	];
	pattern     = Duty.ar(durations,0,freqs);


	osc = VarSaw.ar(pattern,0.75,0).range(0,1);
	osc = [osc[0], (1-osc[1])];


	[
		min(osc[0], osc[1]),
		max(osc[0], osc[1]),
		absdif(osc[0], osc[1]),
		osc[0]*osc[1],
		(osc[0]+osc[1])/2
	];
});
)

(Ndef(\duty, Instr(\duty).func);)
Ndef(\duty).play
Ndef(\duty).stop
Ndef(\duty).clear
Ndef(\duty).set(\freq,432)
Ndef(\duty).scope


({Instr(\duty).func.value(48);}.plot(0.5))





(
Instr(\grains, {arg
	grainRate, grainRateVar,
	grainPosition, grainPositionVar,
	grainDuration, grainDurationVar,
	grainPitch, grainPitchVar,
	bufnum,envbufnum;

	var grainBuf;
	var grainTrigger;
	var lfos, lfos2;

	lfos = Instr(\duty).ar(0.1);
	lfos2 = Instr(\duty).ar(1);

	grainRate = lfos[3].lincurve(0,1,40,120,1);
	grainRate = grainRate + LFDNoise0.kr(grainRate,mul:grainRateVar);
	grainTrigger = Impulse.kr(grainRate);

	grainPosition = lfos[0].linlin(0,1,0.84,0.85);
	grainPositionVar = TRand.kr(grainPositionVar * (-1), grainPositionVar, grainTrigger);
	grainPosition = grainPosition + grainPositionVar;

	grainDuration = lfos[2].lincurve(0,1,0.03,0.2,-4);
	grainDurationVar = TRand.kr(grainDurationVar * (-1), grainDurationVar,grainTrigger);
	grainDuration = grainDuration + grainDurationVar;

	grainPitchVar = TRand.kr(grainPitchVar * (-1), grainPitchVar, grainTrigger);
	grainPitch = grainPitch + grainPitch;

	grainBuf = GrainBuf.ar(2,
		grainTrigger,
		grainDuration,
		bufnum,
		grainPitch,
		grainPosition,
		4,
		0,
		envbufnum
	);
	grainBuf;
});
)


~buffer = Buffer.readChannel(s,
	Platform.resourceDir +/+ "sounds/julio2/sound-sources/teufel.wav",
	channels:0
);

Ndef(\grains).clear;
Ndef(\grains, Instr(\grains).func)
Ndef(\grains).set(\grainRate, 80, \grainRateVar, 1);
Ndef(\grains).set(\grainPosition, 0.1, \grainPositionVar, 0.01);
Ndef(\grains).set(\grainDuration, 0.2, \grainDurationVar, 0.1);
Ndef(\grains).set(\grainPitch, 1
	, \grainPitchVar, 0.01);
Ndef(\grains).set(\bufnum, ~buffer.bufnum, \envbufnum, -1);
Ndef(\grains).play

