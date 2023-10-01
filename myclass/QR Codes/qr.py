import qrcode
from PIL import Image, ImageDraw
# for i in range(19384101, 19384124):
for i in range(22370001, 22370070):
    qr = qrcode.QRCode(
        version=1,  # QR code version (adjust as needed)
        error_correction=qrcode.constants.ERROR_CORRECT_L,  # Error correction level
        box_size=10,  # Size of each box (adjust as needed)
        border=4,  # Border size (adjust as needed)
    )
    qr.add_data(i)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white")
    img.save(f"my_qr_code_{i}.png")

    # Add the text below the image
    image = Image.open(f"my_qr_code_{i}.png")
    draw = ImageDraw.Draw(image)
    draw.text((10, image.height - 20), str(i), fill="black")  # Specify text color as "black"
    image.save(f"my_qr_code_with_text_{i}.png")
