<p align="center">
  <img width="256" alt="Adwaita Template Icon" src="data/icons/io.github.AparokshaUI.AdwaitaTemplate.svg">
  <h1 align="center">Adwaita Template</h1>
</p>

_Adwaita Template_ is a template application for the [Adwaita package](https://github.com/AparokshaUI/Adwaita/).

## Table of Contents

- [Installation](#Installation)
- [Usage](#Usage)
- [Thanks](#Thanks)

## Installation

### Install the Swift Freedesktop SDK Extension

1. Install `flatpak` and `flatpak-builder` (https://flatpak.org/).
2. Add Flathub to Flatpak:
```
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```
3. Install the newest version of the Freedesktop SDK:
```
flatpak install org.freedesktop.Sdk
```
4. Install the LLVM 16 Freedesktop extension:
```
flatpak install org.freedesktop.Sdk.Extension.llvm16/x86_64/23.08
```
5. Install the GNOME SDK. It's not required for building the Swift Freedesktop SDK extension, but later for building the application:
```
flatpak install org.gnome.Sdk
```
6. Download the [Swift Freedesktop SDK extension](https://github.com/AparokshaUI/org.freedesktop.Sdk.Extension.swift) using [this](https://github.com/AparokshaUI/org.freedesktop.Sdk.Extension.swift/archive/refs/heads/main.zip) link.
7. In a terminal, enter the downloaded directory using `cd`.
8. Install the Swift Freedesktop SDK extension:
```
sudo flatpak-builder build-dir org.freedesktop.Sdk.Extension.swift.json --install --force-clean
```

### Install Other Tools

The following tools are required or recommended for editing this repository:
- [GNOME Builder](https://flathub.org/apps/org.gnome.Builder)
- [App Icon Preview](https://flathub.org/apps/org.gnome.design.AppIconPreview)
- [Inkscape](https://flathub.org/apps/org.inkscape.Inkscape)

## Usage

1. Open this project in GNOME Builder. Copy the path to the containing folder of this file (in the sidebar) and replace the following piece of text in the `io.github.AparokshaUI.AdwaitaTemplate.json` file:
```
https://github.com/AparokshaUI/AdwaitaTemplate
```
with the following syntax (replace `/path/to/directoy`):
```
file:///path/to/directory
```
2. Build and run the application.
3. Change the app's name and other information about the application in the following files (and file names):
    - `README.md`
    - `Package.swift`
    - `io.github.AparokshaUI.AdwaitaTemplate.json`
    - `Sources/AdwaitaTemplate.swift`
    - `data/io.github.AparokshaUI.AdwaitaTemplate.metainfo.xml`
    - `data/io.github.AparokshaUI.AdwaitaTemplate.desktop`
    - `data/icons/io.github.AparokshaUI.AdwaitaTemplate.Source.svg`
    - `data/icons/io.github.AparokshaUI.AdwaitaTemplate.svg`
    - `data/icons/io.github.AparokshaUI.AdwaitaTemplate-symbolic.svg`
4. Edit the code. Help is available [here](https://david-swift.gitbook.io/adwaita/), ask questions in the [discussions](https://github.com/AparokshaUI/Adwaita/discussions/).
5. Edit the app's icons using the previously installed tools according to [this](https://blogs.gnome.org/tbernard/2019/12/30/designing-an-icon-for-your-app/) tutorial.
6. In GNOME Builder, click on the dropdown next to the hammer and then on `Export`. Wait until the file explorer appears, open the `.flatpak` file and install the app on your device!

## Thanks

### Dependencies
- [Adwaita](https://github.com/AparokshaUI/Adwaita) licensed under the [GPL-3.0 license](https://github.com/AparokshaUI/Adwaita/blob/main/LICENSE.md)

