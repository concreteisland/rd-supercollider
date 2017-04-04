(
SynthDef(\middd, {arg outbus=0, freq=100, amp=0.5, ampFactor=1, modOffset=0, xFade=1;
	var snd;
	snd = SynthDef.wrap(Instr(\middd).func,
		[\kr, \kr, \kr, \kr],
		[freq, amp*ampFactor.lag(1), modOffset.lag(1)]
	);
	snd = SynthDef.wrap(Instr(\liveChannel).func, [\ar], [snd]);
	XOut.ar(outbus,xFade.lag(3),snd);
}).add;
)

(
~middd = ();
~middd.voicer = ();
)
(
if(~middd.voicer.notNil, {
	~middd.voicer.releaseAll;
});
~middd.voicer = Voicer.new(4, \middd, [
	\amp, 0.5, \outbus, 0, \gain, 0.1, \amp, 0.5, \attack, 2, \release, 5],
	target: ~live1.mixer.mixers[3].asMixer
);


~bcr.elements.kn[2][0].action_({|e|
	~middd.voicer.firstNodeFreq(140).set([\xFade,e.value.lincurve(0,1,0,1,4)]);
});
~qneo.elements.pad[2].noteOn.action_({arg e; });
~qneo.elements.pad[2].noteOff.action_({arg e; });
~qneo.elements.pad[2].pressure.action_({arg e;
	var value = e.value.linlin(0,1,1,1.2);
	~middd.voicer.firstNodeFreq(5220).set([\ampFactor, value]);
	~middd.voicer.firstNodeFreq(5330).set([\ampFactor, value]);
	~middd.voicer.firstNodeFreq(140).set([\ampFactor, value]);
});
~qneo.elements.pad[2].locationX.action_({arg e;
	var value = e.value;
	~middd.voicer.firstNodeFreq(5220).set([\modOffset, value]);
	~middd.voicer.firstNodeFreq(5330).set([\modOffset, value]);
	~middd.voicer.firstNodeFreq(140).set([\modOffset, value]);
});


)


/****************************/


(
~middd.voicer.trigger1(5220);
~middd.voicer.trigger1(5330, args: [\xFade, 0.5]);
~middd.voicer.trigger1(140, args: [
	\gain, 1, \xFade, 0,
	\loFreq,100,\loRs,0.5,\loGain,12,
	\peakFreq,400,\peakRq,1,\peakGain,-12,
	\hiFreq,3200,\hiRs,1,\hiGain,5
]);
)
~middd.voicer.releaseAll;




