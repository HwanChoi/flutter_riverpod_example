from PIL import Image

img = Image.new('RGB', (200, 200), color = 'red')
img.save('assets/images/album_art.jpg')
