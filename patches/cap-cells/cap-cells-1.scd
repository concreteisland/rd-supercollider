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

	#cap, capTrigger = Instr(\hpzCap).ar(in, max, trigger);

	sh1 = Latch.ar(cap, trigger2);
	sh2 = Latch.ar(in2, capTrigger);

	osc = SinOsc.ar(sh1.linlin(0,max,50,70),0);

	[cap, capTrigger, sh1, sh2, osc];
});
)





~buffer = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

(
{
	var in, max, trigger, in2, trigger2;
	var cell1Cap, cell1CapTrigger, cell1Sh1, cell1Sh2, cell1Osc;
	var cell2Cap, cell2CapTrigger, cell2Sh1, cell2Sh2, cell2Osc;
	var fbNode;

	in = PlayBuf.ar(1,~buffer.bufnum,loop:1);
	max = 30;
	//trigger = Impulse.ar(3);
	trigger2 = Impulse.ar(10);
	in2 = SinOsc.ar(100);

	#cell1Cap, cell1CapTrigger, cell1Sh1, cell1Sh2, cell1Osc = Instr(\cell).ar(
		in,
		max,
		1,
		trigger2,
		in2
	);

	#cell2Cap, cell2CapTrigger, cell2Sh1, cell2Sh2, cell2Osc = Instr(\cell).ar(
		cell1Osc,
		cell1Sh1,
		1,
		cell1CapTrigger,
		cell1Sh2,
	);

	[
		in,
		//cell1Cap, cell1CapTrigger, cell1Sh1, cell1Sh2, cell1Osc,
		cell2Cap, cell2CapTrigger, cell2Sh1, cell2Sh2, cell2Osc,
	] * [
		1,max.reciprocal,1,max.reciprocal,1,1,
	];
}.plot(4.3);
)
