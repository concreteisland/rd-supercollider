(
SynthDef(\buegel, {arg outbus=0;
	var grains, envelope, dust;
	grains = SynthDef.wrap(Instr(\grainsUniASR).func);
	dust = Dust.kr(0.2);
	grains = XFade2.ar(
		grains,
		BPF.ar(CrossoverDistortion.ar(grains, 0.6, 0.5),TExpRand.kr(120,2000,dust),2,1),
		EnvGen.kr(Env.perc(0.1,0.5,1,-2),dust,2,-1)
	);
	grains = GVerb.ar(grains,10,1,0.9,0.1,15,1,0.05,0.1,100);
	grains = SynthDef.wrap(Instr(\liveChannel).func, [\ar], [grains]);
	Out.ar(outbus, grains );
}).add;
)
(
~buegel01 = ();
~buegel01.voicer = ();
)
(
RDBufferUtils.createMonoBufferListFromPath(Platform.resourceDir +/+ "sounds/_live/VOC_151024-0070_quietsch.wav", s,
	~buegel01.buffers,
	{|buffers| ~buegel01.buffers = buffers;}
);
RDBufferUtils.createSineEnvelopeBuffer(0.2, 0.2, 1024, s,
	~buegel01.envelopeBuffer,
	{|buffer| ~buegel01.envelopeBuffer = buffer;}
);
)
(
if(~buegel01.voicer.notNil, {
	~buegel01.voicer.releaseAll;
});
~buegel01.voicer = Voicer.new(8,\buegel, [
	\grainRate,12, \grainRateRadius,4,
	\grainDur,70,\grainDurRadius,60,
	\grainPitch,1,\amp,1,
	\grainPositionRadius,200,\grainPosition,0.4511,
	\bufnum, ~buegel01.buffers.collect({|b|b.bufnum;}),
	\grainEnvelopeBufnum, ~buegel01.envelopeBuffer.bufnum,
	\outbus, 0,
	\release,0.1,\gain,0.4,
	\loFreq,70,\loRs,0.25,\loGain,12,
	\peakFreq,300,\peakRq,0.2,\peakGain,-12,
	\hiFreq,1000,\hiRs,3,\hiGain,-6
], target: ~live1.mixer.mixers[1].asMixer);
)
(
var pad1 = ~qneo.elements.pad[0];
var pad2 = ~qneo.elements.pad[1];
var vSlider = ~qneo.elements.vSlider[0];

vSlider.location.action_({|e|
	var value = (e.value+0.5).wrap(0,1);
	//value.postln;
});

pad1.noteOn.action_({|e|
	~buegel01.voicer.trigger1(0);
});
pad1.noteOff.action_({|e|
	~buegel01.voicer.release1(0)
});
pad1.pressure.action_({|e|
	var value = e.value.linlin(0,1,0.1,1);
	~buegel01.voicer.firstNodeFreq(0).set([\amp, value]);
});
pad1.locationX.action_({|e|
	var value = e.value.linlin(0,1,
		vSlider.location.value.linlin(0,1,0.2,0.8)-0.1,
		vSlider.location.value.linlin(0,1,0.2,0.8)+0.1
	);
	~buegel01.voicer.firstNodeFreq(0).set([\grainPosition, value]);
});
pad1.locationY.action_({|e|
	var durValue = e.value.linexp(0,1,30,500);
	var durRadiusValue = e.value.linexp(0,1,10,200);
	var rateValue = (1-e.value).linexp(0,1,5,15);
	var rateRadiusValue = (1-e.value).linexp(0,1,4,7);
	~buegel01.voicer.firstNodeFreq(0).set([
		\grainDur, durValue, \grainDurRadius, durRadiusValue,
		\grainRate, rateValue, \grainRateRadius, rateRadiusValue
	]);
});

pad2.noteOn.action_({|e|
	~buegel01.voicer.trigger1(1);
});
pad2.noteOff.action_({|e|
	~buegel01.voicer.release1(1)
});
pad2.pressure.action_({|e|
	var value = e.value.linexp(0,1,0.1,1);
	~buegel01.voicer.firstNodeFreq(1).set([\amp, value]);
});
pad2.locationX.action_({|e|
	var value = e.value.linlin(0,1,
		(vSlider.location.value+0.5).wrap(0,1).linlin(0,1,0.2,0.8)-0.1,
		(vSlider.location.value+0.5).wrap(0,1).linlin(0,1,0.2,0.8)+0.1
	);
	~buegel01.voicer.firstNodeFreq(1).set([\grainPosition, value]);
});
pad2.locationY.action_({|e|
	var durValue = e.value.linexp(0,1,30,500);
	var durRadiusValue = e.value.linexp(0,1,10,200);
	var rateValue = (1-e.value).linexp(0,1,3,40);
	var rateRadiusValue = (1-e.value).linexp(0,1,4,12);
	~buegel01.voicer.firstNodeFreq(1).set([
		\grainDur, durValue, \grainDurRadius, durRadiusValue,
		\grainRate, rateValue, \grainRateRadius, rateRadiusValue
	]);
});
)


