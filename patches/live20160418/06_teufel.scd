(
SynthDef(\teufel, {arg outbus=0, xFade=1;
	var snd;
	snd = SynthDef.wrap(Instr(\teufel).func);
	snd = SynthDef.wrap(Instr(\liveChannel).func, [\ar], [snd]);
	snd = snd * SynthDef.wrap(Instr(\envelopeASR).func);
	XOut.ar(outbus,xFade.lag(3),snd);
}).add;
)

(
~teufel1 = ();
)
(
RDBufferUtils.loadBuffer(Platform.resourceDir +/+ "sounds/_live/teufel.wav",s,~teufel1.buffer, {|b|
	~teufel1.buffer = b.normalize;});
)
(
if(~teufel1.voicer.notNil, {
	~teufel1.voicer.releaseAll;
});
~teufel1.voicer = Voicer.new(1,\teufel,
	[
		\xFade, 0,
		\bufnum, ~teufel1.buffer.bufnum,
		\loFreq,100,\loRs,1,\loGain,12,
		\peakFreq,400,\peakRq,1,\peakGain,-12,
		\hiFreq,3200,\hiRs,1,\hiGain,-12,
		\gain,20,
	], target: ~live1.mixer.mixers[4].asMixer);

~bcr.elements.kn[2][1].action_({|e|
	~teufel1.voicer.set(
		[
			\xFade,
			e.value.lincurve(0,1,0,1,1)
		]
	);
});

);


/***************************/

~teufel1.voicer.trigger1(0);
~teufel1.voicer.releaseAll;





