s.boot;

//-------- read discrete LFP timepoints ---------//

x = CSVFileReader.readInterpret(
"/Users/brainbow/Documents/LFP sonification/data_files/theta_filt_5s_binned_20Hz_corrected.txt"
).postcs;
y = CSVFileReader.readInterpret(
"/Users/brainbow/Documents/LFP sonification/data_files/gamma_env_5s_binned_20Hz_corrected.txt"
).postcs;

//take a look at the signal
a = x.plot;
a.plotMode = \bars; a.refresh;

b = y.plot;
b.plotMode = \bars; b.refresh;



//Define Drum sounds
//Using " Punchy break" from https://sccode.org/1-5bW

(
SynthDef(\kick,
	{
		|gate=1,t_trig=1,out=0,pan=0,amp=0.1,boost=4,attenuation=1,fmlevel = 0.5, noiselevel = 0.5, thumplevel=0.5,revlevel=0.1,revroomsize=0.8,revdamping=0.5,
		fmenvatttime=0.001,fmenvattcurve=0,fmenvdectime=0.1,fmenvdeccurve=0.3,
		noiseenvatttime=0.001,noiseenvattcurve=1,noiseenvdectime=0.1,noiseenvdeccurve=0.3,
		thumpenvatttime=0.001,thumpenvattcurve=1,thumpenvdectime=0.1,thumpenvdeccurve=0.3,
		fm1freq=292,fm2freq=838,fm3freq=393,fm1amt = 0.8,fm2amt=0.8,fmenvtofreq=0,
		noiselpf=20000,noisehpf=400,thumpenvtofreq=1,thumpcutoffmin=80,thumpcutoffmax=300,thumpfreqmultiplier=25,thumpfreqoffset=18|
		var audio, switch, fmenv, fm1, fm2, fm3, noise, noiseenv, thump, thumpenv;
		switch = Env.cutoff.kr(Done.freeSelf, gate);
		fmenv = Env([0,1,0],[fmenvatttime,fmenvdectime],[fmenvattcurve,fmenvdeccurve]).kr(Done.none, t_trig, 1, amp * fmlevel);
		fm1 = SinOsc.ar(fm1freq) * fm1amt.clip(0,1);
		fm2 = SinOsc.ar(fm2freq * fm1.exprange(0.1,10)) * fm2amt.clip(0,1);
		fm3 = SinOsc.ar(fm3freq * (fmenv * fmenvtofreq + 1) * fm2.exprange(0.1,10));
		noiseenv = Env([0,1,0],[noiseenvatttime,noiseenvdectime],[noiseenvattcurve,noiseenvdeccurve]).kr(Done.none, t_trig, 1, amp * noiselevel);
		noise = WhiteNoise.ar(noiseenv);
		noise = LPF.ar(noise,noiselpf.clip(100,20000));
		noise = HPF.ar(noise,noisehpf.clip(100,20000));
		thumpenv = Env([0,1,0],[thumpenvatttime,thumpenvdectime],[thumpenvattcurve,thumpenvdeccurve]).kr(Done.none, t_trig, 1, amp * thumplevel);
		thump = Mix((1..5).collect({
			|num|
			SinOsc.ar(0, Phasor.ar(t_trig, (thumpfreqmultiplier * num * 2 * pi + thumpfreqoffset) * (thumpenv * thumpenvtofreq + 1)/SampleRate.ir, 0, 2*pi));
		}));
		thump = LPF.ar(thump, thumpenv * (thumpcutoffmax - thumpcutoffmin) + thumpcutoffmin);
		audio = (fm3 * fmenv) + noise + (thump * thumpenv);
		audio = (audio * boost).tanh * attenuation;
		audio = FreeVerb.ar(audio,revlevel,revroomsize,revdamping);
		audio = Pan2.ar(audio,pan);
		Out.ar(out,audio);
	}
).add;
SynthDef(\snare,
	{
		|gate=1,t_trig=1,out=0,pan=0,amp=0.1,boost=4,attenuation=1,fmAlevel=0.5,fmBlevel=0.5,fmAfreqscale=1,fmBfreqscale=1,
		noiselevel=0.5,revlevel=0.1,revroomsize=0.8,revdamping=0.5,
		fmAenvatttime=0.001,fmAenvattcurve=0,fmAenvdectime=0.1,fmAenvdeccurve= -3,
		fmA1freq=292,fmA2freq=838,fmA3freq=393,fmA1amt = 0.8,fmA2amt=0.8,
		fmBenvatttime=0.001,fmBenvattcurve=0,fmBenvdectime=0.1,fmBenvdeccurve= -3,
		fmB1freq=292,fmB2freq=838,fmB3freq=393,fmB1amt = 0.8,fmB2amt=0.8,
		noiseenvatttime=0.001,noiseenvattcurve=0,noiseenvdectime=0.1,noiseenvdeccurve= -3,
		noiselpf=20000,noisehpf=400,fmenvtofreq=0|
		var audio, switch, fmAenv, fmBenv, fmA1, fmA2, fmA3, fmB1, fmB2, fmB3, noise, noiseenv;
		fmA1freq = fmA1freq * fmAfreqscale;fmA2freq = fmA2freq * fmAfreqscale;fmA3freq = fmA3freq * fmAfreqscale;
		fmB1freq = fmB1freq * fmBfreqscale;fmB2freq = fmB2freq * fmBfreqscale;fmB3freq = fmB3freq * fmBfreqscale;
		switch = Env.cutoff.kr(Done.freeSelf, gate);
		fmAenv = Env([0,1,0],[fmAenvatttime,fmAenvdectime],[fmAenvattcurve,fmAenvdeccurve]).kr(Done.none, t_trig, 1, amp * fmAlevel);
		fmA1 = SinOsc.ar(fmA1freq) * fmA1amt.clip(0,1);
		fmA2 = SinOsc.ar(fmA2freq * fmA1.exprange(0.1,10)) * fmA2amt.clip(0,1);
		fmA3 = SinOsc.ar(fmA3freq * (fmAenv * fmenvtofreq + 1) * fmA2.exprange(0.1,10));
		fmBenv = Env([0,1,0],[fmBenvatttime,fmBenvdectime],[fmBenvattcurve,fmBenvdeccurve]).kr(Done.none, t_trig, 1, amp * fmBlevel);
		fmB1 = SinOsc.ar(fmB1freq) * fmB1amt.clip(0,1);
		fmB2 = SinOsc.ar(fmB2freq * fmB1.exprange(0.1,10)) * fmB2amt.clip(0,1);
		fmB3 = SinOsc.ar(fmB3freq * (fmBenv * fmenvtofreq + 1) * fmB2.exprange(0.1,10));
		noiseenv = Env([0,1,0],[noiseenvatttime,noiseenvdectime],[noiseenvattcurve,noiseenvdeccurve]).kr(Done.none, t_trig, 1, amp * noiselevel);
		noise = WhiteNoise.ar(noiseenv);
		noise = LPF.ar(noise,noiselpf.clip(100,20000));
		noise = HPF.ar(noise,noisehpf.clip(100,20000));
		audio = (fmA3 * fmAenv) + (fmB3 * fmBenv) + noise;
		audio = (audio * boost).tanh * attenuation;
		audio = FreeVerb.ar(audio,revlevel,revroomsize,revdamping);
		audio = Pan2.ar(audio,pan);
		Out.ar(out,audio);
	}
).add;
SynthDef(\hat,
	{
		|gate=1,t_trig=1,out=0,pan=0,amp=0.1,boost=4,attenuation=1,fmlevel = 0.5, fmfreqscale=1,noiselevel = 0.5, revlevel=0.1,revroomsize=0.8,revdamping=0.5,
		fmenvatttime=0.001,fmenvattcurve=0,fmenvdectime=0.1,fmenvdeccurve= -3,
		noiseenvattime=0.001,noiseenvattcurve=0,noiseenvdectime=0.1,noiseenvdeccurve= -3,
		fm1freq=292,fm2freq=838,fm3freq=393,fm1amt = 0.8,fm2amt=0.8,
		noiselpf=20000,noisehpf=400|
		var audio, switch, fmenv, fm1, fm2, fm3, noise, noiseenv;
		fm1freq = fm1freq * fmfreqscale;fm2freq = fm2freq * fmfreqscale;fm3freq = fm3freq * fmfreqscale;
		switch = Env.cutoff.kr(Done.freeSelf, gate);
		fmenv = Env([0,1,0],[fmenvatttime,fmenvdectime],[fmenvattcurve,fmenvdeccurve]).kr(Done.none, t_trig, 1, amp * fmlevel);
		fm1 = SinOsc.ar(fm1freq) * fm1amt.clip(0,1);
		fm2 = SinOsc.ar(fm2freq * fm1.exprange(0.1,10)) * fm2amt.clip(0,1);
		fm3 = SinOsc.ar(fm3freq * fm2.exprange(0.1,10));
		noiseenv = Env([0,1,0],[noiseenvattime,noiseenvdectime],[noiseenvattcurve,noiseenvdeccurve]).kr(Done.none, t_trig, 1, amp * noiselevel);
		noise = WhiteNoise.ar(noiseenv);
		noise = LPF.ar(noise,noiselpf.clip(100,20000));
		noise = HPF.ar(noise,noisehpf.clip(100,20000));
		audio = (fm3 * fmenv) + (noise * noiseenv);
		audio = (audio * boost).tanh * attenuation;
		audio = FreeVerb.ar(audio,revlevel,revroomsize,revdamping);
		audio = Pan2.ar(audio,pan);
		Out.ar(out,audio);
	}
).add;
)

