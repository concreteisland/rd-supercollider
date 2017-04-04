(
SynthDef(\radioChaos, {arg outbus=0;
	var snd;

	snd = SynthDef.wrap(Instr(\radioChaos).func);
	snd = GVerb.ar(snd,10,3,0.5,0.5,15,1,0.2,0.1,12);
	snd = SynthDef.wrap(Instr(\liveChannel).func, [\ar], [snd]);
	snd = snd * SynthDef.wrap(Instr(\envelopeASR).func);

	Out.ar(outbus,snd);
}).add;
)


(
~radioChaos = ();
)
(
~radioChaos !? { ~radioChaos.voicer !? { ~radioChaos.voicer.releaseAll } };

~radioChaos.voicer = Voicer(1, \radioChaos, args: [
	\attack, 0.1,	\release,5, \gain, 0.2,
	\loFreq, 120, \loRs, 1.5, \loGain, 0,
	\peakFreq, 400, \peakRq, 0.5, \peakGain, 0,
	\hiFreq, 1000, \hiRs, 1.5, \hiGain, 0,
], target: ~live1.mixer.mixers[4].asMixer);
)

/********/

~radioChaos.voicer.trigger1(0);
~radioChaos.voicer.releaseAll;
