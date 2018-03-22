(
Instr(\capacitorCellsInput, {arg bufnum;
	var snd;
	snd = PlayBuf.ar(1,bufnum,loop:1).dup;
	snd*1;
});
)
(
Instr(\capacitor, {arg in = 0, max=1, trigger = 1;
	var signal, outTrigger, time;
	signal = Phasor.ar(trigger, in.thresh(0), 0, max, 0);
	outTrigger = (HPZ1.ar(signal) < 0);
	time = Timer.ar(outTrigger + Impulse.ar(0));
	[signal, outTrigger, time];
});

Instr(\capacitorLatch, {arg
	capacitorIn, capacity, triggerRelease, latchIn;

	var capacitor, capacitorOutTrigger, latch, capacitorTime;

	#capacitor, capacitorOutTrigger, capacitorTime = Instr(\capacitor).ar(capacitorIn, capacity, triggerRelease);
	capacitor = capacitor.linlin(0,capacity,0,1);

	latch = Latch.ar(latchIn, capacitorOutTrigger);

	[capacitor, capacitorOutTrigger, latch, capacitorTime];
});
)

(
Instr(\capacitorLatchHPZFormlet, {arg
	in, capacity, triggerRelease,
	formletFreqMin, formletFreqMax, latchIn;

	var inHPZ, out, osc;
	var capacitor, capacitorOutTrigger, latch, capacitorTime;

	inHPZ = HPZ1.ar(in);

	#capacitor, capacitorOutTrigger, latch, capacitorTime = Instr(\capacitorLatch).ar(
		inHPZ, capacity, triggerRelease, latchIn
	);

	out = Formlet.ar(in,latch.exprange(formletFreqMin, formletFreqMax),0.01,0.1).softclip;

	osc = SinOsc.ar(capacitorTime.reciprocal);

	[capacitor, capacitorOutTrigger, latch, out, osc];
});
//)
//(
Instr(\capacitorCells, {arg bufnum, capacity1, capacity2, capacity3;

	var in;
	var fbNode;
	var cell1Capacitor, cell1CapacitorOutTrigger, cell1Latch, cell1Out, cell1Osc;
	var cell2Capacitor, cell2CapacitorOutTrigger, cell2Latch, cell2Out, cell2Osc;
	var cell3Capacitor, cell3CapacitorOutTrigger, cell3Latch, cell3Out, cell3Osc;

	in = Instr(\capacitorCellsInput).ar(bufnum);
	in = in[0];

	fbNode = FbNode(1,1,4);
	cell3Osc = fbNode.delay(SampleDur.ir);

	#cell1Capacitor, cell1CapacitorOutTrigger, cell1Latch, cell1Out, cell1Osc = Instr(\capacitorLatchHPZFormlet).ar(
		in, capacity1, 0, 20, 20000, cell3Osc
	);

	#cell2Capacitor, cell2CapacitorOutTrigger, cell2Latch, cell2Out, cell2Osc = Instr(\capacitorLatchHPZFormlet).ar(
		cell1Out, capacity2, 0, 20, 20000, cell1Osc
	);

	#cell3Capacitor, cell3CapacitorOutTrigger, cell3Latch, cell3Out, cell3Osc = Instr(\capacitorLatchHPZFormlet).ar(
		cell2Out, capacity3, 0, 20, 20000, cell2Osc
	);

	fbNode.write(cell3Osc);


	[
		cell1Capacitor, cell1CapacitorOutTrigger, cell1Latch, cell1Out, cell1Osc,
		cell2Capacitor, cell2CapacitorOutTrigger, cell2Latch, cell2Out, cell2Osc,
		cell3Capacitor, cell3CapacitorOutTrigger, cell3Latch, cell3Out, cell3Osc
	].clump(5).flop.flatten;
});
//)
//(
Ndef(\capacitorCells, {
	var ctrl = Instr(\capacitorCells).func.value(
		~buffer.bufnum, 1000, 1560, 2610
	);
	ctrl;
});

