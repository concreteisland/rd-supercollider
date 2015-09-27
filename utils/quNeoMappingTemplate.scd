MIDIMKtl.find;
~quNeo = MIDIMKtl('qn0');

(
/** PADS **/
~quNeo.elements[\pad].collect({|pad, i|
	pad[\noteOn].action_({|e|
		format("Pad#% noteOn: %", i, e.value).postln;
	});
	pad[\noteOff].action_({|e|
		format("Pad#% noteOff: %", i, e.value).postln;
	});
	pad[\pressure].action_({|e|
		format("Pad#% pressure: %", i, e.value).postln;
	});
	pad[\locationX].action_({|e|
		format("Pad#% locationX: %", i, e.value).postln;
	});
	pad[\locationY].action_({|e|
		format("Pad#% locationY: %", i, e.value).postln;
	});
});


/** VERTICAL SLIDERS **/
~quNeo.elements[\vSlider].collect({|vSlider, i|
	vSlider[\noteOn].action_({|e|
		format("vSlider#% noteOn: %", i, e.value).postln;
	});
	vSlider[\noteOff].action_({|e|
		format("vSlider#% noteOff: %", i, e.value).postln;
	});
	vSlider[\pressure].action_({|e|
		format("vSlider#% pressure: %", i, e.value).postln;
	});
	vSlider[\location].action_({|e|
		format("vSlider#% location: %", i, e.value).postln;
	});
});


/** HORIZONTAL SLIDERS **/
~quNeo.elements[\hSlider].collect({|hSlider, i|
	hSlider[\noteOn].action_({|e|
		format("hSlider#% noteOn: %", i, e.value).postln;
	});
	hSlider[\noteOff].action_({|e|
		format("hSlider#% noteOff: %", i, e.value).postln;
	});
	hSlider[\pressure].action_({|e|
		format("hSlider#% pressure: %", i, e.value).postln;
	});
	hSlider[\location].action_({|e|
		format("hSlider#% location: %", i, e.value).postln;
	});
});


/** LONG SLIDERS **/
~quNeo.elements[\longSlider][\noteOn].action_({|e|
	format("\longSlider noteOn: %", e.value).postln;
});
~quNeo.elements[\longSlider][\noteOff].action_({|e|
	format("\longSlider noteOff: %", e.value).postln;
});
~quNeo.elements[\longSlider][\pressure].action_({|e|
	format("\longSlider pressure: %", e.value).postln;
});
~quNeo.elements[\longSlider][\location].action_({|e|
	format("\longSlider location: %", e.value).postln;
});
~quNeo.elements[\longSlider][\width].action_({|e|
	format("\longSlider width: %", e.value).postln;
});

)
