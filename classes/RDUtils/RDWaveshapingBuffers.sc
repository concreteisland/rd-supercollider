RDChebySample : RDLibraryItem {
	var <amplitudes;
	var frames;
	var server;
	var <buffer;

	*new {arg key, amplitudes, frames, server;
		^super.new(key, amplitudes, frames, server);
	}

	init {arg argKey, argAmplitudes, argFrames, argServer;
		key = argKey;
		amplitudes = argAmplitudes;
		frames = argFrames;
		server = argServer;
		this.fillBuffer;
		^this;
	}

	mustUpdate {arg argAmplitudes, argFrames, argServer;
		if((argAmplitudes.isNil and: argFrames.isNil and: argServer.isNil), {
			^false;
		});
		if(((argAmplitudes != amplitudes) or: (argFrames != frames) or: (argServer != server)), {
			^true;
		});
		^false;
	}

	update {arg argAmplitudes, argFrames, argServer;
		^this.init(key, argAmplitudes, argFrames, argServer);
	}

	fillBuffer {
		if((buffer.notNil.and({buffer.numFrames == frames})), {
			buffer.cheby(amplitudes);
		}, {
			if(buffer.notNil, {
				buffer.free;
			});
			buffer = Buffer.alloc(server, frames, 1, {arg buf;
					buf.chebyMsg(amplitudes);
			});
		});
	}

	amplitudes_ {|argAmplitudes|
		amplitudes = argAmplitudes;
		this.fillBuffer;
		^this;
	}

	guiClass { ^RDChebySampleGui }

}

RDChebySampleGui : ObjectGui {
	var knobs;
	var <>foo;

	guiBody { arg layout,bounds;
		bounds = (bounds ?? {layout.indentedRemaining}).asRect;
		layout.startRow;
		knobs = Array.fill(model.amplitudes.size, {arg i;
			EZKnob(layout,
				action: {|knob|
					var amplitudes = model.amplitudes;
					amplitudes[i] = knob.value;
					model.amplitudes_(amplitudes).changed;
				},
				initVal: model.amplitudes[i]
			);
		});
	}

	update {arg theChanged, theChanger;
		var viewChanged = false;

		if(model.amplitudes.size < knobs.size, {
			var knobsToDelete = knobs.copyRange(model.amplitudes.size,knobs.size-1);
			knobsToDelete.do({|knob|
				knob.view.remove;
				knobs.remove(knob);
			});
			viewChanged = true;
		});

		model.amplitudes.do({|amplitude, i|
			if(knobs[i].isNil, {
				knobs.add(EZKnob(view,
					action: {|knob|
						var amplitudes = model.amplitudes;
						amplitudes[i] = knob.value;
						model.amplitudes_(amplitudes).changed;
					},
					initVal: amplitude
				));
				viewChanged = true;
			}, {
					knobs[i].value_(amplitude);
			});
		});

		if(viewChanged, {
			"debug".postln;
			view.resizeToFit(true, true);
		});
	}
}