(
~model = SoundFilePlayerOSC.new;

/************************************
*
* CONTROLLER
*
****/
~controller=SimpleController.new(~model);
~controller.put(\soundfile, {arg model, what;
	~soundFileView.soundfile = model.soundfile;
	~soundFileView.readWithTask(doneAction:{
		~soundFileView.gridResolution_(25/(~soundFileView.bounds.width/model.soundfile.duration));
		~soundfileLength.string = model.soundfile.duration.round(0.01).asString++"sec";
	});
});
~controller.put(\isCued, {arg model, what; ("Cued for play: "++model.isCued).postln;});
~controller.put(\playState, {arg model, what;
	if(model.playState==\playing,{~playPauseButton.value_(1);});
	if(model.playState==\paused,{~playPauseButton.value_(0);});
	if(model.playState==\stopped,{
		AppClock.sched(0,{~playPauseButton.value_(0);});
	});
});
~controller.put(\rate, {arg model, what; ~rateSlider.value_(model.rate);});
~controller.put(\amp, {arg model, what;	~ampSlider.value_(model.amp);});
~controller.put(\pan, {arg model, what;	~panSlider.value_(model.pan);});
~controller.put(\out, {arg model, what;	~outNumber.value_(model.out);});
~controller.put(\playheadPosition, {arg model, what;
	AppClock.sched(0.0, {~soundFileView.timeCursorPosition_(model.playheadPosition)});
});

~controller.put(\startPosition, {arg model; ~boundaries.value(model)});
~controller.put(\endPosition, {arg model; ~boundaries.value(model)});
~boundaries={arg model;
	var lo,hi;
	if(model.startPosition.notNil && model.endPosition.notNil, {
		lo = min(model.startPosition,model.endPosition);
		hi = max(model.startPosition,model.endPosition);
		AppClock.sched(0.0,{
			~soundFileView.setSelectionStart(0, lo);
			~soundFileView.setSelectionSize(0, absdif(lo,hi));
		});
	});
};


/************************************
*
* VIEW
*
****/
~window = Window.new.front.setInnerExtent(370, 472);
~window.view.decorator = FlowLayout( ~window.view.bounds, 4@4, 4@4 );
~window.onClose = {
	~model.freeAll;
};

//fileview
~soundFileView = SoundFileView.new(~window.view, 362@144);
~soundFileView.timeCursorOn = true;
~soundFileView.timeCursorColor = Color.white;
~soundFileView.setSelectionColor (1, Color.clear);
~soundFileView.mouseUpAction = {arg view,x;
	if(view.currentSelection==0, {
		var boundary1 = view.selections[view.currentSelection][0];
		var size = view.selections[view.currentSelection][1];
		var boundary2 = boundary1 + size;
		~model.setBoundaries(boundary1,boundary2);
	}, {
		~movePlayheadAction.value(view,x);
	});
};
~soundFileView.mouseDownAction = {arg view, x;
	if(view.currentSelection==1, {
		~mouseDownX=x;
	});
};
~soundFileView.mouseMoveAction = {arg view, x;
	~movePlayheadAction.value(view,x);
};

~movePlayheadAction={arg view, x;
	var boundaries,start,size,newPlayheadPosition;
	if(view.currentSelection==1, {
		boundaries = view.selection(1);
		start=boundaries[0];
		size =boundaries[1];
		if(x<=~mouseDownX, {
			newPlayheadPosition = start;
		}, {
			newPlayheadPosition = start+size;
		});
		newPlayheadPosition.postln;
		~model.movePlayhead(newPlayheadPosition);
	});
};



//select file
~selectButton = Button(~window.view, 40@20);
~selectButton.states = [["Select", Color.white, Color.grey]];
~selectButton.action = {arg view;
	Dialog.openPanel({arg path;
		SoundFile.use(path, {arg soundfile;
			~model.soundfile_(soundfile);
		});
	});
};

//play/pause
~playPauseButton = Button.new(~window.view, 40@20);
~playPauseButton.states = [["Play", Color.white, Color.green(0.5)],["Pause", Color.black,  Color.new255(173, 216, 230)],];
~playPauseButton.action = {arg view;if(view.value==1, {~model.play;}, {~model.pause;});};

//stop
~stopButton = Button(~window.view, 40@20);
~stopButton.states = [["Stop", Color.white, Color.red]];
~stopButton.action = {arg view;~model.stop;};

//mouseClickMode
~mouseClickModeButton = Button(~window.view, 20@20);
~mouseClickModeButton.states = [
	["S", Color.white, Color.green(0.4)],
	["M", Color.white, Color.red(0.5)]
];
~mouseClickModeButton.action = {arg view;
	if (view.value == 1, {
		~soundFileView.currentSelection_(1);
	}, {
		~soundFileView.currentSelection_(0);
	});
};

~soundfileLength = StaticText(~window.view, 100@20);


//rate
~rateSlider = EZSlider(
	~window.view,
	362@20,
	"Rate",
	ControlSpec(0,2),
	{arg view; ~model.rate_(view.value;)},
	~model.rate,labelWidth:36,numberWidth:36);

//amp
~ampSlider = EZSlider(
	~window.view,
	362@20,
	"Volume",
	ControlSpec(0,20,\amp),
	{arg view; ~model.amp_(view.value;)},
	~model.amp,labelWidth:36,numberWidth:36);

//pan
~panSlider = EZSlider(
	~window.view,
	362@20,
	"Pan",
	ControlSpec(-1,1),
	{arg view; ~model.pan_(view.value;)},
	~model.pan,labelWidth:36,numberWidth:36);

//out
~outNumber = EZNumber(
	~window.view,
	362@20,
	"Outbus",
	ControlSpec(0,inf),
	{arg view; ~model.out_(view.value;)},
	~model.out,numberWidth:40);
)

~soundfile

~model.dump

s.scope


