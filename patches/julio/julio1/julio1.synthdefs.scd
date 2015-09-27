(
SynthDef(\rdSampler2, {arg out=0,
	bufnum, startframe=0, rate=1,
	attack=0.01,gate=1,release=0.01,
	amp=1, pan=0;
	var snd,env;
	env = EnvGen.kr(Env.asr(attack,gate,release,\sine),gate,amp,doneAction:2);

	snd = PlayBuf.ar(2,bufnum,rate,1,startframe);
	snd = snd * env;

	Out.ar(out,Balance2.ar(snd[0],snd[1],pan))
}).add;

SynthDef(\julio1PingFX, {arg in,out,
	delayWet=1, delayTime=1,delayfactor=0.7,
	klankFreqs=#[100,200,300,0,0],
	klankAmps=#[0.1,0,0,0,0],
	klankTimes=#[0,0,0,0,0],
	klankWet=0.5;
	var snd, delay, klank;

	snd = In.ar(in,2);

	klank = DynKlank.ar(Ref([
		klankFreqs,klankAmps,klankTimes
	]), snd,freqoffset:SinOsc.kr(1/10,0,10)).distort;
	snd = XFade2.ar(snd,klank,klankWet.linlin(0,1,-1,1));

	delay = SwitchDelay.ar(snd,1,delayWet, delayTime,delayfactor);
	snd = delay;

	Out.ar(out,snd);
}).add;


SynthDef(\julio1Bass1, {arg out=0, freq=100, amp=0.5, gate=1,
	ampAttackTime=0.1, ampDecayTime=0.1,
	ampSustainLevel=0.5, ampReleaseTime=0.3,
	lpFreqFac=2.0,lpRq=1,
	lpAttackTime=0.1, lpDecayTime=0.1,
	lpSustainLevel=0.5, lpReleaseTime=0.3,
	lpEnvDepth=1,
	knackTriggerFreq=0;

	var snd, lp, freqMod, origFreq, knack, knackTrigger;

	freqMod = SinOsc.kr(freq * 2.0);
	//freqMod = freqMod.fold(-0.9,0.9).tanh;
	freqMod = freqMod * (freq * 0.2);

	origFreq = freq;
	freq = freq + freqMod;


	snd = DPW3Tri.ar(freq) +
	      Pulse.ar(freq+0.1,0.1) +
	SinOsc.ar((origFreq/2)-0.1,0);

	snd = snd + Mix.new(CombC.ar(Ringz.ar(snd,origFreq*[5,6],3,2).tanh,0.2,(freq*[2,4,7]).reciprocal,2).distort);

	knackTrigger = Dust.kr(knackTriggerFreq);
	lpFreqFac = lpFreqFac + TRand.kr((lpFreqFac/4)*(-1),(lpFreqFac/4),knackTrigger);

	lp = RLPF.ar(
		snd,
		origFreq * (lpFreqFac + EnvGen.kr(Env.adsr(
			lpAttackTime, lpDecayTime,
			lpSustainLevel, lpReleaseTime
		),gate,lpEnvDepth)),
		lpRq
	);
	snd = lp;

	snd = snd + PinkNoise.ar(0.3);

	knack = RLPF.ar(
		(
			EnvGen.ar(
				Env.linen(0.01,0.01,0, 5),
				knackTrigger
			)*LFNoise0.ar(5)
		).softclip,
		[50,1000],
		[0.1,1.5],
		[0,0]
	).softclip;
	knack = Mix.ar(knack);

	snd = snd + knack;

	snd = snd * EnvGen.kr(
		Env.adsr(
			ampAttackTime,
			ampDecayTime,
			ampSustainLevel,
			ampReleaseTime,
		),gate,doneAction:2
	) * amp;

	snd = CompanderD.ar(snd,0.8,1,0.1,0.01,0.01);

	Out.ar(out, snd.dup);
}).add;

SynthDef(\julio1Schweb1, {arg
	out = 0,
	bufnumLeft, bufnumRight, grainEnvelopeBufnum,
	t_trigger = 1,
	grainRate = 10, grainRateVar = 0, grainDuration = 0.1, grainDurationVar = 0,
	pos1 = 0, pos2 = 1, startPosition = 0, posVar = 0, posRate = 1,
	grainPitch = 1, grainPitchVar = 0,
	grainAmp = 0.5, gate = 1,
	attackTime = 0.1, decayTime = 0, sustainLevel = 1, releaseTime = 0.1;

	var snd, pos, grainTrigger, grains;
	var env, envGen, envLength, envTrigger, asr;

	grainTrigger = Impulse.kr(grainRate + LFNoise0.kr(grainRate,grainRateVar));

	posRate = (BufRateScale.kr(bufnumLeft)/BufDur.kr(bufnumLeft))  *posRate;
	pos = RDPhasor.ar(t_trigger,pos1,pos2,startPosition,-1,posRate,1);
	pos = TRand.kr(pos-posVar,pos+posVar,grainTrigger).clip(0,1);

	grainPitch = TRand.kr(
		grainPitch-grainPitchVar,
		grainPitch+grainPitchVar,
		grainTrigger
	);

	grainDuration = TRand.kr(
		grainDuration-grainDurationVar,
		grainDuration+grainDurationVar,
		grainTrigger
	);

	grains = GrainBuf.ar (
		numChannels: 1,
		trigger: grainTrigger,
		dur: grainDuration,
		sndbuf: [bufnumLeft,bufnumRight],
		rate: grainPitch,
		pos: pos,
		interp: 4,
		pan: [-1,1],
		envbufnum: grainEnvelopeBufnum,
		maxGrains: 512,
		mul: grainAmp
	);

	snd = grains;

	snd = snd * EnvGen.kr(
		Env.adsr(attackTime,decayTime,sustainLevel,releaseTime),
		gate,
		doneAction:2
	);

	Out.ar(out, snd);
}).add;

SynthDef(\julio1Schweb1Fx, {arg in, out,
	hpFreq=440, hpRq=1, drive=1,
	combFreq=440,combDecay=1, wet=0.5;
	var snd, hp;
	snd = In.ar(in,2);
	hp = CombC.ar(snd,0.2,(hpFreq-400+LFNoise2.kr(1/3,40)).reciprocal,combDecay);
	hp = RHPF.ar(hp,hpFreq, hpRq);
	hp = (hp*drive).distort;
	snd = XFade2.ar(snd, hp, wet.linlin(0,1,-1,1));
	Out.ar(out,snd);
}).add;


SynthDef(\julio1Schweb2, {arg
	out = 0,
	bufnumLeft, bufnumRight, grainEnvelopeBufnum,
	t_trigger = 1,
	grainRate = 10, grainRateVar = 0, grainDuration = 0.1, grainDurationVar = 0,
	pos1 = 0, pos2 = 1, startPosition = 0, posVar = 0, posRate = 1,
	grainPitch = 1, grainPitchVar = 0,
	grainAmp = 0.5, gate = 1,
	attackTime = 0.1, decayTime = 0, sustainLevel = 1, releaseTime = 0.1;

	var snd, pos, grainTrigger, grains;
	var env, envGen, envLength, envTrigger, asr;

	grainTrigger = Impulse.kr(grainRate + LFNoise0.kr(grainRate,grainRateVar));

	posRate = (BufRateScale.kr(bufnumLeft)/BufDur.kr(bufnumLeft))  *posRate;
	pos = RDPhasor.ar(t_trigger,pos1,pos2,startPosition,-1,posRate,1);
	pos = TRand.kr(pos-posVar,pos+posVar,grainTrigger).clip(0,1);

	grainPitch = TRand.kr(
		grainPitch-grainPitchVar,
		grainPitch+grainPitchVar,
		grainTrigger
	);

	grainDuration = TRand.kr(
		grainDuration-grainDurationVar,
		grainDuration+grainDurationVar,
		grainTrigger
	);

	grains = GrainBuf.ar (
		numChannels: 2,
		trigger: grainTrigger,
		dur: grainDuration,
		sndbuf: [bufnumLeft,bufnumRight],
		rate: grainPitch,
		pos: pos,
		interp: 4,
		pan: [-1,1],
		envbufnum: grainEnvelopeBufnum,
		maxGrains: 512,
		mul: grainAmp
	);

	snd = grains;

	snd = snd * EnvGen.kr(
		Env.adsr(attackTime,decayTime,sustainLevel,releaseTime),
		gate,
		doneAction:2
	);

	Out.ar(out, snd);
}).add;

SynthDef(\julio1Schweb2Fx, {arg in, out,
	hpFreq=440, hpRq=1, drive=1,
	combFreq=440,combDecay=1;
	var snd, hp;

	snd = In.ar(in,2);

	hp = CombC.ar(snd,0.2,(hpFreq-400+LFNoise2.kr(1/3,40)).reciprocal,combDecay);
	hp = RHPF.ar(hp,hpFreq, hpRq);
	hp = (hp*drive).distort;


	snd = snd + hp;


	Out.ar(out,snd);
}).add;


SynthDef(\rdAmp2, {|out=0, in, amp, lagTime=0|
	Out.ar(out,Lag.kr(amp,lagTime)*In.ar(in,2));
}).add;
)