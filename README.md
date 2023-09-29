<p align="center">
<br/>
<a href="https://github.com/ursi">
  <img src="https://user-images.githubusercontent.com/26458780/278759718-c3b59702-6bb4-4fbf-8a1d-fff04e933dd2.png" height=250 title="NixThePlanet"/>
</a>
</p>

# NixThePlanet

This is a Nix flake that allows you to run medieval operating systems, some new
and some old. Some other candidate names for this flake were:

- `ProprietareKackscheisse`
- `nix-zoo`
- `Windows 12`
- `menagerie`

# Thanks

Massive thanks to the following for various help and with the repository!

- [Michael Hoang](https://github.com/enzime) For getting start with the idea
- [Robert Hensing](https://github.com/roberth) For putting up with determinism questions
- [Max Headroom](https://github.com/max-privatevoid) For figuring out why fetching was non deterministic when using `fetch-macOS-v2.py`

# TODO

- Find a more reproducible way of fetching macOS BaseSystems, currently the
  board identifier determines what is fetched, and Apple changes what OS is
  compatible with which board identifier routinely
- Find a faster way of completing the installation with even less dependence on
  hardware speed
- Add amiga, macOS System 1 - 7, Windows 1.0, Windows 95 and Windows 98
- Find a way of getting serial access for Dosbox so we can make `runInWin311`
  and similar functions
- Implement `runInDarwinVM` using the `makeDarwinImage` primitive
- Remove dependency on OSX-KVM that is currently being cargo-culted into the
  repository without a git submodule
- Put screen captures into `$out` for the image builders using `vncdo`, would
  help with debugging
- Maybe record a video of the automation session in the image builders using
  `ffmpeg`, could help with debugging
- Better logging in image builders
- Maybe make a framework for using `expect` and `tesseract` together with Nix,
  similar to the NixOS Testing Framework
- Make some installation options configurable, such as initial username/pass for
  all image builders

Notable changes to the `OpenCore-Boot.sh` script for the OSX-KVM repository that
I am copy-pasting into this repo temporarily for bootstrapping purposes are:

- Using `snapshot=on` and generating QCOW2 images backed by raw disk images to
improve performance and disk usage during installation phase
- Disabling nic during installation
- Doing everything offline by default
- Limiting CPU to one core and thread for determinism, there were some threading
  issues during installation that caused non deterministic behavior and failed
installations that lead to this.
- Using QEMU's monitor feature to safely powerdown automatically post
installation

I am also changing `scripts/run_offline.sh` to automatically partition the Disk.
