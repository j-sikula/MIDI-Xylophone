# MIDI-Xylophone

### Team members

* Josef Sikula (responsible for GUI [MIDI xylophone](midi_xylophone))
* Ondrej Vlcek (responsible for [MIDI source device](midi_source))
* Ilja Zhigachev, Mark Kovychev (responsible for [Xylophone controller](xylophone_controller))

## Hardware description
From MIDI source protocol via USB (UART) is sent to PC/Smartphone, then via USB (UART) is sent to MIDI Target, note is played on Xylophone and played note is sent back via USB to PC/Smartphone.

![schematic](images/SchematicDiagram.jpg)


## Software description

Include flowcharts/state diagrams of your algorithm(s) and direct links to the source files in PlatformIO `src` or `lib` folders. Present the libraries you used in the project.

### GUI
[Documentation](https://raw.githack.com/j-sikula/MIDI-Xylophone/refs/heads/main/midi_xylophone/doc/api/index.html)

### MIDI Source
[Documentation](https://raw.githack.com/j-sikula/MIDI-Xylophone/refs/heads/main/midi_source/documentation/html/group__memory__song.html)


## Instructions and photos

Describe how to use the application. Add photos or videos of your application.

## References and tools

1. [AVR course GitHub](https://github.com/tomas-fryza/avr-course)
2. [GitHub Copilot for VS Code](https://code.visualstudio.com/docs/copilot/overview)
3. [Flutter](https://docs.flutter.dev/get-started/install/windows/desktop)
