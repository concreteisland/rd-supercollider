(
SynthDef(\julioPfiff01, {arg
	out = 0,
	bufnumLeft, bufnumRight, grainEnvelopeBufnum,
	t_trigger = 1,
	grainRate = 10, grainRateVar = 0, grainDuration = 0.1, grainDurationVar = 0,
	pos1 = 0, pos2 = 1, startPosition = 0, posVar = 0, posRate = 1,
	grainPitch = 1, grainPitchVar = 0,
	grainAmp = 0.5, gate = 1,
	attackTime = 0.1, decayTime = 0, sustainLevel = 1, releaseTime = 0.1,
	filterFreq = 1000;

	var snd, pos, grainTrigger, grains;
	var env, envGen, envLength, envTrigger, asr;
	var filter;

	grainTrigger = Impulse.kr(grainRate + LFNoise0.kr(grainRate,grainRateVar));

	posRate = (BufDur.kr(bufnumLeft))*posRate;
	pos = RDPhasor.ar(t_trigger,pos1,pos2,startPosition,-1,posRate,1);
	pos = TRand.kr(pos-posVar,pos+posVar,grainTrigger).clip(0,1);

	grainPitch = TRand.kr(
		grainPitch-grainPitchVar,
		grainPitch+grainPitchVar,
		grainTrigger
	);

	grainDuration = TRand.kr(
		grainDuration-grainDurationVar,
		grainDuration+grainDurationVar,
		grainTrigger
	);

	grains = GrainBuf.ar (
		numChannels: 1,
		trigger: grainTrigger,
		dur: grainDuration,
		sndbuf: [bufnumLeft,bufnumRight],
		rate: grainPitch,
		pos: pos,
		interp: 4,
		pan: [-1,1],
		envbufnum: grainEnvelopeBufnum,
		maxGrains: 512,
		mul: grainAmp
	);

	snd = grains;

	/***********/

	filter = RLPF.ar(snd,filterFreq,1);
	snd = filter;

	/***********/

	snd = snd * EnvGen.kr(
		Env.adsr(attackTime,decayTime,sustainLevel,releaseTime),
		gate,
		doneAction:2
	);

	Out.ar(out, snd);
}).add;
)

RDSineEnvelopeBuffer(\julioSineEnv1,0.5,0.5,1024,s);
RDChannelSample(\julioPfiff01, "D:/MusikMachen/Tracks/julio/samples/pfiff01.wav", s);
RDGroup(\julioSrc1,s);



~julio = ();
~julio.pfiff01 = ();
~julio.pfiff01.launcher = RDSynthLauncher();
(
~julio.pfiff01.launcher.setConfig(\a,
	RDSynthConfig.new(\julioPfiff01, [
		\out, 0,
		\bufnumLeft, RDChannelSample(\julioPfiff01).buffer(0).bufnum,
		\bufnumRight, RDChannelSample(\julioPfiff01).buffer(1).bufnum,
		\grainEnvelopeBufnum, RDSineEnvelopeBuffer(\julioSineEnv1).buffer.bufnum,
		\t_trigger, 1,
		\grainRate, 50, \grainRateVar, 10,
		\grainDuration, 0.06, \grainDurationVar, 0,
		\pos1, 0.05, \pos2, 0.2, \startPosition, 0,
		\posVar, 0.01, \posRate, 0.00001,
		\grainPitch, 1, \grainPitchVar, 0.01,
		\grainAmp, 0.45, \gate, 1,
		\attackTime, 0.1, \decayTime, 0, \sustainLevel, 1, \releaseTime, 2;
		], RDGroup(\julioSrc1).group
	)
);
)

~julio.pfiff01.launcher.on(0,\a);
~julio.pfiff01.launcher.setArg(0, \grainRate, 15);
~julio.pfiff01.launcher.setArg(0, \grainRateVar, 4);
~julio.pfiff01.launcher.setArg(0, \posRate, 0.001);
~julio.pfiff01.launcher.setArg(0, \startPosition, 0.4);
~julio.pfiff01.launcher.setArg(0, \t_trigger, 1);
~julio.pfiff01.launcher.setArg(0, \pos1, 0.07);
~julio.pfiff01.launcher.setArg(0,	\pos2, 0.6);
~julio.pfiff01.launcher.setArg(0, \posVar, 0.01);
~julio.pfiff01.launcher.setArg(0, \grainDuration, 0.01);
~julio.pfiff01.launcher.setArg(0, \grainDurationVar, 0.01);
~julio.pfiff01.launcher.setArg(0, \releaseTime, 2);
~julio.pfiff01.launcher.setArg(0, \grainPitch, 1);
~julio.pfiff01.launcher.off(0);

s.plotTree



MIDIMKtl.find
~quneo = MIDIMKtl('qn0', 1, 3);
(
~quneo.elements.pad[12].noteOn.action_({|e|
	~julio.pfiff01.launcher.on(0,\a, [\grainPitch, 1]);
});
~quneo.elements.pad[12].noteOff.action_({|e|
	~julio.pfiff01.launcher.off(0);
});
~quneo.elements.pad[12].pressure.action_({|e|
	~julio.pfiff01.launcher.setArg(0, \filterFreq, e.value.linexp(0,1,1000,5000));
});
~quneo.elements.pad[12].locationX.action_({|e|
	~julio.pfiff01.launcher.setArg(0, \grainRate, e.value.linlin(0,1,25,75));
	~julio.pfiff01.launcher.setArg(0, \grainRateVar, e.value.linlin(0,1,5,25));
});
~quneo.elements.pad[12].locationY.action_({|e|
	~julio.pfiff01.launcher.setArg(0, \grainDuration, e.value.linlin(0,1,0.01,1));
	~julio.pfiff01.launcher.setArg(0, \grainDurationVar, e.value.linlin(0,1,0.005,0.03));
});
~quneo.elements.hSlider[0].location.action_({|e|
	~julio.pfiff01.launcher.setArg(0, \startPosition, e.value);
});



)






s.scope


