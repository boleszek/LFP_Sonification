# LFP_Sonification
Sonification of olfactory bulb (OB) local field potential (LFP) data

# Science Background
The [local field potential](http://www.scholarpedia.org/article/Local_field_potential) (LFP) is the electric field created by the coordinated activity of 100s or 1000s of indivudual neurons. When this collective activity moves up and down in unison, the LFP

The [olfactory bulb](https://en.wikipedia.org/wiki/Olfactory_bulb) (OB) is the part of the brain that processes the sense of smell. The OB produces highly coordinated neural activity, also called "oscillations", between exitatory mitral cells and inhobitory granule cells. When an odorant is detected by olfactory receptor neurons in the nose, these oscillations coordinate and adjust the incoming odor signal as it is passed to downstream brain areas. In rodent brains, there are generally 3 frequency bands of LFP oscillations which correspond to different things.
* Theta (1 - 10 Hz) : corresponds to breathing rhythm
* Beta (15 - 30 Hz) : corresponds to strong odorant stimuli as well as coordinated activity between OB and other brain regions
* Gamma (60 - 100 Hz) : corresponds to native (resting) activity as well as odor processing activity

Durring sniffing, gamma oscillations tend to occur in bursts on each inhalation/exhalation cycle. When an odor is present the gamma rythms may be enahnced, shifted in freuqncy, or overtaken by the beta ryhthm.

# Sonification task
[Supercolider](https://supercollider.github.io/) is used to sonify the **amplitude peaks** of the theta and gamma rhythms. The current implemtation assigns a bass drum to the theta-filtered LFP and a hi-hat to the gamma-filtered LFP, resulting in a drum beat tracking the relative timing of theta and gamma peaks. By default, ScreenFlow saves audio to `/Users/username/Music/SuperCollider Recordings/` on Mac. An example audio file is provided in `SuperCollider/example_audio/kick_hat_correct_binning_13s.aiff`.

Python is used to process the raw data into a format digestible by Supercollider. See `LFP_sonification_preprocessing.ipynb` for examples of how to get the peaks of the theta and gamma filtered LFP signal.

[Screenflow](https://www.telestream.net/screenflow/overview.htm) is used to sync video and sound to show the drum beat playing as the LFP signal sweeps across the screen.

Example vids of the synced sonification and video are in `synced_videos` folder.

## Data processing workflow
**Simplified workflow**
```
python : data processing and video creation --> .txt data files, .mp4 video files
Supercollider : sonification of processed data --> .aiff sound files
Screenflow : sync sonification and video together --> .mp4 video files
````

**More detailed workflow**

In python:
* load raw LFP data
* filter LFP to gamma or theta frequency bands
* create animation showing gamma and theta over time and write to `.mp4`
* write peaks times of filtered LFP envelopes to `.txt` files (to be later read by Supercollider)

In Supercollider:
* read peak times `.txt` files
* sonify and write to `.aiff` files

In ScreenFlow:
* load video (`.mp4`) and sound (`.aiff`) files
* make any adjustments necessary to sync the sounds to the video, then write to `.mp4` file

Alternatively, you could use [FFmpeg](https://ffmpeg.org/) instead of ScreenFlow to add the sound to the video. This has advantage of being more automated, but disadvantage of not being able to do manual tweaks if needed. Example of how to use FFmpeg is below
```
ffmpeg -i '/LFP_Sonification/gamma_theta_peaks_40fps.mp4' -i '/Users/username/Music/SuperCollider Recordings/kick_hat_correct_binning_13s.aiff' -c:v copy -c:a aac /LFP_Sonification/synced_videos/sonified_lfp.mp4
```

# Data Source
Data for this project were recorded from rats by graduate students in the [Kay lab](https://kaylab.uchicago.edu/) at the University of Chicago.
