(
SynthDef(\buegel2, {arg outbus=0, resTime=0, loAmp=1, loRes=0.1, 	bufnum = #[0,0],
	grainRate=8, grainRateRadius=3,
	grainDur=1650, grainDurRadius=420,
	grainPitch=1;

	var grains, envelope, bpf, lpf;
	grainPitch = Latch.kr(grainPitch, TDelay.kr(Impulse.kr(0),0.1));
	grains = SynthDef.wrap(Instr(\grainsUniASR).func,
		[\kr, \kr, \kr, \kr, \kr, \kr],
		[bufnum, grainRate, grainRateRadius, grainDur, grainDurRadius, grainPitch]
	);
	bpf = SwitchDelay.ar(
		BPF.ar(
		WaveLoss.ar(
			DynKlank.ar(Ref([
				[1,2.01,3.02,4.03] + Perlin3.kr(Phasor.kr(1,300,0,999999),0,0).range(-500,500),
				[1,1/2, 1/3, 1/4]/10,
				[resTime.lag(3)]
				]),
				grains,600
			),
			20,
			40,
				ToggleFF.kr(Dust.kr(1)).range(1,2).round
		).tanh,LFNoise2.kr(0.1).range(400,2000),1),1,0.5,0.8,0.8,1
	);
	lpf = BMoog.ar(grains,120,loRes,0,2.2,loAmp).tanh.tanh;
	grains = grains + bpf + lpf;

	grains = DFM1.ar(grains,3000,0.3,1.2,0,0.001);
	grains = GVerb.ar(grains,10,1,0.9,0.1,15,1,0.05,0.1,100);
	grains = CompanderD.ar(grains,0.5,1,0.1,0.01,1);

	grains = SynthDef.wrap(Instr(\liveChannel).func, [\ar], [grains]);
	Out.ar(outbus, grains );
}).add;
)

(
~buegel02 = ();
~buegel02.voicer = ();
)
(
RDBufferUtils.createMonoBufferListFromPath(Platform.resourceDir +/+ "sounds/_live/VOC_160112-0083_gluehbirne-stirbt.wav", s,
	~buegel02.buffers,
	{|buffers| ~buegel02.buffers = buffers;}
);
RDBufferUtils.createSineEnvelopeBuffer(0.2, 0.2, 1024, s,
	~buegel02.envelopeBuffer,
	{|buffer| ~buegel02.envelopeBuffer = buffer;}
);
)

(
if(~buegel02.voicer.notNil, {
	~buegel02.voicer.releaseAll(0);
});
~buegel02.voicer = Voicer.new(2,\buegel2, [
	\grainRate,30, \grainRateRadius,10,
	\grainDur,150,\grainDurRadius,10,
	\grainPitch,1.0,\amp,1,
	\grainPositionStart,0.7,
	\grainPositionRadius,100,
	\bufnum, ~buegel02.buffers.collect({|b|b.bufnum;}),
	\grainEnvelopeBufnum, ~buegel02.envelopeBuffer.bufnum,
	\outbus, 0,\gain,2,
	\loFreq,200,\loRs,1,\loGain,0,
	\peakFreq,500,\peakRq,2,\peakGain,3,
	\hiFreq,1000,\hiRs,3,\hiGain,-4,
	\attack, 6, \release, 12,
], target: ~live1.mixer.mixers[2].asMixer);
)


(
~qneo.elements.pad[14].noteOn.action_({|e|
	~buegel02.voicer.trigger1(10.rand);
});
~qneo.elements.pad[14].noteOff.action_({|e|
	~buegel02.voicer.releaseAll;
});
~qneo.elements.pad[14].pressure.action_({|e|
	var value = e.value.lincurve(0,1,0.2,1,3);
	~buegel02.voicer.set([\amp, value]);
});

~qneo.elements.pad[14].locationX.action_({|e|
	~buegel02.voicer.set([
		\grainDur, e.value.lincurve(0,1,50,150,3),
		\grainDurRadius, e.value.lincurve(0,1,10,30,3),
		\loAmp, e.value.lincurve(0,1,0.1,2,1),
		\loRes, e.value.lincurve(0,1,0.1,0.7,0),
	]);
});

~qneo.elements.pad[14].locationY.action_({|e|
	var p = e.value.linlin(0,1,0.8,2);
	~buegel02.voicer.set([\resTime, e.value.lincurve(0,1,0,2,3), \grainPitch, p]);
});


)

