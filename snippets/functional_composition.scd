f = {arg e; 
	e.out = e.out + 2 + e.out2;
	e;
};
g = {arg e; 
	e.out = e.out + 3;
	e;
};
h = {arg e; 
	e.out = e.out + 4;
	e;
};


z = f <> g <> h

z.value((out: 1, out2:2))
