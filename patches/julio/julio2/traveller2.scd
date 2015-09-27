(
Ndef(\traveller02, {
	var snd;
	var freq;

	freq = 60;

	freq = freq + LagUD.kr(
		LFNoise0.kr([18,18]).lincurve(-1,1,0.0001,20000-freq,20),
		SinOsc.kr(0.2).exprange(0.01,0.3),
		SinOsc.kr(0.3).range(0.001,0.005)
	);

	snd = VarSaw.ar(freq,0,0.1);
	snd = (snd + snd.tanh);

	snd = RLPF.ar(snd,1200,0.5);

	Pan2.ar(snd,0);
});
)

Ndef(\traveller02).play