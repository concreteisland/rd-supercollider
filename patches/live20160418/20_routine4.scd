(
~part4Setup = {
	"start part 4".postln;
	{
		~bcr.elements.pr_d_r.value_(1);
	}.forkIfNeeded;

	//field
	{
		(~playSoundfile.value(~live1.trainrattle,
			~live1.mixer.mixers[0].asMixer.asBus,
			~live1.mixer.mixers[0].asMixer.synthgroup,
			0.25,
			[
				\xFade, 1, \gain, 1.5,
				\loFreq,100,\loRs,0.5,\loGain,3,
				\peakFreq,400,\peakRq,0.3,\peakGain,-6,
				\hiFreq,1000,\hiRs,3,\hiGain,12,
			]
		));
		~live1.mixer.mixers[0].asMixer.level_(0);
		~bcr.elements.knUp[0][0].value_(0);
	}.forkIfNeeded;

	//buegel01
	{
		~live1.mixer.mixers[1].asMixer.level_(0.1);
		~bcr.elements.knUp[0][1].value_(0.1);
	}.forkIfNeeded;

	//conv
	{
		~live1.mixer.mixers[3].asMixer.level_(0.1);
		~bcr.elements.knUp[0][3].value_(0.1);
	}.forkIfNeeded;

	//rattle
	{
		~rattle.voicer.trigger1(0);
		~live1.mixer.mixers[4].asMixer.level_(0);
		~bcr.elements.knUp[0][4].value_(0);
	}.forkIfNeeded;

	//holz
	{
		~live1.mixer.mixers[5].asMixer.level_(0.1);
		~bcr.elements.knUp[0][5].value_(0.1);
	}.forkIfNeeded;

	//falter
	{
		~live1.mixer.mixers[6].asMixer.level_(0.1);
		~bcr.elements.knUp[0][6].value_(0.1);
	}.forkIfNeeded;

	~part4Timer.reset;
	~part4Timer.play;
};
~part4Finish = {
	"end part 4".postln;
	{ ~bcr.elements.pr_d_r.value_(0); }.forkIfNeeded;

	//field
	{ ~stopSoundfile.value(~live1.trainrattle); }.forkIfNeeded;

	//buegel01
	{ ~buegel01.voicer.releaseAll; }.forkIfNeeded;

	//conv
	{
		~ulvaC.voicer.releaseAll;
		~ulvaC.voicerPlay.releaseAll;
	}.forkIfNeeded;

	//rattle
	{ ~rattle.voicer.releaseAll; }.forkIfNeeded;

	//holz
	{ ~holz.voicer.releaseAll; }.forkIfNeeded;

	//falter
	{ ~falter01.voicer.releaseAll; }.forkIfNeeded;

	~part4Timer.stop;
};

~part4Timer = Routine.new({
	var lengthSeconds = 480, fraction = 1.0;
	(lengthSeconds/fraction).do({|i|
		fraction.wait;
		"% / % ".postf(((i+1)*fraction).asTimeString, lengthSeconds.asTimeString);
		"(% \\%) of part 4 passed \n".postf(((((i+1)*fraction)/lengthSeconds) * 100).round(0.01));
	});
	~part4Finish.value;
});

~bcr.elements.pr_d_r.action_({|e|
	if(e.value.booleanValue, ~part4Setup, ~part4Finish);
});
)


