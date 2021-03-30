# BatteryNotifier

## General
iOS application which gives the possibility to monitor battery level and send notification if it exceeds configured limits.

It uses background refresh to make these actions in background hovewer this is managed by iOS when it calls it.

The code in master is for iOS 13+. 

There is an example of code for iOS 12- in branch `ios-12-and-less`

The BatteryController is initialized on SceneDelagate level, maybe it would be better to add it on AppDelegate level and access it as

```
(UIApplication.shared.delegate as! AppDelegate).batteryController
```
from SceneDelegate.

## Screenshot

![alt text](screen.png?raw=true)


