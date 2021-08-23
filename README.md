<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
	<img src="https://i.ibb.co/WKJtTzj/App-Icon.png" alt="Logo" width="140" height="140">
  </a>

  <h3 align="center">WeatherBoard</h3>

  <p align="center">
	Beautiful weather app built in Swift.
	<br />
	<br />
	<a href="https://github.com/ju5tyn/WeatherBoard/issues">Report Bug</a>
	·
	<a href="https://github.com/ju5tyn/WeatherBoard/issues">Request Feature</a>
  </p>
</p>

<!-- ABOUT THE PROJECT -->
## About The Project
<img src="https://i.ibb.co/FwCrgMh/Display1.png" alt="Logo">

This was originally just a simple design idea of mine, created in 2018. After learning Swift I decided I wanted to make it a reality.

The project uses Realm for data persistence, and the OpenWeatherMap API for fetching Weather Data. 

A problem with many weather apps that I have used is that they take a long amount of time to load, and end up bombarding the user with a mass of information. My main goal with this app was to make the most important weather information be available to the user at a glance, with the option to expand to see further details.

Another aim of this project was to reduce usage of static image assets as much as possible. Currently the only images being used in this app are for weather condition icons, with everything else ranging from gradient backgrounds, to condition effects, to custom buttons all being rendered natively using Core Graphics and Core Animation.


## Demo

<p align="center">
	<img src="https://i.ibb.co/2jnQnSP/RPReplay-Final1606495728-2020-11-27-17-00-58.gif" alt="Logo">
</p>
<!-- GETTING STARTED -->

## Installation

Setting up and building the project locally requires a few prerequisites.

1. Install CocoaPods if not already installed
```sh
sudo gem install cocoapods
```
2. Clone the repo
```sh
git clone https://github.com/ju5tyn/WeatherBoard.git
```
3. Install CocoaPod packages in project directory 
```sh
pod install
```
4. In the 'Constants' folder, create a new file called 'Keys.swift'

5. Head over to openweathermap.com, and register for an API key (free)

6. In keys.swift, add your key:

```sh
struct Keys{
	static let openweathermap = [ENTER YOUR KEY HERE]
}
```


The project will now be fully usable.


<!-- ROADMAP -->
## Roadmap

See the [open issues](https://github.com/ju5tyn/WeatherBoard/issues) for a list of proposed features (and known issues).


<!-- CONTACT -->
## Contact

Email: justynlive@gmail.com

My Website and Portfolio: [justynhenman.com](https://justynhenman.com)



<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements
* [Realm](https://realm.io)
* [LTMorphingLabel](https://github.com/lexrus/LTMorphingLabel)
* [Netguru Weather Icons](https://dribbble.com/shots/2923788-Free-Weather-Icons)

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.
