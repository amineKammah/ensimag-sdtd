import os
from typing import List

from PIL import Image

import pytesseract


class OpticalCharacterRecognizer:
    """
    Uses Tesseract to extract text from images.
    """
    def __init__(self):
        pass

    def extract(self, image_path: str):
        image = Image.open(image_path)
        return pytesseract.image_to_string(image)

    def extract_list(self, images: List[str]):
        text = []
        for image in images:
            text.append(self.extract(image))

        return text

    def extract_from_folder(self, folder_path: str):
        text = []
        for image_name in os.listdir(folder_path):
            image_path = folder_path + image_name
            text.append(self.extract(image_path))

        return text
