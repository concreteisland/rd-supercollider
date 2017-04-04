(
Instr(\bufferPlayer, {arg bufnum;
	var snd, phase;
	phase = Sweep.ar(1,BufSampleRate.kr(bufnum));
	((phase/BufFrames.kr(bufnum)*100)).round(0.01).poll(1, "tfinal1 is at %");
	snd = BufRd.ar(2,bufnum, phase, interpolation: 4);
	snd;
});

Instr(\liveChannel, {arg
	in, gain=1,
	loFreq=1200,loRs=1,loGain=0,
	peakFreq=1200,peakRq=1,peakGain=0,
	hiFreq=1200,hiRs=1,hiGain=0;

	var snd;
	snd = gain * in;

	snd = BLowShelf.ar(snd,loFreq,loRs,loGain);
	snd = BPeakEQ.ar(snd,peakFreq,peakRq,peakGain);
	snd = BHiShelf.ar(snd,hiFreq,hiRs,hiGain);

	snd = Limiter.ar(snd);
	snd = LeakDC.ar(snd);
	snd;
});


Instr(\impulseUni, {arg lo=1, hi=1;
	var impulse, rate;
	rate = LFNoise0.kr((lo+hi)/2).range(lo,hi);
	impulse = Impulse.kr(rate);
	impulse;
});

Instr(\grainsUni, {arg
	bufnum = #[0,0],
	grainRate=8, grainRateRadius=3,
	grainDur=1650, grainDurRadius=420,
	grainPitch=1,
	grainPosition=0.5,grainPositionRadius=1,
	grainEnvelopeBufnum=(-1);

	var grains;
	var grainTrigger;
	var bufferFrames = BufFrames.kr(bufnum[0]);
	var envelope;

	grainTrigger = Instr(\impulseUni).kr(grainRate-grainRateRadius, grainRate+grainRateRadius);

	grainDur = TRand.kr(
		grainDur-grainDurRadius,
		grainDur+grainDurRadius,
		grainTrigger
	)/1000; //scale duration to sec;

	grainPosition = grainPosition * bufferFrames; //scale grainPos from range 0-1 to frames
	grainPositionRadius = (grainPositionRadius/1000) * BufSampleRate.kr(bufnum[0]); //scale grainPosRadius from ms to frames
	grainPosition = TRand.kr(
		grainPosition - grainPositionRadius,
		grainPosition + grainPositionRadius,
		grainTrigger
	) / bufferFrames; //scale grainPos to range 0-1

	grains = GrainBuf.ar(
		1,
		grainTrigger,
		grainDur,
		bufnum,
		grainPitch,
		grainPosition,
		4,
		0,
		grainEnvelopeBufnum
	);

	grains;
});

Instr(\grainsUniASR, {arg
	bufnum = #[0,0],
	grainRate=8, grainRateRadius=3,
	grainDur=1650, grainDurRadius=420,
	grainPitch=1,
	grainPosition=0.5,grainPositionRadius=1,
	grainEnvelopeBufnum=(-1),
	attack = 0.1,gate=1, release=0.1, amp = 1;

	var grains, envelope;

	grains = Instr(\grainsUni).ar(
		bufnum,
		grainRate, grainRateRadius,
		grainDur, grainDurRadius,
		grainPitch, grainPosition, grainPositionRadius,
		grainEnvelopeBufnum,
	);

	envelope = EnvGen.kr(Env.asr(attack,1,release),gate, 1, doneAction:2) * amp;
	grains = grains * envelope;
	grains;
});

Instr(\grainsLoopingASR, {arg
	bufnum = #[0,0],
	grainRate=8, grainRateRadius=3,
	grainDur=1650, grainDurRadius=420,
	grainPitch=1,
	grainPositionStart=0,grainPositionEnd=0,grainPositionRate=1,grainPositionRadius=1,
	grainEnvelopeBufnum=(-1),
	attack = 0.1,gate=1, release=0.1, amp = 1;

	var snd;
	var grainPosition = Phasor.ar(
		1,
		(grainPositionRate/BufSampleRate.kr(bufnum[0]))/BufDur.kr(bufnum[0]),grainPositionStart, grainPositionEnd,grainPositionStart);

	snd = Instr(\grainsUniASR).ar(
		bufnum,
		grainRate, grainRateRadius,
		grainDur, grainDurRadius,
		grainPitch,
		grainPosition,grainPositionRadius,
		grainEnvelopeBufnum,
		attack,gate,release,amp
	);

	snd;
});

Instr(\middd, {arg freq=100, amp=0.5, modOffset=0, attack=1, release=1, gate=1;
	var snd, envelope;
	snd = Instr(\midddSaw).ar(freq, amp, modOffset);
	snd = Splay.ar(snd);
	envelope = EnvGen.kr(Env.asr(attack,1,release),gate, 1, doneAction:2);
	snd = snd * envelope;
	snd;
});

Instr(\midddSaw, {arg freq=100, amp=1, modOffset=0;
	var snd, hpf;
	snd = VarSaw.ar(
		freq + SinOsc.ar(freq * 0.251,0, freq*(0.4+modOffset.linlin(0,1,0,0.6))),
		0,
		0.4,
		amp + Instr(\midddSawAmpMod).ar(freq, amp, modOffset)
	);
	hpf = RHPF.ar(snd, freq * 2.52,1,1).tanh;
	snd = RLPF.ar(snd,freq * 2.5,0.4,1).softclip;
	snd = (snd*1) + (hpf*0.4);
	snd = Splay.ar(snd).softclip;
	snd;
});

Instr(\midddSawAmpMod, {arg carrierFreq=100, carrierAmp=1, modOffset=0;
	var osc;

	osc = PMOsc.ar(
		carrierFreq * (4.032 + SinOsc.ar(0.1,0,0.02)+modOffset.linlin(0,1,0,0.02)),
		carrierFreq * (
			0.25 +
			SinOsc.ar(
				0.34,0,0.0002,LFNoise0.kr(2,0.001)
				+
				modOffset.linlin(0,1,0,0.002))),
		3,
		3,
		carrierAmp * (0.8 + modOffset.linlin(0,1,0,0.2))
	);

	osc = osc + Ringz.ar(osc,carrierFreq * 2.51,2,0.4).softclip;
	osc;
});


Instr(\rdPerlin, {arg freq;
	var perlin;
	var phasor;
	var numbers = TRand.kr(
		2.0.pow(8).neg,
		2.0.pow(8),
		Impulse.kr(0).dup(6)
	).clump(3);
	phasor = Phasor.ar(1,freq/SampleRate.ir,numbers[0],numbers[1]);
	perlin = Perlin3.ar(
		phasor[0], 0, 0
	);
	perlin;
});


Instr(\teufel, {arg bufnum=0;
	var snd, perlin, trigger;

	trigger = Impulse.kr(0.056299836845371, [0,0.5]);
	snd = PlayBuf.ar(2,bufnum,1,trigger).tanh * [1,0.5];
	snd = Splay.ar(snd);
	perlin = Instr(\rdPerlin).ar(2);
	snd = snd * (0.5 + (0.5*perlin.clip(0,1).lag(1)));
	snd = snd + Ringz.ar(snd,500,0.07,0.05).tanh;
	snd = snd + BPF.ar(snd,500 + (perlin.lag(2) * 400), 1, 2).tanh;
	snd;
});

Instr(\envelopeASR, {arg attack = 0.1,gate=1, release=0.1, amp = 1;
	var envelope;
	envelope = EnvGen.kr(Env.asr(attack,1,release),gate, 1, doneAction:2) * amp;
	envelope;
});


Instr(\radioBruss, {arg bufnum, attack = 0.1,gate=1, release=0.1, amp = 1,
	reset = 13, hpFreq = 3240, lpAmp = 0.08, mu=3.301;
	var signal, rhpf, rlpf, delay;

	signal = Brusselator.ar(
		reset: Impulse.kr(
			reset +
			SinOsc.kr(
				0.53+
				  SinOsc.kr(0.43,mul:0.2),mul:3)),
				rate: 0.01,
				mu: mu,
				gamma: 1.1,
				initx: -0.77,
				inity: 0.4
            );

	rhpf = RHPF.ar(signal, hpFreq,0.01, 0.7);
	delay = AllpassC.ar(rhpf,3,1+SinOsc.kr([2.1,0.5],mul:0.7),5);
	rhpf = rhpf + delay;
	rhpf = BPF.ar(rhpf,[330,2100]!2,[0.7,0.1],[2,1]);


	rhpf = Shaper.ar(bufnum,rhpf,0.5);

	rlpf = RLPF.ar(signal,30,0.1,lpAmp);

	signal = rhpf  + rlpf;
	signal = Splay.ar(signal, 0.5);

	signal = FreeVerb2.ar(signal[0],signal[1],mix:0.2,room:1,damp:1);

	signal = LeakDC.ar(signal);
	signal = Compander.ar(signal,signal,0.5,1,1/20,0.0001,0.1);
	signal = signal * Instr(\envelopeASR).ar(attack,gate,release,amp);


	signal;
});


Instr(\klavier, {arg bufnum;
	var snd;

	snd = PlayBuf.ar(2,bufnum, 0.8, Impulse.kr(BufDur.kr(bufnum).reciprocal * 0.8,[0,0.5]));
	snd = Splay.ar(snd,1,0.2);
	snd = snd * LFCub.kr([3,3.1],0).range(0.8,1);
	snd = SwitchDelay.ar(snd,1,0.2,1,0.6,2);
	snd = DFM1.ar(snd,1000,0.1,1,0,0.008);

	snd;
});

Instr(\hundebass, {arg bufnum=0, bufnumAttack=0, lpMod=0;
	var snd, bass;
	var attack, attackLo;
	var tail;
	var freq, hasFreq;
	var t_trig = Impulse.kr(0);

	bass = PlayBuf.ar(2,bufnum,1,t_trig);
	bass = bass * EnvGen.kr(Env.linen(0.01,1,3),t_trig);

	attack = PlayBuf.ar(2,bufnumAttack,1,t_trig);
	attackLo = RLPF.ar(attack,60,0.3,4).tanh;
	attack = (attack * 3).tanh;
	attack = attack + attackLo;
	attack = attack * EnvGen.kr(Env.perc(0.01,1,1,-2),t_trig);

	# freq, hasFreq = Pitch.kr(bass[0], minFreq:10);

	freq = Latch.kr(freq,TDelay.kr(t_trig, 0.3));
	freq = [freq,freq+0.1];

	tail = PulseDPW.ar(freq.lag,0.8,1);
	tail = RLPF.ar(tail,70+lpMod, 0.6);
	tail = tail * EnvGen.kr(Env.asr(2,1,0.5),1);


	snd = XFade2.ar(XFade2.ar(bass,attack,-0.5), tail, -0.9);
	snd = LeakDC.ar(snd);
	snd;
});

Instr(\partconv, {arg in, irbufnum = #[0,0], fftsize=4096;
	var snd, conv;
	conv = PartConv.ar(in,fftsize,irbufnum);
	snd = conv;
	snd;
});



Instr(\ulvaPlayer, {arg
	bufnum, startframe=0, rate=1;
	var snd;
	snd = PlayBuf.ar(2,bufnum,rate,1,startframe);
	snd;
});

Instr(\radioChaos, {
	var snd, hpf, lpf;

	snd = FBSineC.ar(
		freq: 20000,
		im: LFNoise2.kr([3,3.1]).range(0.1,51),
		fb: LFNoise0.kr([2,2.03]).range(0,0.5),
		a: SinOsc.kr(0.2,[0,0.5*pi]).range(1,1.01),
		c: VarSaw.kr(0.133,0,SinOsc.kr([0.2,0.3]).range(0.1,0.9)).range(0.3,1)
	) * 1;

	hpf = RHPF.ar(snd,1400,2,0.1).distort;
	lpf = RLPF.ar(snd,70,3,0.3).distort.tanh;

	snd = hpf + lpf;

	snd = BPF.ar(snd,LFNoise2.kr(0.2.dup).range(300,1000).lag(2),LFNoise2.kr(0.2.dup).range(0.5,1.5).lag(2));

	//snd = SinOsc.ar(70+(snd*30),0,0.1);

	snd = Pan2.ar(snd.tanh);

	snd;
});

Instr(\trainrattle, {arg bufnum;
	var snd;
	snd = PlayBuf.ar(2,bufnum, 0.8, Impulse.kr(BufDur.kr(bufnum).reciprocal * 0.8,[0,0.5]));

	snd = snd + RLPF.ar(
		WaveLoss.ar(
			HPF.ar(CombC.ar(snd,0.1,[2484,2485].reciprocal,
				LFNoise2.kr(3.reciprocal).range(0,LFNoise2.kr(1).range(0.01,3))),
				80+TRand.kr(0.01,100,Dust.kr(0.3)).lag(2)
			),
			30,40,2
		).tanh,
		1200,3);

	snd = Splay.ar(snd,1,0.2);
	snd;
});




)