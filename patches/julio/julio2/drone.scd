(
Ndef(\folder, {
	var freq=[3356,3356.5], snd, folder, hpf, klank, comb;
	snd = SinOsc.ar(freq+SinOsc.kr(freq*3.03,0,freq*0.8),0,1);

/*		comb = EnvGen.kr(
		Env.linen(1,0,1.6,0,0),
		Impulse.kr(0.4)
	) * CombC.ar(snd,0.2,0.2,0.2,1);
*/


	//snd = snd + comb;

	folder = SinOsc.kr(freq/2).range(
		LFNoise2.kr(0.3).range(0.2,0.5),
		LFNoise2.kr(0.1).range(0.5,1)
	);
	snd = snd.wrap(folder*(-1), folder);

	klank = DynKlank.ar(Ref([
		[freq/8,freq*3.333,(freq*2.444)+SinOsc.kr(0.2).range(-100,100)],
			[0.1,0.2,0.04],
		[0.1,0.1,SinOsc.kr(0.1).range(0.05,0.1)]
		]),snd);

	snd = snd+klank;// * EnvGen.kr(Env.perc(0.01,1.3),Impulse.kr(0.4));

	hpf = BBandPass.ar(
		snd,
		freq*1.3,0.3,0.75);
	snd = RLPF.ar(snd,80,0.2,5,0);
	snd = snd+ hpf;
	snd = LeakDC.ar(snd);

	snd;
})
)

Ndef(\folder).play

s.scope(2)

({
	var snd, folder, folded;
	snd = SinOsc.ar(100,0,1).dup;
	folder = SinOsc.kr(120,0,0.5,0.5);
	folded = snd.wrap(folder*(-1), folder);
	folded = LeakDC.ar(folded);
	[snd,folder,folded];

}.plot(0.1))