from logging import raiseExceptions
from inky.inky_uc8159 import Inky
import numpy
from PIL import Image

INKY_IMPRESSION = 'inky_uc8159_colour'

SUPPORTED_MODELS = [INKY_IMPRESSION]

class Display:
    def __init__(self, epaper_model):
        if not epaper_model in SUPPORTED_MODELS:
            raise f'unsupported model {epaper_model}'
        self.model_name = epaper_model
        self.inky = Inky()
        self.saturation = 0.5

    def render(self, im_black, im_color = None):
        im_full = im_black
        im_color = Display._set_color(im_color)
        im_full.paste(im_color, (0,0), im_color)

        self.inky.set_image(im_full, saturation=self.saturation)
        self.inky.show()

    def calibrate(self, cycles = None):
        return

    def get_display_size(cls, model_name):
        if model_name == INKY_IMPRESSION:
            return 448, 600

    def get_display_names(cls):
        for d in SUPPORTED_MODELS:
            print(d)

    def _set_color(img):
        x = numpy.asarray(img.convert('RGBA')).copy()
        x[:, :, 3] = (255 * (x[:, :, :3] != 255).any(axis=2)).astype(numpy.uint8)
        red, green, blue, alpha = x.T # Temporarily unpack the bands for readability

        black_areas = (red == 0) & (blue == 0) & (green == 0)
        x[..., :-1][black_areas.T] = (255, 0, 0) # Transpose back needed
        return Image.fromarray(x)

if __name__ == '__main__':
  print("Running Display class in standalone mode")
