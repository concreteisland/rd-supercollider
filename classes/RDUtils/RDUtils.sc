RDUtils {

	*loadBuffer {arg server, path, buffer;
		if(buffer.notNil && buffer.isKindOf(Buffer), {
			buffer.free;
		});

		buffer = Buffer.read(server, path, bufnum: buffer.bufnum);

		^buffer;
	}


	*sineEnvBuffer {arg buffer,attack, release;
		var sustain, asr, env;
		sustain = (1.0 - (attack + release)).clip(0,1);
		asr=[attack,sustain,release].normalizeSum;
		env = Env.linen(asr[0],asr[1],asr[2],curve:\sin);
		buffer.loadCollection(env.asSignal(buffer.numFrames));
		^buffer;
	}

	/*
	MIDIMKtl.find
	k = MIDIMKtl('bcr20000', 1, 3)

	m = MixingBoard.new
	c = MixerChannel('a',s,2,2);
	m.add(c)

	RDUtils.mapMixer2BCR(m, k);
	k.gui;
	*/

	*mapMixer2BCR {arg mixingBoard, bcr;
		mixingBoard.mixers.do({arg mixer, i;
			var x = div(i,8);
			var y = mod(i,8);
			var knob = bcr.elements[\knUp][x][y];
			var button = bcr.elements[\tr][x][y];

			mixer = mixer.asMixer;

			knob.value_(mixer.getControl(\level));
			knob.action_({|knob|
				mixer.setControl(\level, knob.value);
			});

			button.value_(mixer.muted.binaryValue);
			button.action_({|button|
				mixer.mute(button.value.asBoolean);
			});
		});
	}

	*nodeExists {arg node;
		^(and(node.notNil,node.isPlaying));
	}

	*existingNode {arg node;
		if(and(node.notNil,node.isPlaying), {
			^node;
		}, {
			^nil;
		})
	}
}