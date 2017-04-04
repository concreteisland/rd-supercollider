(
SynthDef(\trainrattle, {arg outbus=0;
	var snd;
	snd = SynthDef.wrap(Instr(\trainrattle).func);
	snd = SynthDef.wrap(Instr(\liveChannel).func, [\ar], [snd]);
	snd = SynthDef.wrap(Instr(\envelopeASR).func) * snd;
	Out.ar(outbus, snd);
}).add;
)

(
~rattle = ();
)
(
(RDBufferUtils.loadBuffer(Platform.resourceDir+/+"sounds/_live/trainrattle.wav",s,~rattle.buffer,{|b|~rattle.buffer=b});)
)
(
~rattle !? { ~rattle.voicer !? { ~rattle.voicer.releaseAll } };
~rattle.voicer=Voicer.new(2,\trainrattle, [
	\bufnum, ~rattle.buffer.bufnum,
	\release, 3,
	\loFreq,100,\loRs,1,\loGain,0,
	\peakFreq,300,\peakRq,1,\peakGain,-12,
	\hiFreq,1300,\hiRs,1,\hiGain,6,
	\gain, 3,
], target: ~live1.mixer.mixers[4].asMixer);
)


/*********/
~rattle.voicer.trigger1(0);
~rattle.voicer.releaseAll;








