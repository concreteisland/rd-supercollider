~mapArray = {arg selector, target; 
	//selector range 0-1;	
	Select.ar(selector*(target.size+1).floor.clip(0, target.size), target);
}


(
{
	r = K2A.ar(Scale.minor.degrees);
	a = Phasor.ar(1, SampleRate.ir.reciprocal * 100, 0, 1);
	c = ~mapArray.value(a, r);
	[a,c];	
}.plot(0.03)
)