(
~kickpatch = (
	noiseenvdectime: 0.082310089963034,
	attenuation: 0.22910061478615,
	fm1amt: 0.22018975019455,
	fm2amt: 0.1617539525032,
	thumpenvdectime: 0.096060367398437,
	revlevel: 0.046831969171762,
	fmenvtofreq: 0.02991867002122,
	boost: 4.4948384561961,
	thumplevel: 0.68209940195084,
	thumpenvdeccurve: 1.8052649497986,
	thumpenvtofreq: 0.66234208917665,
	thumpfreqoffset: 10.603728294373,
	fm3freq: 56.014459619136,
	revdamping: 0.9112092256546,
	fm2freq: 240.34838654631,
	noiseenvatttime: 0.02882155594665,
	noisehpf: 1957.5643831734,
	thumpcutoffmin: 459.57285712758,
	thumpfreqmultiplier: 19.783316850662,
	fmenvdectime: 0.37148556080558,
	noiselevel: 0.15430730581284,
	thumpenvatttime: 0.001,
	revroomsize: 0.71596258878708,
	fmlevel: 0.70129412412643,
	fmenvdeccurve: -3.5376764833927,
	thumpcutoffmax: 92.37343754883,
	fm1freq: 525.46488393532,
	noiseenvdeccurve: -3.7274378538132,
	noiselpf: 3060.9291005849
);
~snarepatch = (
	fmA1amt: 0.25185558199883,
	fmAfreqscale: 1.0504953073651,
	fmB1amt: 0.45330801606178,
	fmAlevel: 0.62608307600021,
	noiseenvdeccurve: -3.6571384966373,
	fmBenvdeccurve: -1.207347214222,
	fmA2freq: 103.80361514711,
	noisehpf: 3482.8808579243,
	fmB3freq: 87.961764307079,
	fmAenvdectime: 0.16059027158164,
	boost: 7.3301957098881,
	noiseenvdectime: 0.1206777957479,
	revdamping: 0.62858611345291,
	fmA3freq: 175.20096253367,
	fmBenvdectime: 0.089293047347157,
	fmB2freq: 70.818393507471,
	fmB2amt: 0.50210249423981,
	fmBfreqscale: 1.8168465878768,
	fmAenvdeccurve: -2.4535009264946,
	noiselpf: 5982.6825037192,
	noiseenvatttime: 0.0073936101820986,
	fmenvtofreq: 0.17540055065142,
	fmA1freq: 67.033367952364,
	fmBlevel: 0.55415153503418,
	revroomsize: 0.5787867307663,
	fmA2amt: 0.15265274047852,
	noiselevel: 0.6460028886795,
	fmB1freq: 470.81620150722,
	revlevel: 0.25108739733696,
	attenuation: 0.33438730239868
);
~hatpatch = (
	fm1amt: 0.25010031461716,
	fmfreqscale: 2.5124176161438,
	noiselpf: 20000.0,
	fmlevel: 0.15848658978939,
	noisehpf: 4743.8046187692,
	revroomsize: 0.19304300844669,
	fm2freq: 1338.7784155564,
	boost: 4.4979889479394,
	attenuation: 0.12104642391205,
	fmenvdeccurve: -4.5520303025842,
	noiseenvdectime: 0.12313126194395,
	fm1freq: 1220.1787917932,
	fm3freq: 1507.0961269746,
	noiseenvatttime: 0.001,
	noiseenvdeccurve: -2.4986642599106,
	fm2amt: 0.65971809625626,
	revdamping: 0.71325391530991,
	noiselevel: 1.0,
	revlevel: 0.15580302476883,
	fmenvdectime: 0.034721955338952
);
)



