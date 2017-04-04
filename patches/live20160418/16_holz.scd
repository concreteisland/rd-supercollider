(
SynthDef(\holz, {arg outbus=0, cutoff=3000, res=0.1, bufnum = #[0,0],
		grainRate, grainRateRadius,
		grainDur, grainDurRadius,
		grainPitch,
		grainPosition,grainPositionRadius;

	var grains, envelope, dust, noise, noiseAmp;

	grains = SynthDef.wrap(Instr(\grainsUniASR).func,
		[\kr, \kr, \kr, \kr, \kr, \kr, \kr, \kr], [
		bufnum,
		grainRate, grainRateRadius,
		grainDur, grainDurRadius,
		grainPitch,
		grainPosition,grainPositionRadius
	]);
	noise = CombC.ar(grains,0.1,4400.reciprocal,0 + LFNoise2.kr(0.5).clip(0,1).exprange(0.005,2)).tanh;
	noiseAmp = AmplitudeMod.ar(noise,0.01,0.01);
	noise = BPF.ar(noise,2000-(noiseAmp*2000),2);
	grains = grains + noise;
	grains = DFM1.ar(grains,cutoff.lag(0.5),res.lag(1),1,0,0.0005,1);
	grains = CompanderD.ar(grains, 0.5,1,0.1,0.001,0.001);
	grains = GVerb.ar(grains,10,1,0.9,0.1,15,1,0.05,0.1,100);
	grains = SynthDef.wrap(Instr(\liveChannel).func, [\ar], [grains]);
	Out.ar(outbus, grains );
}).add;
)
(
~holz = ();
~holz.voicer = ();
~holz.poscenter1 = 0.5;
~holz.poscenter2 = 0.5;
)
(
RDBufferUtils.createMonoBufferListFromPath(Platform.resourceDir +/+ "sounds/_live/ofen.wav", s,
	~holz.buffers,
	{|buffers| ~holz.buffers = buffers;}
);
RDBufferUtils.createSineEnvelopeBuffer(0.2, 0.5, 1024, s,
	~holz.envelopeBuffer,
	{|buffer| ~holz.envelopeBuffer = buffer;}
);
)
(
if(~holz.voicer.notNil, {
	~holz.voicer.releaseAll;
});
~holz.voicer = Voicer.new(8,\holz, [
	\grainRate,12, \grainRateRadius,4,
	\grainDur,70,\grainDurRadius,60,
	\grainPitch,1,\amp,1,
	\grainPositionRadius,200,\grainPosition,0.4511,
	\bufnum, ~holz.buffers.collect({|b|b.bufnum;}),
	\grainEnvelopeBufnum, ~holz.envelopeBuffer.bufnum,
	\outbus, 0,
	\release,3,\gain,0.125,
	\loFreq,150,\loRs,0.25,\loGain,4,
	\peakFreq,300,\peakRq,0.2,\peakGain,-12,
	\hiFreq,1200,\hiRs,3,\hiGain,3
], target: ~live1.mixer.mixers[5].asMixer);
)

(
var pad1 = ~qneo.elements.pad[4];
var pad2 = ~qneo.elements.pad[5];

pad1.noteOn.action_({|e|
	~holz.poscenter1 = 1.0.rand;
	~holz.voicer.trigger1(0);
});
pad1.noteOff.action_({|e|
	~holz.voicer.release1(0)
});
pad1.pressure.action_({|e|
	var value = e.value.linlin(0,1,0.1,1);
	~holz.voicer.firstNodeFreq(0).set([\amp, value,
		\cutoff, (1-e.value).linlin(0,1,2000,6000),
		\res, e.value.linlin(0,1,0.03,0.6)]
	);
});
pad1.locationX.action_({|e|
	var value;
	value = e.value.linlin(0,1,~holz.poscenter1 - 0.05,~holz.poscenter1 + 0.05);
	~holz.voicer.firstNodeFreq(0).set([\grainPosition, value]);
});
pad1.locationY.action_({|e|
	var durValue = e.value.linexp(0,1,40,120);
	var durRadiusValue = e.value.linexp(0,1,10,20);
	var rateValue = (1-e.value).lincurve(0,1,5,65,-2);
	var rateRadiusValue = (1-e.value).linexp(0,1,2,30);
	~holz.voicer.firstNodeFreq(0).set([
		\grainDur, durValue, \grainDurRadius, durRadiusValue,
		\grainRate, rateValue, \grainRateRadius, rateRadiusValue
	]);
});





pad2.noteOn.action_({|e|
	~holz.poscenter2 = 1.0.rand;
	~holz.voicer.trigger1(1, args: [\grainPitch, (1-e.value).linlin(0,1,0.5,2.0), \gain, 0.05, \release, 3]);
});
pad2.noteOff.action_({|e|
	~holz.voicer.release1(1)
});
pad2.pressure.action_({|e|
	var value = e.value.linlin(0,1,0.1,1);
	~holz.voicer.firstNodeFreq(1).set([\amp, value,
		\cutoff, (1-e.value).linlin(0,1,2000,6000),
		\res, e.value.linlin(0,1,0.03,0.6)]
	);
});
pad2.locationX.action_({|e|
	var value;
	value = e.value.linlin(0,1,~holz.poscenter2 - 0.05,~holz.poscenter2 + 0.05);
	~holz.voicer.firstNodeFreq(1).set([\grainPosition, value, \grainPositionRadius, 30]);
});
pad2.locationY.action_({|e|
	var durValue = e.value.linexp(0,1,40,60);
	var durRadiusValue = e.value.linexp(0,1,10,20);
	var rateValue = (1-e.value).lincurve(0,1,70,200,-2);
	var rateRadiusValue = (1-e.value).linexp(0,1,20,70);
	~holz.voicer.firstNodeFreq(1).set([
		\grainDur, durValue, \grainDurRadius, durRadiusValue,
		\grainRate, rateValue, \grainRateRadius, rateRadiusValue
	]);
});


)


