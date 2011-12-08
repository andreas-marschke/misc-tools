#include<cairo.h>
#include<iostream>
#include<string>

using std::string;
using namespace std;


int main(int argc, char* argv[])
{
  int x,y,width,height;
  float size_font;
  
  x = 20;
  y = 20;
  width = 200;
  height = 40;
  size_font=20.0;
  string file_path(argv[1]);
  
  
  cairo_surface_t *surface;
  cairo_t *cr;

  
  surface = cairo_image_surface_create (CAIRO_FORMAT_ARGB32, width, height);
  cr = cairo_create (surface);
  
  cairo_text_extents_t te;
  cairo_set_source_rgb (cr, 0.0, 0.0, 0.0);
  cairo_select_font_face (cr, "Georgia",
			  CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD);
  cairo_set_font_size (cr, size_font);
  cairo_text_extents (cr, "hello world!", &te);
  cairo_move_to (cr, x ,y);
  cairo_show_text (cr, "hello world!");
  cairo_fill(cr);
  cairo_surface_write_to_png(surface , file_path.c_str());

    return 0;
}

