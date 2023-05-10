from PIL import Image, ImageDraw, ImageFont

transparent = False

def draw_text(text):

    image = Image.open('button.png')

    width = image.width
    height = image.height
    '''
    # Set image size
    width = 400
    height = 150

    # Create a new image with a white background
    if transparent:
        image = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    else:
        image = Image.new('RGB', (width, height), (255, 255, 255))
    '''
    # Get a font
    font = ImageFont.truetype('impact.ttf', size=64)

    # Get a drawing context
    draw = ImageDraw.Draw(image)

    # Get the size of the text
    text_width, text_height = draw.textbbox((0, 0), text, font)[2:]

    # Calculate the x and y coordinates for centering the text
    x = (width - text_width) / 2
    y = (height - text_height-8) / 2

    # Draw the text in the center of the image
    draw.text((x, y), text, font=font, fill=(0, 0, 0, 255))

    # Save the image as a PNG file
    image.save(text.lower()+'.png')
    print(text.lower()+'.png')

draw_text('Sign-Up')
draw_text('Start')
draw_text('Finish')
draw_text('Tip')
draw_text('INFO')
draw_text('Rules')
draw_text('Calendar')
draw_text('List')