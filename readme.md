### Performers Board

DISCLAIMER:

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT.

Keep the source in root open permission

## Features

* User can add them self to the list (click Signup)
* User can set stream url (click url icon)
* User remove self (click finish)
* User start his show, and stream set to the parcel
* Show who started profile picture
* User finish his show (click finish)
* Owner can remove users from the list
* Owner can move user to top in the list
* Tip forwared to current performer who started
* If not started show no tip prices will show
* Owner can set stream from any performers signed list, click on performer name
* Customizable button, add :nc, :text to name of buttom prim to change action
* :nc suffex button name will send nc card with name of button, like rules:nc
* :text suffex button name will show the nc card with name of button, like info:text, it show in the console
* welcome notecard show at rezzing (TODO: show it when empty list)
* config notecard to set many options
* Free and Open source https://github.com/zadium/PerformersBoard.lsl

## Disadvantage

* No cut, the whole tip send to performer (TODO)

#### Build FURWARE_text

Text https://wiki.secondlife.com/wiki/FURWARE_text/Tutorial#Creating_displays

* Import mesh TextMesh8.dae (we need 8 cell), Set LOD to above, name it as "FURWARE text mesh 8"
* Rez it and set Size to (x, y, z)(0.08, 1, 0.250)
* Upload "FURWARE text element initializer.lsl" inside that mesh, take it DO not rez it on ground or attach
* Take it
* Make a simple cube, Name it "FURWARE text creator"
* Copy "FURWARE text mesh 8" inside it
* upload "FURWARE text display creator.lsl" inside the cube
* Click on it to show dialog
* Set name to "default", Set Prim Kind to 8,  Rows to 16 and Columns to 4
* From menu Click Create, Link all prims into one prim, and use another cube (design it as root)
* Link the new cells generated and make sure it faced same as your board
* Make sure you are on right direction to X watch your faces
* Design your board
* Upload font image Impact-512.png the root of board with name Impact-512
* Upload "FURWARE text.lsl" into root of board
* //--Upload init.lsl into root, change the font name to Impact-512 (already set)--

* Reset Script

#### Build Objects/Prims

* Upload Performers.lsl into root

* Add Buttons with this names, `text` will show notecard on console board, `nc` will give nc to toucher

- ProfileImage (set click to Pay)
- Tip (set click to Pay)
- Signup:cmd
- Start:cmd
- Finish:cmd
- List:cmd
- info:text
- rules:nc
- calender:nc

### Config

HomeURI: if you see error when start image, and osGetAvatarHomeURI this function not work, set HomeURI in Config notecard to your grid uri with port number too

    HomeURI=http://login.osgrid.org/

    HomeURI=http://utopiaskyegrid.com:8002/

    HomeURI=http://grid.wolfterritories.org:8002/

Enable or disable Tip system

    Tip=1

StartTop: Only on top this number can start, disbale it by set to 0, any one can start

    StartTop=0

ShowStream on tip panel header or not

    ShowStream=0

OnlineTimeout: in minutes, check if started performer still in the region before auto finish

    OnlineTimeout=5

Money: You can set money list

    Money=50,100,150,200

AskTime: Show time for performer when start, it ask him/her what time he will spend in his/her show, and send notification before the time end

    Money=1

Particles: Show Particles when tip, to the performer, you can change the money.png texture

    Particles=1


## Thanks ##

Special thanks to Rogue Galaxy for testing