(
//s.options.memSize = 131072;
//~julio1 = ();
~julio1.conv1 = (
	busses: (),
	buffer: (),
	actions: (),
);
s.waitForBoot({
	~julio1.conv1.mixerChannel = MixerChannel.new('~julio1.conv1',s,2,2)
});


/* BUS ****************************/
~julio1.conv1.busses.toMixer = {~julio1.conv1.mixerChannel.asBus};
~julio1.conv1.busses.convolver = Bus.audio(s,2);
~julio1.conv1.busses.fx = Bus.audio(s,2);

/* BUFFER *************************/
~julio1.conv1.buffer.kernel = RDPartConvKernel(\julio1Conv1Kernel,"D:/MusikMachen/Tracks/julio/samples/badkern1.wav", s);
~julio1.conv1.buffer.sample = RDSample(\julio1Conv1Sample, "D:/MusikMachen/Tracks/julio/samples/troet.wav" ,s);


/* ACTIONS ***********************/
~julio1.conv1.actions.sample = ();
~julio1.conv1.actions.sample.pattern = nil;
~julio1.conv1.actions.sample.playIt = {arg self, rate=1, amp=1;
		Synth(\rdOneShotSampler2, [
			\out,~julio1.conv1.busses.convolver,
			\bufnum, ~julio1.conv1.buffer.sample.bufnum,
			\startframe, ~julio1.conv1.buffer.sample.buffer.numFrames * 0.9,
		  \rate, rate, \amp, amp, \pan, 0,
			\attack, 0.5, \sustain, 0.5/*~julio1.conv1.buffer.sample.duration/rate*/, \release, 0.5,
	], ~julio1.groups.sndSrc.group).register;
};
~julio1.conv1.actions.sample.stopIt = {
	~julio1.groups.sndSrc.group.freeAll;
};

~julio1.conv1.actions.convolver = ();
~julio1.conv1.actions.convolver.pattern = nil;
~julio1.conv1.actions.convolver.playIt = {
	if(not(RDUtils.nodeExists(~julio1.conv1.actions.convolver.synthNode)), {
		~julio1.conv1.actions.convolver.synthNode = Synth(\rdPartConv2, [
			\out,~julio1.conv1.busses.toMixer, \audioInput, ~julio1.conv1.busses.convolver,
			\irBufnumL,~julio1.conv1.buffer.kernel.bufnum(0),
			\irBufnumR,~julio1.conv1.buffer.kernel.bufnum(1),
			\wet,1, \pan,0, \amp,0.1, \fftsize,16384
		], ~julio1.groups.fx1.group).register;
	});
};
~julio1.conv1.actions.convolver.stopIt = {
	if(RDUtils.nodeExists(~julio1.conv1.actions.convolver.synthNode), {
		~julio1.conv1.actions.convolver.synthNode.free;
	});
};


)
/* DO STUFF ***********************/
~julio1.conv1.actions.do(_.clear);

~julio1.conv1.actions.convolver.playIt;
~julio1.conv1.actions.convolver.stopIt;

~julio1.conv1.actions.sample.playIt(0.3,1);
~julio1.conv1.actions.sample.playIt(0.4,1);
~julio1.conv1.actions.sample.playIt(0.9,1);
~julio1.conv1.actions.sample.stopIt;
























