(
~julio1.ping = ();
~julio1.ping.busses = ();
~julio1.ping.buffer = ();
~julio1.ping.actions = ();
~julio1.ping.mixerChannel = MixerChannel.new('julio1.ping',s,2,2);


/* BUS ****************************/
~julio1.ping.busses.toMixer = {~julio1.ping.mixerChannel.asBus};
~julio1.ping.busses.fx = Bus.audio(s,2);


/* BUFFER *************************/
~julio1.ping.buffer.sample = [
	RDSample(\julio1Ping1, "D:/MusikMachen/Tracks/julio/samples/ping1.wav", s),
	RDSample(\julio1Ping2, "D:/MusikMachen/Tracks/julio/samples/ping2.wav", s),
	RDSample(\julio1Ping3, "D:/MusikMachen/Tracks/julio/samples/ping3.wav", s),
	RDSample(\julio1Ping4, "D:/MusikMachen/Tracks/julio/samples/ping4.wav", s)
];


/* ACTIONS ***********************/
~julio1.ping.actions.sample = ();
~julio1.ping.actions.sample.playIt = {|self, rate, amp=0.5|
	var buffer = rrand(0,~julio1.ping.buffer.sample.size-1);
	Synth(\rdOneShotSampler2, [
		\rate, rate, \amp, amp,
		\bufnum, ~julio1.ping.buffer.sample.at(buffer).bufnum,
		\release, 0.8,
		\sustain, 0.5,
		\out, ~julio1.ping.busses.fx.index
	], ~julio1.groups.sndSrc.group).register;
};

~julio1.ping.actions.fx = (
	playIt: {
		if(RDUtils.nodeExists(~julio1.ping.actions.fx.synthNode).not, {
			~julio1.ping.actions.fx.synthNode = Synth(\julio1PingFX, [
				\in, ~julio1.ping.busses.fx.index,
				\out, ~julio1.ping.busses.toMixer.index,
				\delayWet,0.5,\delayTime,0.1,\delayfactor,0.5,
				\klankFreqs,[50,600,3200,3300,3500],
				\klankAmps,[0.1,0.1,0.01,0.08,0.01],
				\klankTimes,[0.4,0.1,0.4,0.5,0.1],
				\klankWet,0.3
			], ~julio1.groups.fx1.group).register;
		});
	},
	stopIt: {
		if(RDUtils.nodeExists(~julio1.ping.actions.fx.synthNode), {
			~julio1.ping.actions.fx.synthNode.free;
		})
	}
);

)


/* DO STUFF ***********************/
~julio1.ping.actions.fx.playIt;
~julio1.ping.actions.fx.stopIt;

~julio1.ping.actions.sample.playIt;
~julio1.ping.actions.sample.stopIt;






