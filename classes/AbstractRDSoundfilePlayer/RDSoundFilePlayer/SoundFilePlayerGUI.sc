SoundFilePlayerGUI : BufferPlayerGUI {

	selectButtonAction {arg view;
		Dialog.openPanel({arg path;
			SoundFile.use(path, {arg soundfile;
				this.model.soundfile_(soundfile);
			});
		});
	}

}