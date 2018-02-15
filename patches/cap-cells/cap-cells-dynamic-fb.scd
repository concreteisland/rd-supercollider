(
Instr(\capacitor, {arg in = 0, max=1, trigger = 1;
	var signal, outTrigger;
	signal = Phasor.ar(trigger, in, 0, max, 0);
	outTrigger = (HPZ1.ar(signal) < 0);
	[signal, outTrigger]
});

Instr(\capacitorCell, {arg 
	in, capacity, triggerRelease,
	sLo, sHi,
	fb, fbDelay, fbMaxDelay,
	inShape, outShape, fbShape;
	
	var fbNode, feedback;
	var capacitor, capTrigger;
	var shTrigger, sh;
	
	//fbNode = FbNode(1,fbMaxDelay);
	//feedback = fbNode.delay(fbDelay);
	//feedback = feedback.lincurve(0,1,0,1,fbShape);
	//feedback = feedback * fb;
	
	in = in.abs.clip(0,1);
	//in = in + feedback;
	//in = in.lincurve(0,1,0,1,inShape); 
	
	#capacitor, capTrigger = Instr(\capacitor).ar(in, capacity, triggerRelease);
	capacitor = capacitor.linlin(0,capacity,0,1);
	//capacitor = capacitor.lincurve(0,1,0,1,outShape);
	//fbNode.write(capacitor);
	
	shTrigger = Schmidt.ar(in, sLo, sHi);
	in.poll;
	sh = Latch.ar(capacitor, shTrigger);
	
	[capacitor, capTrigger, sh];
});

Instr(\capacitorCellsInput, {arg bufnum;
	var snd;
	snd = PlayBuf.ar(1,bufnum,loop:1).dup;
	snd;
});

Instr(\capacitorCells, {arg bufnum,
	capacity1,
	sLo1, sHi1,
	fb1, fbDelay1, fbMaxDelay1,
	inShape1, outShape1, fbShape1;	
	
	var in, triggerRelease;
	var cell1Cap, cell1CapTrigger, cell1Sh;
	var snd;

	in = Instr(\capacitorCellsInput).ar(bufnum);
	triggerRelease = Coyote.kr(in);
	

	#cell1Cap, cell1CapTrigger, cell1Sh = Instr(\capacitorCell).ar(
		in[0], capacity1, triggerRelease,
		sLo1, sHi1,
		fb1, fbDelay1, fbMaxDelay1,
		inShape1, outShape1, fbShape1;
	);

	[cell1Cap, cell1Sh];
});
)
(
Ndef(\capacitorCells, {
	var snd = Instr(\capacitorCells).func.value(~buffer.bufnum, 100, 0.1, 0.2);
	snd;
});
)

Ndef(\capacitorCells).play
Ndef(\capacitorCells).plot



~buffer = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");