//play the sequences


TempoClock.default.tempo = 2;

// good tempo: tempo = 1, dur = 0.125 /or/ tempo = 2, dur = 0.25 (do they sound different?)

(
Pdef(\kick,
	Pmono(
		\kick,
		\amp, Pseq(100*x[0],inf),
		\amp, Pkey(\amp) / 100,
		\trig, Pif(Pkey(\amp) > 0, 1, 0),
		\dur, 0.125,
		\timingOffset, Pseg(Pseq([0,0.05],inf),Pseq([0.5,0.5],inf),\sine,inf)
	)
).play(protoEvent: ~kickpatch);
Pdef(\hat,
	Pmono(
		\hat,
		\amp, Pseq(60*y[0],inf),
		\amp, Pkey(\amp) / 100,
		\trig, Pif(Pkey(\amp) > 0, 1, 0),
		\dur,0.125,
		\timingOffset, Pseg(Pseq([0,0.05],inf),Pseq([0.5,0.5],inf),\sine,inf)
	)
).play(protoEvent: ~hatpatch);
)

[\kick,\snare,\hat].do({|pat|Pdef(pat).stop;});



// save recording

(
Pdef(\kick,
	Pmono(
		\kick,
		\amp, Pseq(100*x[0],inf),
		\amp, Pkey(\amp) / 100,
		\trig, Pif(Pkey(\amp) > 0, 1, 0),
		\dur, 0.25,
		\timingOffset, Pseg(Pseq([0,0.05],inf),Pseq([0.5,0.5],inf),\sine,inf)
	)
).play(protoEvent: ~kickpatch);
Pdef(\hat,
	Pmono(
		\hat,
		\amp, Pseq(60*y[0],inf),
		\amp, Pkey(\amp) / 100,
		\trig, Pif(Pkey(\amp) > 0, 1, 0),
		\dur,0.25,
		\timingOffset, Pseg(Pseq([0,0.05],inf),Pseq([0.5,0.5],inf),\sine,inf)
	)
).play(protoEvent: ~hatpatch);
s.record(duration: 13);
)

[\kick,\snare,\hat].do({|pat|Pdef(pat).stop;});

// see where recordings are stored
thisProcess.platform.recordingsDir