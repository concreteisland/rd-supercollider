BufferPlayerController : SimpleController {
	var <>gui;

	*new {arg model_;
		var obj = super.newCopyArgs(model_).init;
		obj.init2;
		^obj;
	}

	init2 {
		gui=BufferPlayerGUI.new(model);

		this.put(\buffer, {|theChanger, what|
			AppClock.sched(0.0,{
				this.gui.soundFileView.soundfile = theChanger.buffer;
				this.gui.soundFileView.read(0, this.gui.soundFileView.soundfile.numFrames).refresh;
			});
		});

		this.put(\boundaries, {|theChanger, what|
			var lo,hi;
			if(theChanger.startPosition.notNil && theChanger.endPosition.notNil, {
				lo = min(theChanger.startPosition,theChanger.endPosition);
				hi = max(theChanger.startPosition,theChanger.endPosition);
				AppClock.sched(0.0,{
					this.gui.soundFileView.setSelectionStart(0, lo);
					this.gui.soundFileView.setSelectionSize(0, absdif(lo,hi));
				});
			});
		});

		this.put(\playheadPosition, {|theChanger, what|
			AppClock.sched(0.0,{
				this.gui.soundFileView.timeCursorPosition = theChanger.playheadPosition;
			});
		});

		this.put(\playState, {|theChanger, what|
			if (theChanger.playState==\stopped, {AppClock.sched(0.0,{this.gui.playButton.value_(0);});});
			if (theChanger.playState==\playing, {AppClock.sched(0.0,{this.gui.playButton.value_(1);});});
			if (theChanger.playState==\paused,  {AppClock.sched(0.0,{this.gui.playButton.value_(0);});});
		});

		this.put(\playRate, {|theChanger, what|
			AppClock.sched(0.0,{
				this.gui.rateSlider.value_(theChanger.playRate);
			});
		});

		this.put(\pan, {|theChanger, what|
			this.gui.panSlider.value_(theChanger.pan);
		});

		this.put(\amp, {|theChanger, what|
			this.gui.ampSlider.value_(theChanger.amp);
		});

		this.put(\loopMode, {|theChanger, what|
			this.gui.loopModeMenu.value_(theChanger.loopMode);
		});

	}

}