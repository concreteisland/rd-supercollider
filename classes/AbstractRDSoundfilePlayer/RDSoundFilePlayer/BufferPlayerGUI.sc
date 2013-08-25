BufferPlayerGUI {
	var <window;
	var <soundFileView;
	var <selectButton;
	var <rewindButton;
	var <playButton;
	var <stopButton;
	var <loopModeMenu;
	var mouseClickModeButton;
	var <rateSlider;
	var <panSlider;
	var <ampSlider;
	var <outBusNumberBox;
	var <model;
	var <>mouseDownX=0;

	*new {arg model;
		^super.new.init(model);
	}

	init {arg model_;
		model=model_;

		window = Window.new;
		window.front;
		window.setInnerExtent(370, 472);
		window.view.decorator = FlowLayout( window.view.bounds, 4@4, 4@4 );

		//fileview
		soundFileView = SoundFileView.new(window.view, 362@144);
		soundFileView.timeCursorOn = true;
		soundFileView.timeCursorColor = Color.white;
		soundFileView.setSelectionColor (1, Color.clear);
		soundFileView.mouseUpAction = {arg view,x;
			if(view.currentSelection==0, {
				var boundary1 = view.selections[view.currentSelection][0];
				var size = view.selections[view.currentSelection][1];
				var boundary2 = boundary1 + size;
				model.setStartEnd(boundary1,boundary2);
			}, {
				this.movePlayheadAction(view,x);
			});
		};
		soundFileView.mouseDownAction = {arg view, x;
			if(view.currentSelection==1, {
				this.mouseDownX=x;
			});
		};
		soundFileView.mouseMoveAction = {arg view, x;
			this.movePlayheadAction(view,x);
		};

		//select file
		selectButton = Button(window.view, 40@20);
		selectButton.states = [["Select", Color.white, Color.grey]];
		selectButton.action = {arg view;
			this.selectButtonAction(view);
		};

		//rewind
		rewindButton = Button(window.view, 20@20);
		rewindButton.states = [["|<", Color.white, Color.green(0.4)]];
		rewindButton.action = {arg view;model.movePlayhead(model.startPosition);};

		//play
		playButton = Button(window.view, 20@20);
		playButton.states = [[">", Color.white, Color.green(0.4)],["||", Color.white, Color.red(0.5)]];
		playButton.action = {arg view;if (view.value == 1, {model.play;}, {model.pause;});};

		//stop
		stopButton = Button(window.view, 20@20);
		stopButton.states = [["\[\]", Color.white, Color.red(1)]];
		stopButton.action = {arg view;model.stop;};

		//mouseClickMode
		mouseClickModeButton = Button(window.view, 20@20);
		mouseClickModeButton.states = [
			["S", Color.white, Color.green(0.4)],
			["M", Color.white, Color.red(0.5)]
		];
		mouseClickModeButton.action = {arg view;
			if (view.value == 1, {
				this.soundFileView.currentSelection_(1);
		  }, {
				this.soundFileView.currentSelection_(0);
		  });
		};

		//LoopMode
		loopModeMenu = EZPopUpMenu(
			parentView:window.view,
			bounds: 160@22,
			label:"Loop Modus ",
	    items: [
				'No Loop' -> {model.loopMode_(0);},
		    'Loop' -> {model.loopMode_(1);},
		    'Pingpong' -> {model.loopMode_(2);},
	    ]
		);

		window.view.decorator.nextLine;

		//rateSlider
		rateSlider = EZSlider(
			window.view,
			240@20,
			"Rate",
			ControlSpec(-2,2),
			{arg view; model.playRate_(view.value);},
			model.playRate,
			numberWidth:36,
			labelWidth:24
		);

		window.view.decorator.nextLine;

		//panSlider
		panSlider = EZSlider(
			parent:window.view,
			bounds: 240@20,
			label:"Pan",
			controlSpec:ControlSpec(-1,1),
			action:{arg view;model.pan_(view.value);},
			initVal:model.pan,
			layout:\horz,
			numberWidth:36,
			labelWidth:24
		);

		window.view.decorator.nextLine;

		//ampSlider
		ampSlider = EZSlider(
			parent:window.view,
			bounds: 240@20,
			label:"Amp ",
			controlSpec:ControlSpec(0,2),
			action:{arg view;model.amp_(view.value);},
			initVal:model.amp,
			layout:\horz,
			numberWidth:36,
			labelWidth:24
		);

		window.view.decorator.nextLine;

		outBusNumberBox = EZNumber.new (
			parent:window.view,
			bounds:80@20,
			label:"OutBus",
			initVal:model.outBus,
			layout:\horz,
			labelWidth:40,
			numberWidth:40,
			controlSpec:ControlSpec(step:1,maxval:99999),
			action:{arg view;model.outBus_(view.value);}
		);
	}

	movePlayheadAction {arg view, x;
		var boundaries,start,size,newPlayheadPosition;
		if(view.currentSelection==1, {
			boundaries = view.selection(1);
			start=boundaries[0];
			size =boundaries[1];
			if(x<=this.mouseDownX, {
				newPlayheadPosition = start;
				}, {
					newPlayheadPosition = start+size;
			});
			newPlayheadPosition.postln;
			model.movePlayhead(newPlayheadPosition);
		});
	}

	selectButtonAction {arg view;
		Buffer.loadDialog(Server.local, action: {arg buffer;
			model.buffer_(buffer);
		});
	}
}


