~julio1.klink1 = ();
~julio1.klink1.mixerChannel1 = MixerChannel.new('klink1',s,2,2);
~julio1.klink1.launcher = RDSynthLauncher();




~julio1.klink1.launcher.setConfig(\a,
	RDSynthConfig(\julio1Klink1, [
		\out, ~julio1.klink1.mixerChannel1.asBus.index,
		], {~julio1.groups.sndSrc.group}
	)
);





(
SynthDef(\julio1Klink1, {arg out=0;
	var snd, comb, combLp, combHp, onset;

	snd = SoundIn.ar([0,1]);

	onset = Coyote.kr(snd,0.2,0.2,0.01,0.5,0.05,0.1);

	snd = CompanderD.ar(snd,0.6,1,0.01,0.001,0.01,2);

	//snd = snd + FreqShift.ar(snd,-300);

	comb = CombFormlet.ar(snd,TRand.kr(30,3000,onset).lag(0.05), 0.01,0.5,40).distort;

	comb = CrossoverDistortion.ar(comb,TRand.kr(0,0.8,onset),0.2);
	combLp = RLPF.ar(comb,70,0.1,17);
	combHp = RHPF.ar(comb,1100,0.1);
	//combHp = BBandPass.ar(comb,TRand.kr(100,4000,onset),1);
	comb = (combLp+combHp).tanh;
	comb = comb *
	EnvGen.kr(
		Env.linen(0.01,TExpRand.kr(0.1,3,onset),1,1,\lin),CoinGate.kr(0.5,onset),1);
	comb = comb*TExpRand.kr(0.001,1,onset);
	comb = FreeVerb2.ar(comb[0], comb[1], mix: 0.1, room: 0.5, damp: 0.5, mul: 1, add: 0);



	snd = snd+comb;

		snd = CompanderD.ar(snd,0.6,1,0.01,0.001,0.01,2);

	Out.ar(out,snd);
}).add;
~julio1.klink1.launcher.synthNodes[0].free;
~julio1.klink1.launcher.on(0, \a);
)

s.makeGui

