(
~julio1.schweb1 = (
	busses:  (),
	buffer:  (),
	actions: (),
	mixerChannel: MixerChannel.new('julio1.schweb1',s,2,2)
);

~julio1.schweb1.launcher = RDSynthLauncher.new;
~julio1.schweb1.plauncher = RDPatternLauncher.new;

~julio1.schweb1.busses.toMixer = {~julio1.schweb1.mixerChannel.asBus};
~julio1.schweb1.busses.fx = Bus.audio(s,2);



~julio1.schweb1.buffer.grainEnvelope =RDSineEnvelopeBuffer(\julio1Schweb1GrainEnv,0.5,0.5,512,s);
~julio1.schweb1.buffer.sample = RDChannelSample(\julio1Schweb1, "D:/MusikMachen/Tracks/julio/samples/schweb1.wav", s);
)
(
~julio1.schweb1.launcher.setConfig(\fx, RDSynthConfig.new(\julio1Schweb1Fx, [
	\in, ~julio1.schweb1.busses.fx.index,
	\out, ~julio1.schweb1.busses.toMixer.index,
	\hpFreq,4700, \hpRq,0.5, \drive, 2, \combDecay,0.5, \wet, 0
	], RDGroup(\julio1Fx1).group)
);

~julio1.schweb1.plauncher.setPattern(\schweb1, Pbindef(\julio1schweb1P1,
		\instrument, \julio1Schweb1,
	\group, RDGroup(\julio1SndSrc).group,
		\dur, 3, \sustain, 6,
		\out, Pfunc({~julio1.schweb1.busses.fx.index}),
		\bufnumLeft, Pfunc({~julio1.schweb1.buffer.sample.bufnum(0)}),
		\bufnumRight, Pfunc({~julio1.schweb1.buffer.sample.bufnum(1)}),
		\grainEnvelopeBufnum, Pfunc({~julio1.schweb1.buffer.grainEnvelope.buffer.bufnum}),
		\grainRate, [10,44], \grainRateVar, [0,10],
		\grainDuration, [0.03,0.1], \grainDurationVar, [0, 0.04],
		\pos1, 0.5, \pos2, 0.9, \startPosition, 0,
		\posRate, 0.05, \posVar, 0.02,
		\grainPitch, Pseq([[1,2],[1,2.98]],inf), \grainPitchVar, 0.01,
		\grainAmp, [0.3,0.5],
		\attackTime, 3, \decayTime, 0,
		\sustainLevel, 1,\releaseTime, 3,
	));
)


/* DO STUFF **************************/
~julio1.schweb1.launcher.on(\fx,\fx);
~julio1.schweb1.launcher.setArg(\fx, \wet, 1);
~julio1.schweb1.launcher.setArg(\fx, \wet, 0);
~julio1.schweb1.plauncher.on(0, \schweb1);

~julio1.schweb1.launcher.synthNodes[\fx].set(\wet,0)

~julio1.schweb1.launcher.synthNodes[\fx].notNil
~julio1.schweb1.launcher.synthNodes[\fx].free;
~julio1.schweb1.launcher.synthNodes[\fx]=nil;
~julio1.schweb1.plauncher.off(0);
