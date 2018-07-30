# Signal Generator 🎛️

A signal generator built in MATLAB. The program generates and plots a sine, square or saw wave with user-defined frequency, timespan, phase and number of sample points. Simultaneously, it computes the Fourier transform of the generated wave, and calculates and plots the power spectrum of the signal. Windowing in real space is also implemented and noise can also be added to the input signal. By Fourier transforming the noisy signal and recovering the peak power frequency, the signal is 'cleaned up' and re-plotted.

![Screenshot](vaughan-rich.github.com/signal-generator/screen.png)

# To Note

This program includes both windowing in real space and the additional features of adding noise / cleaning up of a noisy wave. Both, however, cannot be done simultaneously in this version. I've built in some failsafes to prevent crashing if this is attempted, and will look to fix this in a later version.

# To-Do List For Future Versions

* Add support for windowing and adding noise at the same time.
* Package sections of if-else logic into custom functions (or adjust altogether) for tidier, more concise and less repetitive code.
