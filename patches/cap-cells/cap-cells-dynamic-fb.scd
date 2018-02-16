(
Instr(\capacitor, {arg in = 0, max=1, trigger = 1;
	var signal, outTrigger;
	signal = Phasor.ar(trigger, in.thresh(0), 0, max, 0);
	outTrigger = (HPZ1.ar(signal) < 0);
	[signal, outTrigger]
});

Instr(\capacitorCell, {arg
	in,
	capacity,
	triggerRelease,
	triggerSwitch,
	shape,
	sLo, sHi,
	fb, fbDelay;

	var fbNode, feedback;
	var capacitor, capTrigger, sampleAndHold, schmidt;

	fbNode = FbNode(1,1,4);
	feedback = fbNode.delay(fbDelay);
	//feedback = feedback.lincurve(0,1,0,1,fbShape);
	feedback = feedback * fb;
	in = in + feedback;

	#capacitor, capTrigger = Instr(\capacitor).ar(in, capacity, triggerRelease);
	capacitor = capacitor.linlin(0,capacity,0,1);
	capacitor = capacitor.lincurve(0,1,0,1,shape);
	fbNode.write(capacitor);

	sampleAndHold = Latch.ar(capacitor, triggerSwitch);
	schmidt = HPZ1.ar(Schmidt.ar(sampleAndHold, sLo, sHi))>0;

	[capacitor, capTrigger, sampleAndHold, schmidt];
});

Instr(\capacitorCellsInput, {arg bufnum;
	var snd;
	snd = PlayBuf.ar(1,bufnum,loop:1).dup;
	snd;
});

Instr(\capacitorCells, {arg bufnum,
	capacity1, shape1, sLo1, sHi1, fb1, fbDelay1,
	capacity2, shape2, sLo2, sHi2, fb2, fbDelay2;

	var in, triggerRelease, triggerSwitch;
	var cell1Cap, cell1CapTrigger, cell1Sh, cell1Schmidt;
	var cell2Cap, cell2CapTrigger, cell2Sh, cell2Schmidt;
	var snd;
	var fbNode, feedback;

	in = Instr(\capacitorCellsInput).ar(bufnum);
	snd = in;
	in = in[0];
	triggerSwitch = Coyote.kr(in);

	fbNode = FbNode(2,1,4);
	feedback = fbNode.delay(SampleDur.ir);

	triggerSwitch = triggerSwitch + feedback[0];
	triggerRelease = feedback[1];

	#cell1Cap, cell1CapTrigger, cell1Sh, cell1Schmidt = Instr(\capacitorCell).ar(
		HPZ1.ar(in).abs,
		capacity1,
		triggerRelease,
		triggerSwitch,
		shape1,
		sLo1, sHi1,
		fb1, fbDelay1
	);

	#cell2Cap, cell2CapTrigger, cell2Sh, cell2Schmidt = Instr(\capacitorCell).ar(
		cell1Sh,
		capacity2,
		cell1Schmidt,
		cell1CapTrigger,
		shape2,
		sLo2, sHi2,
		fb2, fbDelay2
	);

	fbNode.write([cell2CapTrigger, cell2Schmidt]);

	[cell1Cap, cell1CapTrigger, cell1Sh, cell1Schmidt] ++
	[cell2Cap, cell2CapTrigger, cell2Sh, cell2Schmidt];
});
//)
//(
Ndef(\capacitorCells, {arg bufnum,
	capacity1, shape1, sLo1, sHi1, fb1, fbDelay1,
	capacity2, shape2, sLo2, sHi2, fb2, fbDelay2;

	var snd = Instr(\capacitorCells).func.value(
		bufnum,
		capacity1, shape1, sLo1, sHi1, fb1, fbDelay1,
		capacity2, shape2, sLo2, sHi2, fb2, fbDelay2
	);
	snd;
});
)

(
Ndef(\capacitorCells).set(
	\bufnum, ~buffer.bufnum,
	\capacity1, 1000, \shape1, 3, \sLo1, 0.1, \sHi1, 0.3, \fb1, 0.04, \fbDelay1, 0.8,
	\capacity2, 10000, \shape2, -0.3, \sLo2, 0.6, \sHi2, 0.7, \fb2, 0.04, \fbDelay2, 0.8
);
)

Ndef(\capacitorCells).play
Ndef(\capacitorCells).plot
Ndef(\capacitorCells).clear
Ndef(\capacitorCells).scope



~buffer = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");


