(
~part1Setup = {
	"start part 1".postln;
	~releaseAll.value;
	{ ~bcr.elements.pr_u_l.value_(1); }.forkIfNeeded;

	// field
	{
		~playSoundfile.value(~live1.tfinal1);
		~playSoundfile.value(~live1.tfinal2, args: [\loFreq,100,\loRs,1,\loGain,-6]);
		~bcr.elements.kn[1][0].value_(0.5);
		~live1.mixer.mixers[0].asMixer.level_(0.5);
		~bcr.elements.knUp[0][0].value_(0.5);
	}.forkIfNeeded;

	//buegel01
	{
		~live1.mixer.mixers[1].asMixer.level_(0.1);
		~bcr.elements.knUp[0][1].value_(0.1);
	}.forkIfNeeded;

	//middd
	{
		~middd.voicer.trigger1(5220);
		~middd.voicer.trigger1(5330, args: [\xFade, 0.5]);
		~middd.voicer.trigger1(140, args: [
			\gain, 1, \xFade, 0,
			\loFreq,100,\loRs,0.5,\loGain,12,
			\peakFreq,400,\peakRq,1,\peakGain,-12,
			\hiFreq,3200,\hiRs,1,\hiGain,5
		]);
		~bcr.elements.kn[2][0].value_(0);

		~live1.mixer.mixers[3].asMixer.level_(0.01);
		~bcr.elements.knUp[0][3].value_(0.01);
	}.forkIfNeeded;

	//teufel
	{
		~teufel1.voicer.trigger1(0);
		~teufel2.voicer.trigger1(0);

		~bcr.elements.kn[2][1].value_(0);
		~live1.mixer.mixers[4].asMixer.level_(0.01);
		~bcr.elements.knUp[0][4].value_(0.01);
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

	~part1Timer.reset;
	~part1Timer.play;
};
~part1Finish = {
	"end part 1".postln;
	{ ~bcr.elements.pr_u_l.value_(0); }.forkIfNeeded;

	//field
	{
		~live1.tfinal1.voicer.releaseAll;
		~live1.tfinal2.voicer.releaseAll;
	}.forkIfNeeded;

	//buegel01
	{ ~buegel01.voicer.releaseAll; }.forkIfNeeded;

	//middd
	{ ~middd.voicer.releaseAll }.forkIfNeeded;

	//teufel
	{
		~teufel1.voicer.releaseAll;
		~teufel2.voicer.releaseAll;
	}.forkIfNeeded;

	//holz
	{ ~holz.voicer.releaseAll; }.forkIfNeeded;

	//falter
	{ ~falter01.voicer.releaseAll; }.forkIfNeeded;

	~part1Timer.stop;
};
~part1Timer = Routine.new({
	var name = 1, lengthSeconds = 389, fraction = 1.0;
	(lengthSeconds/fraction).do({|i|
		fraction.wait;
		"% / % ".postf(((i+1)*fraction).asTimeString, lengthSeconds.asTimeString);
		"(% \\%) of part 1 passed \n".postf(((((i+1)*fraction)/lengthSeconds) * 100).round(0.01));
	});
	~part1Finish.value;
});

~bcr.elements.pr_u_l.action_({|e|
	if(e.value.booleanValue, ~part1Setup, ~part1Finish);
});
)

