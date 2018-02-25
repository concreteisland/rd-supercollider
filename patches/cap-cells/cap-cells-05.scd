(
Instr(\capacitorCellsInput, {arg bufnum;
	var snd;
	snd = PlayBuf.ar(1,bufnum,loop:1).dup;
	snd;
});
)
(
Instr(\capacitor, {arg in = 0, max=1, trigger = 1;
	var signal, outTrigger;
	signal = Phasor.ar(trigger, in.thresh(0), 0, max, 0);
	outTrigger = (HPZ1.ar(signal) < 0);
	[signal, outTrigger]
});

Instr(\capacitorLatch, {arg
	capacitorIn, capacity, triggerRelease, latchIn;

	var capacitor, capacitorOutTrigger, latch;

	#capacitor, capacitorOutTrigger = Instr(\capacitor).ar(capacitorIn, capacity, triggerRelease);
	capacitor = capacitor.linlin(0,capacity,0,1);

	latch = Latch.ar(latchIn, capacitorOutTrigger);

	[capacitor, capacitorOutTrigger, latch];
});
)

(
Instr(\capacitorLatchHPZFormlet, {arg
	in, capacity, triggerRelease,
	formletFreqMin, formletFreqMax, latchIn;

	var inHPZ, out;
	var capacitor, capacitorOutTrigger, latch;

	inHPZ = HPZ1.ar(in);

	#capacitor, capacitorOutTrigger, latch = Instr(\capacitorLatch).ar(
		inHPZ, capacity, triggerRelease, latchIn
	);

	out = Formlet.ar(in,latch.exprange(formletFreqMin, formletFreqMax),0.1,0.11).softclip;

	[capacitor, capacitorOutTrigger, latch, out];
});
//)
//(
Instr(\capacitorCells, {arg bufnum, capacity1, capacity2, capacity3;

	var in;
	var cell1Capacitor, cell1CapacitorOutTrigger, cell1Latch, cell1Out;
	var cell2Capacitor, cell2CapacitorOutTrigger, cell2Latch, cell2Out;
	var cell3Capacitor, cell3CapacitorOutTrigger, cell3Latch, cell3Out;

	in = Instr(\capacitorCellsInput).ar(bufnum);
	in = in[0];

	#cell1Capacitor, cell1CapacitorOutTrigger, cell1Latch, cell1Out = Instr(\capacitorLatchHPZFormlet).ar(
		in, capacity1, 0, 20, 20000, in
	);

	#cell2Capacitor, cell2CapacitorOutTrigger, cell2Latch, cell2Out = Instr(\capacitorLatchHPZFormlet).ar(
		cell1Out, capacity2, 0, 20, 20000, cell1Out
	);

	#cell3Capacitor, cell3CapacitorOutTrigger, cell3Latch, cell3Out = Instr(\capacitorLatchHPZFormlet).ar(
		cell2Out, capacity3, 0, 20, 20000, cell2Out
	);


	[
		cell1Capacitor, cell1CapacitorOutTrigger, cell1Latch, cell1Out,
		cell2Capacitor, cell2CapacitorOutTrigger, cell2Latch, cell2Out,
		cell3Capacitor, cell3CapacitorOutTrigger, cell3Latch, cell3Out,
	].clump(4).flop.flatten;
});
//)
//(
Ndef(\capacitorCells, {
	var ctrl = Instr(\capacitorCells).func.value(
		~buffer.bufnum, 1200, 60, 61
	);
	ctrl;
});

Ndef(\capSound, {
	var ctrl = Ndef(\capacitorCells).ar;
	var snd;
	ctrl = ctrl.clump(3);
	snd = SinOsc.ar(ctrl[2].exprange(50, 1050));
	snd = Mix(snd)*(1/3).dup;
	snd;
})
)

Ndef(\capacitorCells).play
Ndef(\capacitorCells).plot(3)
Ndef(\capacitorCells).scope
Ndef(\capacitorCells).clear

Ndef(\capSound).play
Ndef(\capSound).scope
Ndef(\capSound).clear



~buffer = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

