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

	var effectiveGrainRate, effectiveGrainPosition, effectiveGrainDuration, effectiveGrainPitch;
	var grainBuf;
	var grainTrigger;
	var lfos, lfos2;
	var density;
	var grainChangeRate;

	lfos = Instr(\duty).ar(0.1);
	lfos2 = Instr(\duty).ar(2);

	//grainRate = lfos[3].lincurve(0,1,500,700,0);
	effectiveGrainRate = grainRate + LFDNoise0.kr(grainRate,mul:grainRateVar);
	grainTrigger = Impulse.ar(effectiveGrainRate);

	grainPosition = A2K.kr(lfos2[0]).linlin(0,1,0.03,0.9);
	//grainPosition = SinOsc.kr(0.1).range(0,1);
	grainPositionVar = TRand.kr(grainPositionVar * (-1), grainPositionVar, grainTrigger);
	effectiveGrainPosition = grainPosition + grainPositionVar;

	//grainDuration = lfos[2].linlin(0,1,0.001,grainDuration);
	grainDurationVar = TRand.kr(grainDurationVar * (-1), grainDurationVar,grainTrigger);
	effectiveGrainDuration = grainDuration + grainDurationVar;

	grainPitchVar = TRand.kr(grainPitchVar * (-1), grainPitchVar, grainTrigger);
	effectiveGrainPitch = grainPitch + grainPitch;


	density = grainRate * grainDuration;
	density = density.lag(0.1);
	density.poll(label:\density);

	grainChangeRate = HPZ1.kr(grainPosition,(2*(10**5))).abs;
	grainChangeRate = grainChangeRate.lag(0.1).abs;
	grainChangeRate.poll(label:\grainChangeRate);

	grainBuf = GrainBuf.ar(2,
		grainTrigger,
		effectiveGrainDuration,
		bufnum,
		effectiveGrainPitch,
		effectiveGrainPosition,
		4,
		0,
		envbufnum
	);
	grainBuf;
});
)
Ndef(\grains, Instr(\grains).func)
Ndef(\grains).clear;

~buffer = Buffer.readChannel(s,Platform.resourceDir +/+ "sounds/julio2/sound-sources/automat.wav", channels:0);
~buffer = Buffer.readChannel(s,Platform.resourceDir +/+ "sounds/julio2/sound-sources/western/loop.wav", channels:0);



Ndef(\grains).set(\grainRate, 500, \grainRateVar, 440);
Ndef(\grains).set(\grainPosition, 0.71, \grainPositionVar, 0.008);
Ndef(\grains).set(\grainDuration, 0.07, \grainDurationVar, 0.007);
Ndef(\grains).set(\grainPitch,0.6, \grainPitchVar, 0.01);
Ndef(\grains).set(\bufnum, ~buffer.bufnum, \envbufnum, -1);
Ndef(\grains).play
Ndef(\grains).stop

Ndef(\grains)[0]

