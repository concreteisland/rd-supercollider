(
Instr(\capacitator, {arg in = 0, max=1, trigger = 1;
	var signal, outTrigger;
	signal = Phasor.ar(trigger, in, 0, max, 0);
	outTrigger = (HPZ1.ar(signal) < 0);
	[signal, outTrigger]
});

Instr(\hpzCap, {arg in=0, max=1, trigger=1;
	var signal, outTrigger, hpz;
	hpz = HPZ1.ar(in,2).abs;
	#signal, outTrigger = Instr(\capacitator).ar(hpz, max, trigger);
	[signal, outTrigger];
});
)


(
Instr(\cell, {arg
	in = 0,
	max=1,
	trigger=1,
	trigger2=1,
	in2;

	var cap, capTrigger, sh1, sh2, osc;

	#cap, capTrigger = Instr(\hpzCap).ar(in, max, 0);

	cap = cap.linlin(0,max,0,1);
	sh1 = Latch.ar(cap, trigger);
	sh2 = Latch.ar(in2.linlin(-1,1,0,1), capTrigger);

	osc = SinOsc.ar(sh1.linlin(0,1,5,7),0,sh2);

	[cap, capTrigger, sh1, sh2, osc];
});
)





~buffer = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");


(
Ndef(\capCellsInput, {
	var snd, onset, onsetSnd;
	snd = PlayBuf.ar(1,~buffer.bufnum,loop:1);
	onset = Coyote.kr(snd);
	onsetSnd = SinOsc.ar * EnvGen.kr(Env.perc(0.01,0.1),onset);
	//[snd, onsetSnd];
	[snd, K2A.ar(onset)];
});
)

Ndef(\capCellsInput).play
Ndef(\capCellsInput).stop
Ndef(\capCellsInput).clear


(
Ndef(\capCells, {
	var in, max, trigger, in2, trigger2;
	var cell1Cap, cell1CapTrigger, cell1Sh1, cell1Sh2, cell1Osc;
	var cell2Cap, cell2CapTrigger, cell2Sh1, cell2Sh2, cell2Osc;
	var fbNode;
	var snd;


	#in, trigger = Ndef(\capCellsInput).ar;
	max = 130;
	in2 = SinOsc.ar(100);

	#cell1Cap, cell1CapTrigger, cell1Sh1, cell1Sh2, cell1Osc = Instr(\cell).ar(
		in,
		max,
		trigger,
		0,
		in2
	);

	/*
	#cell2Cap, cell2CapTrigger, cell2Sh1, cell2Sh2, cell2Osc = Instr(\cell).ar(
		cell1Osc,
		cell1Sh1,
		1,
		cell1CapTrigger,
		cell1Sh2,
	);
	*/

	snd = SinOsc.ar([cell1Sh1,cell1Sh2].linexp(0,1,50,1000),0,0.3);

	snd.poll;

	[
		in, trigger,
		cell1Cap, cell1CapTrigger, cell1Sh1, cell1Sh2, cell1Osc,
		//cell2Cap, cell2CapTrigger, cell2Sh1, cell2Sh2, cell2Osc,
	];

	snd;
})
)

Ndef(\capCells).plot(1)
Ndef(\capCells).stop
Ndef(\capCells).play
Ndef(\capCells).clear
