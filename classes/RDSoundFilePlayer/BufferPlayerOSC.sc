BufferPlayerOSC {
	var <buffer;
	var <playState=\stopped;
	var <>playheadPosition;
	var <startPosition;
	var <endPosition;
	var <playRate=1;
	var <>node;
	var <outBus=0;
	var <>currentPositionBus;
	var <amp = 1;
	var <pan = 0;
	var <>oscPositionReceiver;
	var <loopMode=0;

	//public
	*new {
		^super.new.init;
	}

	init {
		this.oscPositionReceiver_(
			OSCdef((\SweepPosition ++ UniqueID.next).asSymbol, {arg msg;
				var cmdName = msg[0];
				var nodeID = msg[1];
				var replyID = msg[2];
				var value = msg[3];

				if (this.node.notNil, {
					if(this.node.nodeID == nodeID
						&& replyID == 0
						&& cmdName=='/SweepPosition', {
							//("Node "++nodeID++" is currently at position "++value).postln;
							if (this.isInBoundaries(value), {
								this.playheadPosition=value;
								this.changed(\playheadPosition);
								}, {
									//("Node "++nodeID++" reached end at "++value).postln;
									this.reachedEndAction;
							})
					});
				});
		  }, '/SweepPosition', Server.local.addr));
	}

	play {
		"start method play".postln;
		this.playState_(\playing);
	}
	pause {
		"start method pause".postln;
		this.playState_(\paused);
	}
	stop {
		"start method stop".postln;
		this.playState_(\stopped);
	}

	pan_ {arg newPanPosition;
		pan = newPanPosition;
		this.changed(\pan);
		if(this.synthIsRunning, {this.node.set(\pan,this.pan);});
	}

	amp_ {arg newAmp;
		amp = newAmp;
		this.changed(\amp);
		if(this.synthIsRunning, {this.node.set(\amp,this.amp);});
	}

	loopMode_ {arg newLoopMode;
		loopMode = newLoopMode;
		this.changed(\loopMode);
		if(this.synthIsRunning, {this.node.set(\loopMode,this.loopMode);});
	}

	movePlayhead {arg newPlayheadPosition;
		"start method movePlayhead".postln;
		this.playheadPosition=newPlayheadPosition;
		this.changed(\playheadPosition);

		if( this.isInBoundaries(newPlayheadPosition), {
			("movePlayhead: new Position is in boundaries "++newPlayheadPosition).postln;
			if(this.synthIsRunning, {
				("movePlayhead: synth is running, so send new startPosition to synth and retrigger").postln;
				this.node.set(\startPosition,this.playheadPosition,\t_trig,1);
		  });
		}, {
			("movePlayhead: synth is not running, so stop").postln;
			this.stop;
		});
	}

	buffer_ {arg newBuffer;
		var oldBuffer = this.buffer;
		if (oldBuffer.notNil, {oldBuffer.free;});
		buffer = newBuffer;
		this.changed(\buffer);
		this.setStartEnd(0,buffer.numFrames);
	}

	setStartEnd {arg boundary1, boundary2;
		if(this.playRate>=0, {
			this.startPosition_(min(boundary1,boundary2));
			this.endPosition_(max(boundary1,boundary2));
		}, {
			this.startPosition_(max(boundary1,boundary2));
			this.endPosition_(min(boundary1,boundary2));
		});


		if( this.playState==\stopped, {
				this.movePlayhead(this.startPosition);
		}, {
				/*this.currentPositionBus.get({|value|
					if( this.isInBoundaries(value)==false, {
						this.movePlayhead(this.startPosition);
					});
				});*/
		});
	}

	playRate_ {arg newPlayRate;
		var oldPlayRate = playRate;

		playRate = newPlayRate;
		this.changed(\playRate);

		if(((oldPlayRate>=0) && (newPlayRate<0)) || ((oldPlayRate<0) && (newPlayRate>=0)), {
			var oldStartPosition= this.startPosition;
			this.startPosition_(this.endPosition);
			this.endPosition_(oldStartPosition);
		});

		if(this.synthIsRunning, {
			this.node.set(\rate,this.playRate);
			if(this.playState==\stopped, {
				this.movePlayhead(this.startPosition);
			});
		}, {
				this.movePlayhead(this.startPosition);
		});
	}

	//privat

	startPosition_{arg newStartPosition;
		startPosition = newStartPosition;
		this.changed(\boundaries);
		if(this.synthIsRunning, {
			this.node.set(\startPosition,this.startPosition);
		});
	}

	endPosition_{arg newEndPosition;
		endPosition = newEndPosition;
		this.changed(\boundaries);
		if(this.synthIsRunning, {this.node.set(\endPosition,this.endPosition);});
	}

	playState_ {arg newState;
		var oldState = this.playState;
		"start method playState".postln;
		playState = newState;

		if(this.playState==\playing, {
			if(oldState==\stopped, {
				this.node = Synth(
					\SamplePlayer,[
						\out,this.outBus,
						\bufNum,this.buffer.bufnum,
						\amp, this.amp,
						\pan, this.pan,
						\rate,this.playRate,
						\t_trig,1,
						\run,1,
						\startPosition,this.playheadPosition,
						\endPosition,this.endPosition,
						\currentPositionBus, this.currentPositionBus,
						\loopMode,this.loopMode
				]);
				NodeWatcher.register(this.node);
			});
			if(oldState==\paused, {
				if(this.synthIsRunning, {
					this.node.set(\run,1);
				});
			});
		});

		if(this.playState==\paused, {
			if(this.synthIsRunning, {
				this.node.set(\run,0);
			});
		});

		if(this.playState==\stopped, {
			"set playState to stopped".postln;
			if(this.synthIsRunning, {
				"stop: synth is running, so free it".postln;
				this.node.isRunning.postln;
				this.node.isPlaying.postln;
				this.node.free;
			});
			"stop: set this.node to nil".postln;
			this.node_(nil);
			"stop: now movePlayhead to startpositon".postln;
			this.movePlayhead(this.startPosition);
		});
		this.changed(\playState);
	}

	synthIsRunning {
		var synthIsRunning=false;
		//"start method synthIsRunning".postln;
		if(this.node.notNil, {
			//"synthIsRunning: node is not nil".postln;
			if(this.node.isRunning, {
				//"synthIsRunning: node is running".postln;
				synthIsRunning=true;
			});
		});
		^synthIsRunning;
	}


	isInBoundaries {arg position;
		var isInBoundaries=false;
		if(this.startPosition.notNil && this.endPosition.notNil, {
			var lower = min(this.startPosition, this.endPosition);
			var higher = max(this.startPosition, this.endPosition);
			if (position >= lower, {
				if (position <= higher, {
					isInBoundaries=true;
				});
			});
		}, {
			isInBoundaries=true;
		});
		^isInBoundaries;
	}

	reachedEndAction {
		if (this.loopMode==0, {
			this.stop;
		});
		if (this.loopMode==1, {
			this.movePlayhead(this.startPosition);
/*			this.stop;
			this.play;*/
		});
		if (this.loopMode==2, {
			this.playRate_(this.playRate*(-1));
			this.movePlayhead(this.startPosition);
/*			this.stop;
			this.playRate_(this.playRate*(-1));
			this.play;*/
		});
	}

	outBus_ {arg newOutBus;
		outBus = newOutBus;
		if(this.node.notNil, {this.node.set(\out,this.outBus)});
		this.changed(\outBus);
	}

}
