(
~part2Setup = {
	"start part 2".postln;
	~releaseAll.value;
	{
		~bcr.elements.pr_u_r.value_(1);
	}.forkIfNeeded;

	//field
	{
		~playSoundfile.value(~live1.hafen1, 0.5);
		~playSoundfile.value(~live1.hafen2, 0.5);
		~bcr.elements.kn[1][1].value_(0.5);
		~live1.mixer.mixers[0].asMixer.level_(0.5);
		~bcr.elements.knUp[0][0].value_(0.5);
	}.forkIfNeeded;

	//buegel01
	{
		~live1.mixer.mixers[1].asMixer.level_(0.25);
		~bcr.elements.knUp[0][1].value_(0.25);
	}.forkIfNeeded;

	//birne
	{
		~live1.mixer.mixers[2].asMixer.level_(0.25);
		~bcr.elements.knUp[0][2].value_(0.25);
	}.forkIfNeeded;

	//radio brussels
	{
		~bruess01.voicer.trigger1(0);
		~bcr.elements.kn[1][2].value_(0.5);

		~live1.mixer.mixers[3].asMixer.level_(0.01);
		~bcr.elements.knUp[0][3].value_(0.01);
	}.forkIfNeeded;

	//hundebass
	{
		~live1.mixer.mixers[4].asMixer.level_(0.4);
		~bcr.elements.knUp[0][4].value_(0.4);
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

	//klavier
	{
		~live1.mixer.mixers[7].asMixer.level_(0.75);
		~bcr.elements.knUp[0][7].value_(0.75);
	}.forkIfNeeded;



	~part2Timer.reset;
	~part2Timer.play;
};
~part2Finish = {
	"end part 2".postln;
	{ ~bcr.elements.pr_u_r.value_(0); }.forkIfNeeded;

	{
		~live1.hafen1.voicer.releaseAll;
		~live1.hafen2.voicer.releaseAll;
	}.forkIfNeeded;

	//buegel01
	{ ~buegel01.voicer.releaseAll; }.forkIfNeeded;

	//birne
	{ ~buegel02.voicer.releaseAll; }.forkIfNeeded;

	//radiobrussels
	{ ~bruess01.voicer.releaseAll; }.forkIfNeeded;

	//hundebass
	{ ~hundebass.voicer.releaseAll; }.forkIfNeeded;

	//holz
	{ ~holz.voicer.releaseAll; }.forkIfNeeded;

	//falter
	{ ~falter01.voicer.releaseAll; }.forkIfNeeded;

	//klavier
	{ ~klavier.voicer.releaseAll; }.forkIfNeeded;

	~part2Timer.stop;
};
~part2Timer = Routine.new({
	var lengthSeconds = 420.0, fraction = 1.0;
	(lengthSeconds/fraction).do({|i|
		fraction.wait;
		"% / % ".postf(((i+1)*fraction).asTimeString, lengthSeconds.asTimeString);
		"(% \\%) of part 2 passed \n".postf(((((i+1)*fraction)/lengthSeconds) * 100).round(0.01));
	});
	~part2Finish.value;
});

~bcr.elements.pr_u_r.action_({|e|
	if(e.value.booleanValue, ~part2Setup, ~part2Finish);
});
)