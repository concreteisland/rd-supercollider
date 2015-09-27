(
~julio1.schweb2 = ();
~julio1.schweb2.busses = ();
~julio1.schweb2.buffer = ();
~julio1.schweb2.actions = ();
~julio1.schweb2.mixerChannel = MixerChannel.new('julio1.schweb2',s,2,2);


/* BUS ****************************/
~julio1.schweb2.busses.toMixer = {~julio1.schweb2.mixerChannel.asBus};
~julio1.schweb2.busses.fx = Bus.audio(s,2);


/* BUFFER *************************/
~julio1.schweb2.buffer.grainEnvelope = RDSineEnvelopeBuffer(\julio1Schweb2GrainEnv,0.3,0.3,512,s);
~julio1.schweb2.buffer.sample = RDChannelSample(\julio1Schweb2, "D:/MusikMachen/Tracks/julio/samples/chord.wav", s);
~julio1.schweb2.buffer.sampleAttack = RDSample(\julio1Schweb2Attack, "D:/MusikMachen/Tracks/julio/samples/chord.wav", s);


/* LAUNCHER **********************/
~julio1.schweb2.launcher = RDSynthLauncher.new;
~julio1.schweb2.launcher.setConfig(\chord,
	RDSynthConfig(\rdSampler2,[
		\amp, 1, \release, 0.8, \gate, 1,
		\bufnum, ~julio1.schweb2.buffer.sampleAttack.bufnum,
		\out, ~julio1.schweb2.busses.toMixer.index
	], {~julio1.groups.sndSrc.group}
	);
);
~julio1.schweb2.launcher.setConfig(\grain,
	RDSynthConfig(\julio1Schweb2,[
		\out, ~julio1.schweb2.busses.toMixer.index,
		\bufnumLeft, ~julio1.schweb2.buffer.sample.bufnum(0),
		\bufnumRight, ~julio1.schweb2.buffer.sample.bufnum(1),
		\grainEnvelopeBufnum, ~julio1.schweb2.buffer.grainEnvelope.buffer.bufnum,
		\grainRate, 40, \grainRateVar, 20,
		\grainDuration, 0.8, \grainDurationVar, 0.04,
		\pos1, 0.5, \pos2, 0.75, \startPosition, 0,
		\posRate, 0.1, \posVar, 0.03,
		\grainPitch, 1, \grainPitchVar, 0.01, \grainAmp, 0.2,
		\attackTime, 2, \decayTime, 0.01,
		\sustainLevel, 1,\releaseTime, 3,
	], {~julio1.groups.sndSrc.group})
);


/* ACTIONS ***********************/
~julio1.schweb2.actions.p1 = (
	pattern: Pbindef(\julio1Schweb2P1,
		\instrument, \julio1Schweb2,
		\group, Pfunc({~julio1.groups.sndSrc.group}),
		\dur, 20, \sustain, 10,
		\out, Pfunc({~julio1.schweb2.busses.toMixer.index}),
		\bufnumLeft, Pfunc({~julio1.schweb2.buffer.sample.bufnum(0)}),
		\bufnumRight, Pfunc({~julio1.schweb2.buffer.sample.bufnum(1)}),
		\grainEnvelopeBufnum, Pfunc({~julio1.schweb2.buffer.grainEnvelope.buffer.bufnum}),
		\grainRate, [30,100,50], \grainRateVar, [5,20,5],
		\grainDuration, [0.2, 0.08, 0.02], \grainDurationVar, 0.02,
		\pos1, 0.5, \pos2, 0.75, \startPosition, [0.5,0.0,0.75],
		\posRate, 0.04, \posVar, 0.03,
		\grainPitch, [3,1,2.03]*0.796, \grainPitchVar, 0.01,
		\grainAmp, [0.1,1,0.7],
		\attackTime, [5,3,1], \decayTime, 0.01,
		\sustainLevel, 1,\releaseTime, 7,
	),
	playIt: {
		~julio1.schweb2.actions.p1.player = ~julio1.schweb2.actions.p1.pattern.trace.play;
	},
	stopIt: {
		~julio1.schweb2.actions.p1.player.stop;
	}
);




)
/* DO STUFF ***********************/

~julio1.schweb2.actions.p1.playIt;
~julio1.schweb2.actions.p1.stopIt;

~julio1.schweb2.launcher.on(0, \grain, [\grainAmp, 4, \grainPitch, 0.8], sustain:10);
~julio1.schweb2.launcher.on(1, \grain, [\grainAmp, 2, \grainPitch, 0.4], sustain:10);
~julio1.schweb2.launcher.off(0);

s.makeGui



















