
(
Ndef(\multitap, {
	var snd;
	var fbNode, fb;
	var delay1, delay2, delay3, delay4, delay5, delay6, delay7, delay8, delay;
	var feedback = 1.0;

	fbNode = FbNode(1,1);
	fb = fbNode.delay(1/SampleRate.ir);

	delay1 = DelayC.ar(fb,        0.2, 0.2, 0.4);
	delay2 = DelayC.ar(delay1, 0.2, 0.181, 0.5);
	delay3 = DelayC.ar(delay2, 0.2, 0.02, 0.4);
	delay4 = DelayC.ar(delay3, 0.2, 0.13, 0.5);
	delay5 = DelayC.ar(delay4, 0.2, 0.2, 0.6);
	delay6 = DelayC.ar(delay5, 0.2, 0.1, 0.7);
	delay7 = DelayC.ar(delay6, 0.2, 0.15, 0.3);
	delay8 = DelayC.ar(delay7, 0.2, 0.2, 0.2);

	delay = (delay1 + delay2 + delay3 + delay4 + delay5 + delay6 + delay7 + delay8) * feedback;


	snd = SinOsc.ar(LFNoise0.ar(1/3).range(100, 300));
	snd = snd * EnvGen.kr(Env.perc(0.1, 2), Impulse.kr(1/3));
	snd = snd + delay;

	fbNode.write(snd);

	LeakDC.ar(snd);

})
)


Ndef(\multitap).scope
Ndef(\multitap).plot(0.2)
Ndef(\multitap).play
