# midi_xylophone

An application which connects two Serial ports using simplified MIDI protocol.
Character '0' means note C1 and '7' means note C2.

Prints all data from both ports, when protocol decoded, prints names of decoded notes.
All data from MIDI source are being sent to MIDI target. 

## Getting Started

[Tutorial for installing Flutter on Windows](https://docs.flutter.dev/get-started/install/windows/desktop)

For creating runnable windows application run in cmd
```
flutter build windows --release
```

When problems appear, run
```
flutter doctor
```

Firstly open port with MIDI source

[Online documentation guide](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
