(
SynthDef(\radioBruss, {arg out=0;
	var snd;
	snd = SynthDef.wrap(Instr(\radioBruss).func);
	snd = SynthDef.wrap(Instr(\liveChannel).func, [\ar], [snd]);
	Out.ar(out, snd);
}).add;
)


(
~bruess01 = ();
)
(
~bruess01.chebyBuf = Buffer.alloc(s, 512, 1, {arg buf;
	buf.chebyMsg([1,0.5,0.6,0.3,0.2,0.3,0.3,0.1,0,0.2], true, true )
});
)
(
if(~bruess01.voicer.notNil, {
	~bruess01.voicer.releaseAll(0);
});
~bruess01.voicer = Voicer.new(1,\radioBruss,
	[\attack, 1, \release, 10, \bufnum, ~bruess01.chebyBuf, \gain, 5],
	target: ~live1.mixer.mixers[3].asMixer
);
)


(
~bcr.elements.kn[1][2].action_({|e|
	var reset = e.value.fold(0,0.5).lincurve(0,0.5,1,14,2);
	var hpFreq = (1 - (e.value.fold(0,0.5))).lincurve(0.5,1,3000,7000,1);
	var lpAmp = (1-e.value).lincurve(0,1,0,0.28,-2);
	var mu = (1-e.value).lincurve(0,1,0,4.3,-2);

	~bruess01.voicer.set([\reset, reset]);
	~bruess01.voicer.set([\hpFreq, hpFreq]);
	~bruess01.voicer.set([\lpAmp, lpAmp]);
	~bruess01.voicer.set([\mu,mu]);
});
)

/*********************/

~bruess01.voicer.trigger1(0);
~bruess01.voicer.releaseAll;


