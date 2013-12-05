Geofencing-Example
==================

*For use in CS175 (Mobile Programming at San Jose State University) grad-level presentation on Thursday, December 5, 2013.
[Powerpoint Presentation used during lecture](https://docs.google.com/presentation/d/12FLbWMuX3QKPSBBJ6Ad2s44BT4LnCfon9ThoaOjUvXU/edit?usp=sharing "Powerpoint Presentation")

The Geofencing example here provides a brief illustration of how to utilize certain CoreLocation-level features. The code itself uses a UITableViewController to display added locations (using long/lat values). The aforementioned locations are generated every time the user taps the '+' button, which simply locks onto his/her current coordinates. 

A CLCircularRegion (in iOS 7, or CLRegion in iOS 6) is then used to create a circular region stretching out 250 meters from the center coordinate. This region is then added to the device's watchlist. The Location Manager will be notified as to the movements of the user. When it detects that the user has left the circular region, it will fire off a descriptive local notification, which they can use to open the app and then create a new region.
