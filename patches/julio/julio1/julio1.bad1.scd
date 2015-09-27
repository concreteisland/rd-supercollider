(
~julio1.bad1 = ();
~julio1.bad1.mixerChannel1 = MixerChannel.new('bad1', s, 2, 2);
~julio1.bad1.busses = ();
~julio1.bad1.busses.toMixer = {~julio1.bad1.mixerChannel1.asBus};
~julio1.bad1.busses.fx = Bus.audio(s,2);


~julio1.bad1.buffer = ();
~julio1.bad1.buffer.empty1 = RDSample(\julio1bad1empty1, "D:/MusikMachen/Tracks/julio/samples/badempty1.wav", s);
~julio1.bad1.launcher = RDSynthLauncher();
)

(
~julio1.bad1.launcher.setConfig(\empty1,
	RDSynthConfig(\rdSampler2, [
		\out, ~julio1.bad1.busses.fx.index,
		\bufnum, RDSample(\julio1bad1empty1).bufnum,
		\startframe, 0, \rate, 1,
		\attack, 0.01, \gate, 1, \release, 0.01,
		\amp, 1, \pan, 0
		], {~julio1.groups.sndSrc.group}
	)
);
~julio1.bad1.launcher.setConfig(\empty1fx,
	RDSynthConfig(\emptybad1, [
		\out, ~julio1.bad1.busses.toMixer.scope.index,
		\in, ~julio1.bad1.busses.fx.index,
		], {~julio1.groups.fx1.group}
	)
);
)
/*************************/
~julio1.bad1.launcher.on(0, \empty1,[\amp, 1], sustain:RDSample(\julio1bad1empty1).buffer.duration);
~julio1.bad1.launcher.off(0);




(
SynthDef(\emptybad1, {arg out, in,
	combFreq=440,combAtt=1,combDec=1, wet=0.5;
	var snd, comb, fb, localIn, sndOrig;

	snd = In.ar(in,2);
	sndOrig = snd;
	localIn = LocalIn.ar(2);

	fb = localIn;
	fb = AllpassC.ar(fb,3,
		[0.02,0.019]+LFNoise0.kr(1,0.01),
		localIn.linlin(-1,1,0.2,5).lag(0.1),
		localIn.cubed.linexp(-1,1,0.4,0.4).lag(0.1)
	).tanh;
	fb = FreqShift.ar(fb,combFreq*(-0.5));
	fb = RHPF.ar(fb,combFreq/localIn.linlin(-1,1,2,8).lag(0.04),0.8);


	snd = snd+fb;

	comb = CombFormlet.ar(
		snd,
		combFreq+(localIn.lag(0.3).linlin(-1,1,(combFreq/8)*(-1),combFreq/8)),
		combAtt,
		combDec,
		Decay2.kr(Dust.kr(12),0.3,0.01,1,0.1)
	).tanh;

	comb = RLPF.ar(comb,combFreq*1.5,0.2).distort;

	snd = comb+(fb*0.5);

	LocalOut.ar(snd);

	snd = RHPF.ar(snd, 30, 1);


	snd = XFade2.ar(sndOrig,snd,wet.linlin(0,1,-1,1));

	CompanderD.ar(snd,0.8,1,0.1,0.01,0.01);


	Out.ar(out,Pan2.ar(snd,[-0.5,0.5]));
}).add;

~julio1.bad1.launcher.synthNodes[\fx].free;
~julio1.bad1.launcher.on(\fx, \empty1fx, [
	\combFreq, 3460,\combAtt, 0.01,\combDec, 0.08, \wet, 0.9
]);
~julio1.bad1.launcher.synthNodes[\fx2].free;
~julio1.bad1.launcher.on(\fx2, \empty1fx, [
	\combFreq, 340,\combAtt, 0.001,\combDec, 0.2, \wet, 1
]);

)












