ChebySpec : ControlSpec {
	defaultControl { arg val;
		^ChebyEditor.new(this.constrain(val ? this.default),this);
	}
}

ChebyEditor : KrNumberEditor {
	var <>chebyAmps;
	var <>buffer;

	guiClass { ^ChebyEditorGui }

	value_ { |newChebyAmps,change=true|
		var v;
		//TODO: check if newChebyAmps is really an array

		chebyAmps = newChebyAmps;

		if(buffer.isNil, {
			postf("buffer is nil, so alloc a new one\n");
			buffer = Buffer.alloc(Server.default, 512, 1, {arg buffer;
				buffer.chebyMsg(chebyAmps);
				postf("fill buffer with chebyAmps %\n",chebyAmps);
			});
		}, {
			postf("fill existing buffer with chebyAmps %\n",chebyAmps);
			buffer.cheby(chebyAmps);
		});
		value = buffer.bufnum;
		if(change,{ this.changed });
	}

	setAmp {arg amp, index;
		var amps = chebyAmps;
		amps[index] = amp;
		this.value_(amps);
	}

}

ChebyEditorGui : KrNumberEditorGui {
	var knobs;
	guiBody { arg layout,bounds;
		knobs = List.new;
		model.chebyAmps.do({arg amp,i;
			var knob = EZKnob(
				parent: layout,
				bounds: 50@90,
				label: " Cheby "++i,
				controlSpec: nil,
				action: {arg view; model.setAmp(view.value,i) },
				initVal: amp,
				initAction: false
			);
			knobs.add(knob);
		});
	}

	update { arg model;
		knobs.do({arg knob,i;
			var amp = model.chebyAmps[i];
			knob.value_(amp);
		})

	}


}