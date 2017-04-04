(
~part3Setup = {
	"start part 3".postln;
	~releaseAll.value;
	{ ~bcr.elements.pr_d_l.value_(1); }.forkIfNeeded;

	//field
	{
		~playSoundfile.value(~live1.ulva, 0,[
			\xFade, 1, \gain, 1,
			\loFreq,100,\loRs,0.5,\loGain,2,
			\peakFreq,400,\peakRq,0.3,\peakGain,-6,
			\hiFreq,1200,\hiRs,1,\hiGain,0
		]);
		~live1.mixer.mixers[0].asMixer.level_(0.5);
		~bcr.elements.knUp[0][0].value_(0.5);
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

	//radio chaos
	{
		~radioChaos.voicer.trigger1(0);
		~live1.mixer.mixers[4].asMixer.level_(0.0);
		~bcr.elements.knUp[0][4].value_(0.0);
	}.forkIfNeeded;

	//holz
	{
		~live1.mixer.mixers[5].asMixer.level_(0);
		~bcr.elements.knUp[0][5].value_(0);
	}.forkIfNeeded;

	//falter
	{
		~live1.mixer.mixers[6].asMixer.level_(0);
		~bcr.elements.knUp[0][6].value_(0);
	}.forkIfNeeded;

	~part3Timer.reset;
	~part3Timer.play;
};
~part3Finish = {
	"end part 3".postln;
	{ ~bcr.elements.pr_d_l.value_(0); }.forkIfNeeded;

	//field
	{ ~live1.ulva.voicer.releaseAll; }.forkIfNeeded;

	//buegel01
	{ ~buegel01.voicer.releaseAll; }.forkIfNeeded;

	//conv
	{
		~ulvaC.voicer.releaseAll;
		~ulvaC.voicerPlay.releaseAll;
	}.forkIfNeeded;

	//radio chaos
	{ ~radioChaos.voicer.releaseAll; }.forkIfNeeded;

	//holz
	{ ~holz.voicer.releaseAll; }.forkIfNeeded;

	//falter
	{ ~falter01.voicer.releaseAll; }.forkIfNeeded;

	~part3Timer.stop;
};
~part3Timer = Routine.new({
	var lengthSeconds = 420.61227083333, fraction = 1.0;
	(lengthSeconds/fraction).do({|i|
		fraction.wait;
		"% / % ".postf(((i+1)*fraction).asTimeString, lengthSeconds.asTimeString);
		"(% \\%) of part 3 passed \n".postf(((((i+1)*fraction)/lengthSeconds) * 100).round(0.01));
	});
	~part3Finish.value;
});

~bcr.elements.pr_d_l.action_({|e|
	if(e.value.booleanValue, ~part3Setup, ~part3Finish);
});
)