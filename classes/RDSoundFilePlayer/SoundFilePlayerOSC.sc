SoundFilePlayerOSC {
	var <soundfile;
	var <buffer;
	var <playheadPosition;
	var <startPosition=0;
	var <endPosition=1;
	var <>node;
	var <rate=1;
	var <amp=1;
	var <pan=0;
	var <out=0;
	var <playState=\stopped;
	var <>oscPositionReceiver;
	var <>cuePosition;
	var <loopMode=\noLoop;
	var <>globalFilePosition=0;
	var <>offset=0;

	*new {
		^super.new.init;
	}

	init {
		this.oscPositionReceiver_(
			OSCdef((\diskin ++ UniqueID.next).asSymbol, {arg msg;
				var cmdName = msg[0];
				var nodeID = msg[1];
				var replyID = msg[2];
				var value = msg[3];

				//value = value - this.cuePosition;
				//value = value + this.startPosition;

				if (this.node.notNil, {
					if(this.node.nodeID == nodeID
						&& replyID == 1
						&& cmdName=='/diskin', {
							//("Node "++nodeID++" is currently at position "++value).postln;

							this.globalFilePosition_(value);

							if (this.isInBoundaries(value), {
								this.playheadPosition_(value);
							}, {
								//("Node "++nodeID++" reached end at "++value).postln;
								this.reachedEndAction;
							})
					});
				});
		  }, '/diskin', Server.local.addr));
	}

	play {
		var oldPlayState = this.playState;
		this.playState_(\playing);

		if(oldPlayState == \stopped, {
			this.node_(Synth(\SoundFilePlayer, [
				\out, this.out,
				\bufnum, this.buffer.bufnum,
				\amp, this.amp,
				\pan, this.pan,
				\rate,this.rate
			]));
		});
		if(oldPlayState == \paused, {
			if(this.node.notNil, {
				this.node.set(\run,1);
			});
		});
	}

	pause {
		if(this.node.notNil, {
			this.node.set(\run,0);
		});
		this.playState_(\paused);
	}

	stop {
		this.playState_(\stopped);
		if(this.node.notNil, {
			this.node.free;
		});
		this.node_(nil);
		this.globalFilePosition_(0);
		this.movePlayhead(this.startPosition);
	}

	playState_{arg newPlayState;
		playState = newPlayState;
		this.changed(\playState);
	}

	reCue {arg position=0;
		"recue".postln;

	}

	soundfile_ {arg newSoundfile;
		soundfile = newSoundfile;
		this.changed(\soundfile);
		this.buffer_(
			Buffer.cueSoundFile(
				Server.local,this.soundfile.path,0,2,
				bufferSize:(Server.local.options.blockSize * (2**4))
		  )
		);
		this.setBoundaries(0,soundfile.numFrames);
	}

	buffer_ {arg newBuffer;
		buffer = newBuffer;
		this.changed(\buffer);
	}

	freeAll {
		this.stop;
		if(this.buffer.notNil, {
			this.buffer.free;
		})
	}

	rate_ {arg newRate;
		rate = newRate;
		if(this.node.notNil, {this.node.set(\rate,this.rate)});
		this.changed(\rate);
	}

	amp_ {arg newAmp;
		amp = newAmp;
		if(this.node.notNil, {this.node.set(\amp,this.amp)});
		this.changed(\amp);
	}

	pan_ {arg newPan;
		pan = newPan;
		if(this.node.notNil, {this.node.set(\pan,this.pan)});
		this.changed(\pan);
	}

	out_ {arg newOut;
		out = newOut;
		if(this.node.notNil, {this.node.set(\out,this.out)});
		this.changed(\out);
	}

	playheadPosition_ {arg newPlayheadPosition;
		playheadPosition = newPlayheadPosition;
		this.changed(\playheadPosition);
	}

	startPosition_{arg newStartPosition;
		startPosition = newStartPosition;
		this.changed(\startPosition);
	}

	endPosition_{arg newEndPosition;
		endPosition = newEndPosition;
		this.changed(\endPosition);
	}

	movePlayhead {arg newPlayheadPosition;
		this.playheadPosition_(newPlayheadPosition);
		this.buffer.cueSoundFile(this.soundfile.path,this.playheadPosition);
		this.cuePosition_(this.playheadPosition);
		this_offset_(this.globalFilePosition + this.playheadPosition);
		this.changed(\buffer);

	}

	isInBoundaries {arg position;
		var isInBoundaries=false;
		if(this.startPosition.notNil && this.endPosition.notNil, {
			var lo = min(this.startPosition, this.endPosition);
			var hi = max(this.startPosition, this.endPosition);
			isInBoundaries = ((lo<=position) && (position<=hi))
		}, {
			isInBoundaries=true;
		});
		^isInBoundaries;
	}

	reachedEndAction {
		if(this.loopMode==\noLoop, {
			this.stop;
		});
	}

	setBoundaries {arg boundary1, boundary2;
		this.startPosition_(min(boundary1,boundary2));
		this.endPosition_(max(boundary1,boundary2));
		if( this.playState==\stopped, {
				this.movePlayhead(this.startPosition);
		});
	}

}

