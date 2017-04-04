(
~releaseAll = {
	~live1 !? {|l| l.tfinal1 !? {|t| t.voicer !? {|v| v.releaseAll}}};
	~live1 !? {|l| l.tfinal2 !? {|t| t.voicer !? {|v| v.releaseAll}}};
	~live1 !? {|l| l.hafen1 !? {|t| t.voicer !? {|v| v.releaseAll}}};
	~live1 !? {|l| l.hafen2 !? {|t| t.voicer !? {|v| v.releaseAll}}};
	~live1 !? {|l| l.ulva !? {|t| t.voicer !? {|v| v.releaseAll}}};
	~live1 !? {|l| l.trainrattle !? {|t| t.voicer !? {|v| v.releaseAll}}};
	~buegel01 !? {|t| t.voicer !? {|v| v.releaseAll}};
	~middd !? {|t| t.voicer !? {|v| v.releaseAll}};
	~teufel1 !? {|t| t.voicer !? {|v| v.releaseAll}};
	~teufel2 !? {|t| t.voicer !? {|v| v.releaseAll}};
	~buegel02 !? {|t| t.voicer !? {|v| v.releaseAll}};
	~bruess01 !? {|t| t.voicer !? {|v| v.releaseAll}};
	~hundebass !? {|t| t.voicer !? {|v| v.releaseAll}};
	~falter01 !? {|t| t.voicer !? {|v| v.releaseAll}};
	~klavier !? {|t| t.voicer !? {|v| v.releaseAll}};
	~ulvaC !? {|t| t.voicer !? {|v| v.releaseAll}};
	~ulvaC !? {|t| t.voicerPlay !? {|v| v.releaseAll}};
	~radioChaos !? {|t| t.voicer !? {|v| v.releaseAll}};
	~rattle !? {|t| t.voicer !? {|v| v.releaseAll}};
	~holz !? {|t| t.voicer !? {|v| v.releaseAll}};
}
)


~releaseAll.value;







