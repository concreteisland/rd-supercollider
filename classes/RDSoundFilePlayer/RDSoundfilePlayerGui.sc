RDSoundfilePlayerGui : ObjectGui {
	var <loadFileButton;
	var <soundfileView;
	var <rewindButton;
	var <playPauseButton;
	var <stopButton;
	var <mouseClickModeButton;
	var <rateSlider;
	var <loopModeSelection;
	var <ampSlider;
	var <outBusNumberbox;

	guiBody { arg layout,bounds;
		bounds = (bounds ?? {layout.indentedRemaining}).asRect;

		layout.startRow;

		soundfileView = SoundFileView.new(view, 362@144);
		soundfileView.timeCursorOn = true;
		soundfileView.timeCursorColor = Color.white;
		soundfileView.setSelectionColor (1, Color.red);
		soundfileView.mouseUpAction = {arg soundfileView, x, y;
			var tempSelection, lowerBoundary, upperBoundary;
			tempSelection = soundfileView.selection(1);
			lowerBoundary = tempSelection[0];
			upperBoundary = lowerBoundary + tempSelection[1];
			if(upperBoundary.absdif(lowerBoundary) > 1, {
				model.setBoundaries(lowerBoundary,upperBoundary);
			});

			soundfileView.currentSelection_(0);
			soundfileView.setSelection(1,[0,0]);
		};
		soundfileView.mouseDownAction = {arg soundfileView, x, y;
			"x: % y:%\n".postf(x,y);
			soundfileView.currentSelection_(1);
		};
		soundfileView.mouseMoveAction = {arg soundfileView, x, y;
		};
		this.updateSoundfile;

		layout.startRow;

		loadFileButton = Button(view, 40@20);
		loadFileButton.states = [["Select", Color.white, Color.grey]];
		loadFileButton.action = {arg button;
			Dialog.openPanel({ arg path;
				model.loadSoundfile(path).changed;
			});
		};

		rewindButton = Button(view, 20@20);
		rewindButton.states = [["|<", Color.white, Color.green(0.4)]];
		rewindButton.action = {};

		playPauseButton = Button(view, 20@20);
		playPauseButton.states = [
			[">", Color.white, Color.green(0.4)],
			["||", Color.white, Color.red(0.5)]
		];
		playPauseButton.action = {arg button;
			if (button.value == 1, {
				model.play;
			}, {
				model.pause;
			});
		};

		stopButton = Button(view, 20@20);
		stopButton.states = [["\[\]", Color.white, Color.red(1)]];
		stopButton.enabled = false;
		stopButton.action = {arg button;
			model.stop;
		};

		mouseClickModeButton = Button(view, 40@20);
		mouseClickModeButton.states = [
			["Select", Color.white, Color.green(0.4)],
			["Extend", Color.white, Color.blue(0.5)],
			["Move", Color.white, Color.red(0.5)]
		];
		mouseClickModeButton.action = {};

		loopModeSelection = EZPopUpMenu(
			parentView:view,
			bounds: 160@22,
			label:"Loop Mode ",
	    items: [
				'No Loop' -> {model.setLoopMode(model.loopModeNoLoop)},
		    'Loop' -> {model.setLoopMode(model.loopModeLooping)},
		    'Pingpong' -> {model.setLoopMode(model.loopModePingPong)},
	    ]
		);

		layout.startRow;

		rateSlider = EZSlider(
			parent: view,
			bounds: 240@20,
			label: "Rate",
			controlSpec: ControlSpec(-2,2),
			action: {arg slider;
				model.setRate(slider.value);
			},
			initVal: 1,
			numberWidth:36,
			labelWidth:24
		);

		layout.startRow;

		ampSlider = EZSlider(
			parent: view,
			bounds: 240@20,
			label: "Amp ",
			controlSpec: ControlSpec(0,2),
			action:{},
			initVal: 1,
			layout: \horz,
			numberWidth: 36,
			labelWidth: 24
		);

		layout.startRow;

		outBusNumberbox = EZNumber.new (
			parent: view,
			bounds: 80@20,
			label: "OutBus",
			controlSpec: ControlSpec(step:1,maxval:99999),
			action: {arg numberbox;
				model.outBus_(numberbox.value);
			},
			initVal: 0,
			layout: \horz,
			labelWidth: 40,
			numberWidth: 40,
		);
	}

	update {arg theChanged, theChanger;
		this.updateSoundfile;
		this.updatePlayPauseStopButton;
		this.updateLoopMode;
		this.updateRate;
		this.updateOutBus;
	}

	updateSoundfile {
		AppClock.sched(0.0,{
			var boundarySelection = soundfileView.selection(0);
			var lowerBoundary = boundarySelection[0];
			var upperBoundary = lowerBoundary + boundarySelection[1];
			if((model.lowerBoundary != lowerBoundary) || (model.upperBoundary != upperBoundary), {
				var selection = [
					model.lowerBoundary,
					model.upperBoundary - model.lowerBoundary
				];
				selection.postln;
				soundfileView.setSelection(0,selection);
			});
			soundfileView.timeCursorPosition_(model.position);
			nil;
		});
		if(model.soundfile != soundfileView.soundfile, {
			soundfileView.soundfile = model.soundfile;
			if(not(soundfileView.soundfile.isOpen), {
				soundfileView.soundfile.openRead;
			});
			soundfileView.readWithTask(0,soundfileView.soundfile.numFrames);
			if(soundfileView.soundfile.isOpen, {
				soundfileView.soundfile.close;
			});
		});
	}

	updatePlayPauseStopButton {
		AppClock.sched(0.0,{
			if(model.isPlaying, {
				playPauseButton.value = 1;
				stopButton.enabled = true;
			});
			if(model.isPaused, {
				playPauseButton.value = 0;
				stopButton.enabled = true;
			});
			if(model.isStopped, {
				playPauseButton.value = 0;
				stopButton.enabled = false;
			});
		});
	}

	updateLoopMode {
		switch(
			model.loopMode,
			model.loopModeNoLoop, {
				AppClock.sched(0.0,{
					if(loopModeSelection.value != 0, {
						loopModeSelection.value_(0);
					});
				});
			},
			model.loopModeLooping, {
				AppClock.sched(0.0,{
					if(loopModeSelection.value != 1,{
						loopModeSelection.value_(1);
					});
				});
			},
			model.loopModePingPong, {
				AppClock.sched(0.0,{
					if(loopModeSelection.value != 2, {
						loopModeSelection.value_(2);
					});
				});
			}
		);
	}

	updateRate {
		if(rateSlider.value != model.rate, {
			AppClock.sched(0.0,{
				rateSlider.value_(model.rate);
			});
		});
	}

	updateOutBus {
		if(outBusNumberbox.value != model.outBus, {
			AppClock.sched(0.0,{
				outBusNumberbox.value_(model.outBus);
			});
		});
	}

	viewDidClose {
		"bye bye".postln;
		super.viewDidClose;
	}
}