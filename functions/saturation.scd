(
{
	var x = SinOsc.ar(220, 0, 0.8);
	var amount = MouseX.kr(-1, 1);
	var k = 2 * amount / (1 - amount);
	(1 + k) * x / (1 + (k * x.abs));
}.scope
	

)

//a bit of filtering and tweaking, you get a decent guitar amp...

(
{
	var in, amount, amCoef;
	in = HPF.ar(SoundIn.ar(0), 400)*5;
	amount = 0.99;
	amCoef= 2*amount/(1-amount);
	MidEQ.ar(LPF.ar((1+amCoef)*in/(1+(amCoef*in.abs)), [3800, 3900])*0.5, 120, 0.7, 8);
}.play;
)

(
{
	var x = SinOsc.ar(220, 0, 0.8);
	var amount = MouseX.kr(0, 10);
	SoftClipAmp8.ar(x,amount);
}.scope
)
	
(
{
	var x = SinOsc.ar(220, 0, 0.8);
	var amount = MouseX.kr(0, 2pi);
	AudioMSG.ar(x, amount);
}.scope
)
	

