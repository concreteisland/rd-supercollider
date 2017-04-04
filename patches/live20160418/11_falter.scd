(
SynthDef(\falter, {arg outbus=0, cutoff=3000, res=0.1, bufnum = #[0,0],
		grainRate, grainRateRadius,
		grainDur, grainDurRadius,
		grainPitch,
		grainPosition,grainPositionRadius;



	var grains, envelope, dust;

	grainPosition = TRand.kr(0.1,0.9,Impulse.kr(0)) + grainPosition;

	grains = SynthDef.wrap(Instr(\grainsUniASR).func,
		[\kr, \kr, \kr, \kr, \kr, \kr, \kr, \kr], [
		bufnum,
		grainRate, grainRateRadius,
		grainDur, grainDurRadius,
		grainPitch,
		grainPosition,grainPositionRadius
	]);
	grains = DFM1.ar(grains,cutoff.lag(0.5),res.lag(1),1,0,0.0005,1);
	grains = CompanderD.ar(grains, 0.5,1,0.1,0.001,0.001);
	grains = GVerb.ar(grains,10,1,0.9,0.1,15,1,0.05,0.1,100);
	grains = SynthDef.wrap(Instr(\liveChannel).func, [\ar], [grains]);
	Out.ar(outbus, grains );
}).add;
)
(
~falter01 = ();
~falter01.voicer = ();
)
(
RDBufferUtils.createMonoBufferListFromPath(Platform.resourceDir +/+ "sounds/_live/falter.wav", s,
	~falter01.buffers,
	{|buffers| ~falter01.buffers = buffers;}
);
RDBufferUtils.createSineEnvelopeBuffer(0.1, 0.1, 1024, s,
	~falter01.envelopeBuffer,
	{|buffer| ~falter01.envelopeBuffer = buffer;}
);
)
(
if(~falter01.voicer.notNil, {
	~falter01.voicer.releaseAll;
});
~falter01.voicer = Voicer.new(8,\falter, [
	\grainRate,12, \grainRateRadius,4,
	\grainDur,70,\grainDurRadius,60,
	\grainPitch,1,\amp,1,
	\grainPositionRadius,200,\grainPosition,0.4511,
	\bufnum, ~falter01.buffers.collect({|b|b.bufnum;}),
	\grainEnvelopeBufnum, ~falter01.envelopeBuffer.bufnum,
	\outbus, 0,
	\release,1,\gain,0.25,
	\loFreq,70,\loRs,0.25,\loGain,8,
	\peakFreq,300,\peakRq,0.2,\peakGain,-12,
	\hiFreq,1200,\hiRs,3,\hiGain,0
], target: ~live1.mixer.mixers[6].asMixer);)


(
var pad1 = ~qneo.elements.pad[8];
var pad2 = ~qneo.elements.pad[9];
pad1.noteOn.action_({|e|
	~falter01.voicer.trigger1(0);
});
pad1.noteOff.action_({|e|
	~falter01.voicer.release1(0)
});
pad1.pressure.action_({|e|
	var value = e.value.linlin(0,1,0.1,1);
	~falter01.voicer.firstNodeFreq(0).set([\amp, value,
		\cutoff, (1-e.value).linlin(0,1,2000,6000),
		\res, e.value.linlin(0,1,0.03,0.6)]
	);
});
pad1.locationX.action_({|e|
	var value = e.value.linlin(0,1,-0.1,0.1);
	~falter01.voicer.firstNodeFreq(0).set([\grainPosition, value]);
});
pad1.locationY.action_({|e|
	var durValue = e.value.linexp(0,1,40,120);
	var durRadiusValue = e.value.linexp(0,1,10,20);
	var rateValue = (1-e.value).lincurve(0,1,5,65,-2);
	var rateRadiusValue = (1-e.value).linexp(0,1,20,70);
	~falter01.voicer.firstNodeFreq(0).set([
		\grainDur, durValue, \grainDurRadius, durRadiusValue,
		\grainRate, rateValue, \grainRateRadius, rateRadiusValue
	]);
});




pad2.noteOn.action_({|e|
	~falter01.voicer.trigger1(1, args: [
		\grainPitch, (1-e.value).linlin(0,1,0.5,2.0),
		\gain, 0.05, \release, 3
	]);
});
pad2.noteOff.action_({|e|
	~falter01.voicer.release1(1)
});
pad2.pressure.action_({|e|
	var value = e.value.linlin(0,1,0.1,1);
	~falter01.voicer.firstNodeFreq(1).set([\amp, value,
		\cutoff, (1-e.value).linlin(0,1,2000,6000),
		\res, e.value.linlin(0,1,0.03,0.6)]
	);
});
pad2.locationX.action_({|e|
	var value = e.value.linlin(0,1,-0.01,0.01);
	~falter01.voicer.firstNodeFreq(1).set([\grainPosition, value]);
});
pad2.locationY.action_({|e|
	var durValue = e.value.linexp(0,1,50,120);
	var durRadiusValue = e.value.linexp(0,1,10,20);
	var rateValue = (1-e.value).lincurve(0,1,100,200,-2);
	var rateRadiusValue = (1-e.value).linexp(0,1,20,70);
	~falter01.voicer.firstNodeFreq(1).set([
		\grainDur, durValue, \grainDurRadius, durRadiusValue,
		\grainRate, rateValue, \grainRateRadius, rateRadiusValue
	]);
});
)


