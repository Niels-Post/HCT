////////////////////////////////////////////////////////////
// This Header was edited to provide code completion on platforms without SFML installed.
// As such this file is not intended for working compilation
// !!! This file should not be compiled into a project
/////////////////////////////////////////////////////////////
// SFML - Simple and Fast Multimedia Library
// Copyright (C) 2007-2019 Laurent Gomila (laurent@sfml-dev.org)
//
// This software is provided 'as-is', without any express or implied warranty.
// In no event will the authors be held liable for any damages arising from the use of this software.
//
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it freely,
// subject to the following restrictions:
//
// 1. The origin of this software must not be misrepresented;
//    you must not claim that you wrote the original software.
//    If you use this software in a product, an acknowledgment
//    in the product documentation would be appreciated but is not required.
//
// 2. Altered source versions must be plainly marked as such,
//    and must not be misrepresented as being the original software.
//
// 3. This notice may not be removed or altered from any source distribution.
//
////////////////////////////////////////////////////////////

#ifndef SFML_GRAPHICS_HPP
#define SFML_GRAPHICS_HPP

////////////////////////////////////////////////////////////
// Headers
////////////////////////////////////////////////////////////

namespace sf {
    class VideoMode {
    public:
        VideoMode(int x, int y){}
    };

    class Event {
    public:
        std::string type = "";
        static std::string Closed;
    };

    class Color {
    public:
        Color(uint8_t r, uint8_t g, uint8_t b, int t){}
    };

    class Image {
    public:
        void create(int x, int y){}
        void setPixel(int x, int y, Color c){}
    };

    class Texture {
    public:
        void loadFromImage(Image i){}
    };

    class Sprite {
    public:
        void setTexture(Texture t, bool f) {}

    };

    class RenderWindow {
    public:
        RenderWindow(VideoMode m, std::string t){}
        bool isOpen(){return true;}
        bool pollEvent(Event e){return true;}
        void close(){}
        void clear(){}
        void draw(Sprite s) {}
        void display(){}
    };




}

#endif // SFML_GRAPHICS_HPP

////////////////////////////////////////////////////////////
/// \defgroup graphics Graphics module
///
/// 2D graphics module: sprites, text, shapes, ...
///
////////////////////////////////////////////////////////////
