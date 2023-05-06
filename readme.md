### Performers Board

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT.

#### Build FURWARE_text

Text https://wiki.secondlife.com/wiki/FURWARE_text/Tutorial#Creating_displays

* Import mesh TextMesh8.dae (we need 8 cell), Set LOD to above, name it as "FURWARE text mesh 8"
* Rez it and set Size to (x, y, z)(0.08, 1, 0.250)
* Upload "FURWARE text element initializer.lsl" insite that mesh, take it DO not rez it on ground or attach
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
* Upload init.lsl into root, change the font name to Impact-512 (already set)
* Upload Performers.lsl into root

* Reset Script

#### Build Objects/Prims

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

if you see error when start image, and osGetAvatarHomeURI this function not work, set HomeURI in Config notecard to your grid uri with port number too

    HomeURI=http://login.osgrid.org/

    HomeURI=http://discoverygrid.net:8002/

    HomeURI=http://grid.wolfterritories.org:8002/
