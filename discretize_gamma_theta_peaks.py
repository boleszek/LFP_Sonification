import numpy as np
import scipy.io as sio



def discretize_gamma_theta_peaks(signal, Fs=2000, Fds=100, Fbn=20):
    # returns raster of peaks of gamma filtered envelope and theta filtered signal
    # INPUTS:
    # signal  -  continuous LFP signal
    # Fs  -  sampling fq of LFP signal (Hz)
    # Fds  -  downsampled frequency (Hz)
    # Fbn  -  Binning frequency(for binning peak times)
    # Generally Fs > Fds > Fbn
    
    # Note: find_peaks height & distance params have been fine tuned to work at 100Hz
    
    from scipy.signal import hilbert, butter, filtfilt, find_peaks, find_peaks_cwt

    def butter_bandpass(lowcut, highcut, Fs, order=5):
        nyq = 0.5 * Fs
        low = lowcut / nyq
        high = highcut / nyq
        b, a = butter(order, [low, high], btype='band')
        return b, a

    dur = len(signal)/Fs # total duration of signal in s
    tvec = np.arange(0,dur,1/Fs) # time vector
    step = int(Fs/Fds) # step size to downsample at desired freuqency
    tvec_ds = tvec[::step] # downsampled
    
    # mean center and normalize
    signal = signal - np.mean(signal)
    signal = signal/np.max(signal)

    # Gamma fq
    b, a = butter_bandpass(40,60,Fs,order=5)
    signal_gamma = filtfilt(b, a, signal)
    
    # Theta frequency (add smoothing)
    b, a = butter_bandpass(1,17,Fs,order=3)
    signal_theta = filtfilt(b, a, signal)
    signal_theta = np.convolve(signal_theta, np.ones(120)/120, mode='same')

    # Gamma envelope
    gamma_analytic_signal = hilbert(signal_gamma)
    gamma_amplitude_envelope = np.abs(gamma_analytic_signal)
    
    # Find peaks of gamma filtered env
    gamma_env_ds = gamma_amplitude_envelope[::step]
    peaks,_ = find_peaks(gamma_env_ds,height=0)
    gamma_env_peak_times = tvec_ds[peaks]
    gamma_env_peak_hights = gamma_env_ds[peaks]
    
    # Find peaks of theta filltered signal
    theta_filt_ds = signal_theta[::step]
    peaks,_ = find_peaks(theta_filt_ds,distance=10)
    theta_filt_peak_times = tvec_ds[peaks]
    theta_filt_peak_hights = theta_filt_ds[peaks]
    
    
    # downsampled frequency (used for plotting)
    binned_gamma = np.histogram(gamma_env_peak_times,np.arange(0,dur+(1/Fds),1/Fds))[0]
    masked_gamma_env = np.multiply(gamma_env_ds,binned_gamma)
    masked_gamma_env = np.where(masked_gamma_env==0,np.nan,masked_gamma_env) # set 0s to nan
    binned_theta = np.histogram(theta_filt_peak_times,np.arange(0,dur+(1/Fds),1/Fds))[0]
    masked_theta_filt = np.multiply(theta_filt_ds,binned_theta)
    masked_theta_filt = np.where(masked_theta_filt==0,np.nan,masked_theta_filt) # set 0s to nan
    
    # # Bin gamma env & theta filt into rasters (used for sonification)
    #binned_gamma_sonify = np.histogram(gamma_env_peak_times,int(dur*Fbn))[0] # using nbins
    #binned_theta_sonify = np.histogram(theta_filt_peak_times,int(dur*Fbn))[0] # using nbins
    binned_gamma_sonify = np.histogram(gamma_env_peak_times,np.arange(0,dur+(1/Fbn),1/Fbn))[0] # using edges
    binned_theta_sonify = np.histogram(theta_filt_peak_times,np.arange(0,dur+(1/Fbn),1/Fbn))[0] # using edges
    
    
    out_dict = {
        'continuous':[
            'tvec':tvec,
            'raw_signal':signal,
            'gamma_signal':signal_gamma,
            'theta_signal':signal_theta
        ],
        'discretized':[
            'tvec_ds':tvec_ds,
            'gamma_env_ds':gamma_env_ds,
            'gamma_env_peak_times':gamma_env_peak_times,
            'gamma_env_peak_hights':gamma_env_peak_hights,
            'theta_filt_ds':theta_filt_ds,
            'theta_filt_peak_times':theta_filt_peak_times,
            'theta_filt_peak_hights':theta_filt_peak_hights,
            'masked_gamma_env':masked_gamma_env,
            'masked_theta_filt':masked_theta_filt,
            'binned_gamma_sonify':binned_gamma_sonify,
            'binned_theta_sonify':binned_theta_sonify,
            'binned_theta':binned_theta
        ]
                }
    return out_dict