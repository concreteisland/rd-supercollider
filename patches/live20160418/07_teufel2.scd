(
SynthDef(\teufel2, {arg outbus=0, xFade=1;
	var grains, envelope, dust;
	grains = SynthDef.wrap(Instr(\grainsUniASR).func);
	dust = Dust.kr(0.2);
	grains = GVerb.ar(grains,50,3,0.1,0.5,15,1,0.2,0.3,100).tanh;
	grains = SynthDef.wrap(Instr(\liveChannel).func, [\ar], [grains]);
	XOut.ar(outbus, xFade.lag(3), grains );
}).add;
)

(
~teufel2 = ();
~teufel2.voicer = ();
)
(
RDBufferUtils.createMonoBufferListFromPath(Platform.resourceDir +/+ "sounds/_live/teufel3.wav", s,~teufel2.buffers,
	{|buffers| ~teufel2.buffers = buffers;}
);
RDBufferUtils.createSineEnvelopeBuffer(0.5, 0.5, 1024, s,
	~teufel2.envelopeBuffer,
	{|buffer| ~teufel2.envelopeBuffer = buffer;}
);
)
(
if(~teufel2.voicer.notNil, {
	~teufel2.voicer.releaseAll(0)
});
~teufel2.voicer = Voicer.new(1,\teufel2, [
	\grainRate,30, \grainRateRadius,7,
	\grainDur,300,\grainDurRadius,50,
	\grainPitch,0.35,\amp,1,
	\grainPositionRadius,100,\grainPosition,0.4511,
	\bufnum, ~teufel2.buffers.collect({|b|b.bufnum;}),
	\grainEnvelopeBufnum, ~teufel2.envelopeBuffer.bufnum,
	\gain,20,
	\loFreq,200,\loRs,1,\loGain,-24,
	\peakFreq,400,\peakRq,0.2,\peakGain,-12,
	\hiFreq,3000,\hiRs,3,\hiGain,-12,
	\attack, 3, \release,1
], target: ~live1.mixer.mixers[4].asMixer, addAction: \addToHead);
)

/****************/

~teufel2.voicer.trigger1(0);
~teufel2.voicer.releaseAll;






