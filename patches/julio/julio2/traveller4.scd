(
Ndef(\blipp, {
	var snd;
	var freq = [26,1280];
	freq = [freq,freq.reverse];

	snd = Blip.ar(
		freq + SinOsc.ar(
			freq/(2+(LFNoise2.kr(4))),
			0,
			freq*(LFNoise2.kr(0.4).range(0,1))
		),
		[
			80,
			10+LFNoise2.kr(0.2).range(-4,4)
		]
	);

	snd = RLPF.ar(snd,freq*[7,3],0.2,[2,3]).tanh;
	//snd = Mix(snd);
	snd = RLPF.ar(snd,6300,2,1);

	Pan2.ar(snd,0,0.3);
});
)

Ndef(\blipp).play

s.scope
