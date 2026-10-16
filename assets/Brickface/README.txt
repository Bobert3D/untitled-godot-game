Brickface v1.0 - pixel font
by fcidade

Thanks for downloading! License: see LICENSE.txt (commercial use allowed).


FILES

  Brickface.ttf
      TrueType font. Crisp at 14px and its multiples (14, 28, 42...).

  Brickface.fnt
      BMFont (text format), uses Brickface.png. Works in Godot, Phaser, LOVE,
      MonoGame, libGDX, Defold and others.

  Brickface.png
      Spritesheet: white glyphs on transparent background, 16 per row,
      11x14px cells. Tint it any color in your engine.

  Brickface-chars.txt
      The characters in the spritesheet, in order.


CHARACTER SET

  196 glyphs: ASCII, Latin-1 and the euro sign. Covers English, Portuguese,
  Spanish, French, German, Italian and most Western European languages.


QUICK START

  Godot 4
    BMFont: put Brickface.fnt and Brickface.png in the same folder of your project
    (the .fnt needs the .png next to it) and use the .fnt as the font of
    a Label.
    TTF: in the .ttf import settings set Antialiasing to None and
    Subpixel Positioning to Disabled, then use font size 14 or a multiple.

  Unity
    Import Brickface.ttf and use a font size that is a multiple of 14. Set the
    font texture filter to Point (no filter) to keep the pixels sharp.

  GameMaker
    Import Brickface.png as a sprite strip (196 frames, 16 per row,
    11x14 each), then create the font with font_add_sprite_ext(),
    passing the contents of Brickface-chars.txt as the string map.

  Anything else
    Use the .ttf at 14px or a multiple, with antialiasing / smoothing off.
