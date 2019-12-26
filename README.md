## IOBat

Battery temperature, as provided by IOKit.

This tool was originally developed to determine the temperature of my laptop while working outside on a hot day.
It has been adapted to compile for any platform with IOKit (e.g. macOS, iOS).
Exit status codes have been added to make using `iobat` with scripts easier.

```
Usage: iobat [-s]
  Battery temperature, as provided by IOKit
    -s  Silent, print nothing

Exit status is
  0 if the temperature is within recommended operating temperatures,
  1 if the temperature is too low,
  2 if the temperature is too high,
  3 if the temperature is either too high or low, but which cannot be determined.
```

