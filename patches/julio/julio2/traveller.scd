(
Ndef(\travel01, {arg freq=220;
	var snd, baseFreq, x;
	var trigger, gate;

	trigger = Impulse.kr(0.8.reciprocal);
	gate = Trig.kr(trigger,0.3);

	baseFreq = [freq,freq*1.002];

	x = 1.333+(SinOsc.kr(baseFreq[0]*2.2,0,0.3));

		//Phasor.kr(1,(44100*2).reciprocal,0,0.3)));//+Phasor.kr(1,(44100*2).reciprocal*(-1),0.4,0);

	freq = Array.geom(7,baseFreq,x).clip(0,20000);

	freq = freq + SawDPW.kr(
		Array.geom(7,baseFreq*(0.5+SinOsc.kr(10,0,0.01)),x*1).clip(0,20000),
		0,
		freq * Array.series(7,0.8,-0.1)
	);

	snd = SinOsc.ar(freq,0,Array.geom(7,1,0.633););
	snd = RLPF.ar(snd, baseFreq*8, 2, 1);
	snd = Mix(snd);
	snd = RLPF.ar(snd,(baseFreq/2)+EnvGen.kr(Env.linen(0.01,0,1,1,-3),trigger,1000),1.5);
	snd = snd * EnvGen.kr(Env.adsr(0.05,0.2,0.2,0.6),gate);

	Pan2.ar(snd,0,0.1);
});
)

Ndef(\travel01).play;
Ndef(\travel01).stop;
s.scope(2);



