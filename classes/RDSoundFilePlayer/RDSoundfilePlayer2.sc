RDSoundFilePlayer2 {
	var <id;
	var <buffer;
	var <soundfile;
	var <server;
	var <synth;
	var <synthDef;
	var <rate = 1;
	var <rateInternal = 1;
	var <lowerBoundary = 0;
	var <upperBoundary = 1;
	var <lowerBoundaryInternal = 0;
	var <upperBoundaryInternal = 1;
	var <position = 0;
	var <positionInternal = 0;
	var <startPosition = 0;
	var <startPositionInternal = 0;

	var <loopModeNoLoop = \noLoop;
	var <loopModeLooping = \loop;
	var <loopModePingPong = \pingpong;
	var <loopMode;

	var <target;
	var <addAction = \addToHead;
	var oscPathPosition = "/position";
	var oscPathBoundary = "/boundary";
	var oscResponders;
	var direction = 1;
	var <statusPlaying = \playing;
	var <statusPaused = \paused;
	var <statusStopped = \stopped;

	*new {arg argServer;
		var instance = super.new;
		instance.perform(\init, argServer);
		^instance;
	}

	init {arg argServer;
		server = argServer;
		id = UniqueID.next;
		oscResponders = Dictionary.new;
		loopMode = loopModeNoLoop;
	}

	loadSoundfile {arg path;
		soundfile = SoundFile.new(path);
		this.prLoadBuffer;
		this.changed;
	}

	play {
		if(this.isPaused, {
			{
				synth.run(true);
				server.sync;
			}.forkIfNeeded;
		}, {
			if(this.isStopped, {
					direction = 1;
					this.prSetStartPosition;
					this.prCreateSynth;
			});
		});
	}

	stop {
		if(not(this.isStopped), {
			direction = 1;
			this.prSetStartPosition;
			this.prEndSynth;
		});
		this.changed;
	}

	pause {
		if(this.isPlaying, {
			{
				synth.run(false);
				server.sync;
				this.changed;
			}.forkIfNeeded;
		});

	}

	setRate {arg argRate;
		argRate = argRate * buffer.sampleRate;
		rate = argRate;
		this.prUpdateSynth(\rate, rate);
		this.prSetStartPosition;
		this.changed;
	}

	setBoundaries {arg argBoundary1, argBoundary2;
		argBoundary1 = argBoundary1.linlin(0,1,0,buffer.numFrames);
		argBoundary2 = argBoundary2.linlin(0,1,0,buffer.numFrames);

		lowerBoundary = min(argBoundary1,argBoundary2);
		upperBoundary = max(argBoundary1,argBoundary2);

		this.prUpdateSynth(\loBoundary, lowerBoundary);
		this.prUpdateSynth(\hiBoundary, upperBoundary);
		this.prSetStartPosition;
		this.changed;
	}

	setLoopMode {arg argLoopMode;
		loopMode = argLoopMode;
		this.prUpdateSynth(\loopMode, loopMode);
		this.changed;
	}

	setTarget {arg argAddAction, argTarget;
		target = argTarget;
		addAction = argAddAction;

		if(not(this.isStopped), {
			if(addAction == \addAfter, {
				synth.moveAfter(target);
			});
			if(addAction == \addBefore, {
				synth.moveBefore(target);
			});
			if(addAction == \addToHead, {
				synth.moveToHead(target);
			});
			if(addAction == \addToTail, {
				synth.moveToTail(target);
			});
		});
		this.changed;
	}

	guiClass {
		^RDSoundfilePlayerGui;
	}

	status {
		if(synth.notNil, {
			if(synth.isPlaying, {
				if(synth.isRunning, {
					^statusPlaying;
				}, {
					^statusPaused;
				});
			}, {
				^statusStopped;
			})
		}, {
			^statusStopped;
		});
	}

	isPlaying {
		^(this.status == statusPlaying);
	}
	isPaused {
		^(this.status == statusPaused);
	}
	isStopped {
		^(this.status == statusStopped);
	}

	/** private **/

	prLoadBuffer{
		{
			if(buffer.notNil, {
				buffer.free
			});
			server.sync;

			if(soundfile.notNil, {
				if(not(soundfile.isOpen), {
					soundfile.openRead;
				});
				buffer = soundfile.asBuffer(server);
				server.sync;
				this.setBoundaries(0,1);
				this.setRate(1.0);
				soundfile.close;
				this.prCreateSynthDef;
			});
			server.sync;
			this.changed;
		}.forkIfNeeded;
	}

	prSetStartPosition {
		if(direction.isNegative, {
			startPosition = upperBoundary;
		}, {
			startPosition = lowerBoundary;
		});
		this.changed;
	}

	prCreateSynth {
		var arguments;
		"create synth\n".postf;
		if(synth.notNil, {
			this.prEndSynth;
		});
		arguments = [
			\t_start, 1,
			\loBoundary, lowerBoundary,
			\hiBoundary, upperBoundary,
			\startPosition, startPosition,
			\rate, rate*direction,
		];
		arguments.postln;
		{
			synth = Synth(synthDef.name.asSymbol, arguments, target, addAction).register;
			synth.onFree({|freedSynth|
				"onFree".postln;
				this.prRemoveOSCResponders(freedSynth);
				if(freedSynth == synth, {
					synth = nil;
				});
				this.changed;
			});
			server.sync;
			this.prCreateOSCResponders;
			this.changed;
			"created synth %\n".postf(synth);
		}.forkIfNeeded;

	}

	prEndSynth {
		"end synth\n".postf;
		this.prRemoveOSCResponders(synth);
		{
			if(synth.notNil, {
				if(synth.isPlaying, {
					"free synth\n".postf;
					synth.free;
				});
				synth = nil;
				"set synth to %\n".postf(synth);
			});
			server.sync;
			this.changed;
		}.forkIfNeeded;

	}

	prUpdatePosition {arg argPosition;
		position = argPosition;
		this.changed;
	}

	prUpdateSynth {arg key, value;
		if(not(this.isStopped), {
			this.synth.set(key, value);
		});
	}

	prBoundary {
		"prBoundary".postln;
		//this.prEndSynth;

		if(loopMode == loopModeLooping,{
			direction = 1;
		});

		if(loopMode == loopModePingPong,{
			direction = direction.neg;
		});
		this.prSetStartPosition;

		if(loopMode != loopModeNoLoop, {
			this.prCreateSynth;
		});
	}

	prCreateOSCResponders {
		var newOscResponders = List.new;
		"prCreateOSCResponders".postln;
		this.prRemoveOSCResponders(synth);

		newOscResponders.add(
			OSCFunc(
				{arg msg, time;
					var nodeID = msg[1];
					"received boundary reply from node % \n".postf(nodeID);
					if(synth.notNil && synth.nodeID == nodeID, {
						synth.postln;
						this.prBoundary;
					});
				},
				oscPathBoundary,
				server.addr,
				argTemplate: [synth.nodeID]
			).oneShot
		);

		newOscResponders.add(
			OSCFunc(
				{arg msg, time;
					var nodeID = msg[1];
					var position = msg[3];
					if(synth.notNil && synth.nodeID == nodeID, {
						this.prUpdatePosition(position);
					});
				},
				oscPathPosition,
				server.addr,
				argTemplate: [synth.nodeID]
			)
		);

		oscResponders.put(synth, newOscResponders);
	}

	prRemoveOSCResponders {arg argSynth;
		var toRemove = oscResponders.at(argSynth);
		"prRemoveOSCResponders".postln;
		"oscResponders toRemove: %\n".postf(toRemove);
		if(toRemove.notNil, {
			toRemove.do({arg oscResponder;
				oscResponder.free;
			});
			oscResponders.removeAt(argSynth);
		});
		"still remaining oscResponders: %\n".postf(oscResponders);
	}

	prCreateSynthDef {
		synthDef = SynthDef(\rdSoundfilePlayer++id, {arg
			outBus=0, t_start=1,
			startPosition=0, loBoundary=0, hiBoundary=1,
			rate=1, rangeOffset=0.001;

			var bufFrames, bufRd, sweep, inRange=1, notInRange=0;
			var envelope;

			startPosition = Latch.ar(startPosition, t_start);
			sweep = Sweep.ar(t_start, rate) + startPosition;

			inRange = InRange.kr(
				sweep,
				loBoundary + (rangeOffset * buffer.sampleRate *    (rate <0)  ),
				hiBoundary - (rangeOffset * buffer.sampleRate * (1-(rate <0)) )
			);
			notInRange = (1-inRange);
			envelope = EnvGen.kr(Env.asr(rangeOffset,1,rangeOffset,0),inRange, doneAction:2);


			SendReply.kr(notInRange, oscPathBoundary, sweep);
			SendReply.kr(Impulse.kr(100), oscPathPosition, sweep);

			bufRd = BufRd.ar(
				buffer.numChannels,
				buffer.bufnum,
				sweep,
				loop:0,
				interpolation:4
			) * envelope;
			Out.ar(outBus,bufRd);
		});
		synthDef.add;
	}
}

