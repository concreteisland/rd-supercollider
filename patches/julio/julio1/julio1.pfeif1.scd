(
~julio1.pfeif1 = (
	busses:  (),
	buffer:  (),
	actions: (),
	mixerChannel: MixerChannel.new('julio1.pfeif1',s,2,2)
);


/* BUS ****************************/
~julio1.pfeif1.busses.toMixer = {~julio1.pfeif1.mixerChannel.asBus};
~julio1.pfeif1.busses.fx = Bus.audio(s,2);
~julio1.pfeif1.busses.amp = Bus.audio(s,2);



/* BUFFER *************************/
~julio1.pfeif1.buffer.grainEnvelope =RDSineEnvelopeBuffer(\julio1Pfeif1GrainEnv,0.3,0.3,512,s);
~julio1.pfeif1.buffer.sample = RDChannelSample(\julio1Pfeif1, "D:/MusikMachen/Tracks/julio/samples/pfeifen1.wav", s);
~julio1.pfeif1.buffer.sample2 = RDChannelSample(\julio1Pfeif2, "D:/MusikMachen/Tracks/julio/samples/pfeifen2.wav", s);

/* ACTIONS ***********************/
~julio1.pfeif1.actions.p1 = ();
~julio1.pfeif1.actions.p1.pattern = Pbindef(\julio1Pfeif1P1,
	\instrument, \grainBufEnv,
	\group, Pfunc({~julio1.groups.sndSrc.group}),
	\dur, 3, \sustain, 6,
	\out, Pfunc({~julio1.pfeif1.busses.amp.index}),
	\bufnumLeft, Pfunc({~julio1.pfeif1.buffer.sample.bufnum(0)}),
	\bufnumRight, Pfunc({~julio1.pfeif1.buffer.sample.bufnum(1)}),
	\grainEnvelopeBufnum, Pfunc({~julio1.pfeif1.buffer.grainEnvelope.buffer.bufnum}),
	\grainRate, [80,84], \grainRateVar, [10,10],
	\grainDuration, [0.12,0.08], \grainDurationVar, [0, 0.04],
	\pos1, 0.3, \pos2, 0.4, \startPosition, 0,
	\posRate, 0.001, \posVar, 0.02,
	\grainPitch, Pseq([[1,1.5],[1,2.5]],inf), \grainPitchVar, 0.01,
	\grainAmp, [0.5,0.2],
	\attackTime, 0.5, \decayTime, 0,
	\sustainLevel, 1,\releaseTime, 0.5,
);
~julio1.pfeif1.actions.p1.playIt = {
	if(~julio1.pfeif1.actions.p1.player.notNil.and(~julio1.pfeif1.actions.p1.player.isPlaying).not, {
		~julio1.pfeif1.actions.amp.playIt(1,0);
		~julio1.pfeif1.actions.p1.player =	~julio1.pfeif1.actions.p1.pattern.trace.play
	});
};
~julio1.pfeif1.actions.p1.stopIt = {
	if(~julio1.pfeif1.actions.p1.player.notNil.and(~julio1.pfeif1.actions.p1.player.isPlaying), {
		~julio1.pfeif1.actions.p1.player.stop;
	});
};



~julio1.pfeif1.actions.amp = ();
~julio1.pfeif1.actions.amp.playIt = {arg self, amp=1, lagTime=0;
	if(RDUtils.nodeExists(~julio1.pfeif1.actions.amp.synthNode).not, {
		~julio1.pfeif1.actions.amp.synthNode = Synth(\rdAmp2, [
			\out, ~julio1.pfeif1.busses.toMixer, \in, ~julio1.pfeif1.busses.amp,
			\amp, amp, \lagTime, lagTime
		], ~julio1.groups.fx1.group).register;
	}, {
		~julio1.pfeif1.actions.amp.setAmp(amp,lagTime)
	});
};
~julio1.pfeif1.actions.amp.stopIt = {
	if(RDUtils.nodeExists(~julio1.pfeif1.actions.amp.synthNode), {
			~julio1.pfeif1.actions.amp.synthNode.free;
	});
};
~julio1.pfeif1.actions.amp.setAmp = {|self, amp, lagTime=0|
	if(RDUtils.nodeExists(~julio1.pfeif1.actions.amp.synthNode), {
		~julio1.pfeif1.actions.amp.synthNode.set(\amp, amp, \lagTime, lagTime);
	});
};

)

/* DO STUFF **************************/
~julio1.pfeif1.actions.amp.playIt;
~julio1.pfeif1.actions.amp.stopIt;
~julio1.pfeif1.actions.amp.setAmp(1,10);


~julio1.pfeif1.actions.p1.playIt
~julio1.pfeif1.actions.p1.stopIt;
~julio1.pfeif1.actions.amp.setAmp(0,2);


