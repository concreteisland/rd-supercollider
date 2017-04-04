(
SynthDef(\klavier, {arg outbus=0;
	var snd;
	snd = SynthDef.wrap(Instr(\klavier).func);
	snd = SynthDef.wrap(Instr(\liveChannel).func, [\ar], [snd]);
	snd = SynthDef.wrap(Instr(\envelopeASR).func) * snd;
	Out.ar(outbus, snd);
}).add;
)

(
~klavier = ();
)
(
(RDBufferUtils.loadBuffer(Platform.resourceDir+/+"sounds/_live/klavier.wav",s,~klavier.buffer,{|b|~klavier.buffer=b});)
)
(
~klavier !? { ~klavier.voicer !? { ~klavier.voicer.releaseAll } };
~klavier.voicer=Voicer.new(2,\klavier, [
	\bufnum, ~klavier.buffer.bufnum,
	\release, 3
], target: ~live1.mixer.mixers[7].asMixer);
)
(
~bcr.elements.bt[0][7].action_({|e|
	if(e.value.booleanValue, {
		var synth = ~klavier.voicer.gate1(0,~klavier.buffer.duration);
		synth.synth.onFree({
			~bcr.elements.bt[0][7].value_(0);
		});
	}, {
		~klavier.voicer.releaseAll;
	});
});
)

/***********************/


~klavier.voicer.releaseAll;