Ndef(\capSound, {
	var ctrl = Ndef(\capacitorCells).ar;
	var snd;
	ctrl = ctrl.clump(3);
	snd = SinOsc.ar(ctrl[2].exprange(50, 1050));
	snd = snd * EnvGen.ar(Env.perc,ctrl[1]);
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


//---------------

(
Ndef(\capSound, {
	var ctrl = Ndef(\capacitorCells).ar;
	var snd;
	var grainDensity = K2A.ar(4), grainDensityVar = K2A.ar(0),
		grainRate = K2A.ar(0), grainRateVar = K2A.ar(0),
		grainDur = K2A.ar(10), grainDurVar = K2A.ar(2), //ms
		grainPosition, grainPositionVar = K2A.ar(0),  // range 0-1
		grainPitch = K2A.ar(0.8),
		mode = K2A.ar(1),
		grainAmp = K2A.ar(1);

	ctrl = ctrl.clump(3);

	grainPosition = ctrl[2][0].range(0.65,75).lag(2);

	grainDur = ctrl[2][2].range(5,34);
	grainDurVar = grainDur * 0.2;
	grainPositionVar = grainDur / 5000;
	grainDensity = ctrl[2][1].lincurve(-1,1,0.3,1.3,-3);

	//snd = SinOsc.ar(ctrl[2].exprange(50, 1050));
	//snd = snd * EnvGen.ar(Env.perc,ctrl[1]);
	//snd = Mix(snd)*(1/3).dup;

	snd = Instr(\grains).ar(
		[~file1_0.bufnum, ~file1_1.bufnum],
		~envelopeBuffer.bufnum,
		grainDensity, grainDensityVar,
		grainRate, grainRateVar,
		grainDur, grainDurVar,
		grainPosition, grainPositionVar,
		grainPitch, mode, grainAmp
	);//* EnvGen.ar(Env.linen(0.1,2,0.1), ctrl[1][1]);


	snd = RHPF.ar(snd,70,1);
	snd = AudioMSG.ar(snd,0.3);
	//snd = RLPF.ar(snd,ctrl[2][3].lincurve(-1,1,600,10400,-2).poll,1);
	snd = SwitchDelay.ar(snd,1,0.1,0.3333,0.5,20);

	snd;
});
)

Ndef(\capacitorCells).play
Ndef(\capacitorCells).plot(3)
Ndef(\capacitorCells).scope
Ndef(\capacitorCells).clear

Ndef(\capSound).play
Ndef(\capSound).scope
Ndef(\capSound).clear


~basePath = PathName(thisProcess.nowExecutingPath).pathOnly +/+ "src";
~file1Path = ~basePath +/+ "mettscrap.wav";
~file1Path = ~basePath +/+ "blos.wav";
~file1_0 = Buffer.readChannel(s,~file1Path,channels:0);
~file1_1 = Buffer.readChannel(s,~file1Path,channels:1);
RDBufferUtils.createSineEnvelopeBuffer(0.1, 0.1, 1024, s,
	~envelopeBuffer, {|buffer|
		~envelopeBuffer = buffer;

	}
);



(
Instr(\grains,  {arg
	bufnum = #[0,0],
	grainEnvelopeBufnum=(-1),
	grainDensity = 1, grainDensityVar = 0,
	grainRate = 1, grainRateVar = 0,
	grainDur = 100, grainDurVar = 0, //ms
	grainPosition = 0.5, grainPositionVar = 0,  // range 0-1
	grainPitch = 1,
	mode = 0,
	grainAmp = 1;

	//mode:
	//0: grainRate, grainDur
	//1: calculatedGrainRate, grainDur
	//2: grainRate, calculatedGrainDur

	var bufferFrames = BufFrames.kr(bufnum[0]);
	var grains, grainTrigger;
	var calculatedGrainDensity, calculatedGrainRate, calculatedGrainDur;
	var grainRateMod, grainPositionMod, grainDurMod, grainDensityMod;

	grainDur = grainDur /1000; //ms, scale duration to sec;
	grainDurVar = grainDurVar /1000;

	// MODULATION

	grainDensityMod = LFDNoise3.ar(100,grainDensityVar);
	grainDensity = grainDensity + grainDensityMod;

	//-----------------------------------------
	calculatedGrainDensity = grainRate * grainDur;
	calculatedGrainRate = grainDensity / grainDur;
	calculatedGrainDur = grainDensity / grainRate;

	grainRate = Select.ar(mode, [grainRate, calculatedGrainRate, grainRate]);
	grainDur = Select.ar(mode, [grainDur, grainDur, calculatedGrainDur]);


	grainTrigger = Impulse.ar(grainRate);
	//-----------------------
	grainDurMod =Demand.ar(grainTrigger, 0, Dwhite(0-grainDurVar,grainDurVar,inf));
	grainDur = grainDur + grainDurMod;

	grainPositionMod = Demand.ar(grainTrigger, 0, Dwhite(0-grainPositionVar,grainPositionVar,inf));
	grainPosition = grainPosition + grainPositionMod;
	grains = GrainBuf.ar(1, grainTrigger, grainDur, bufnum, grainPitch, grainPosition, 4, 0, grainEnvelopeBufnum, 512, grainAmp);
	grains;
});
)














(
~results = Array.new(5);
[1,2,3,4,5].do({arg item, index;
	var prevOut, new;
	var prev = ~results.last;
	prev.postln;
	if(prev.isNil, {
		prevOut = 5;
	}, {
		prevOut = prev[0];
	});
	
	new = [prevOut * item.pow(2), 3];
	~results.add(new);
});
~results.postln;
)




