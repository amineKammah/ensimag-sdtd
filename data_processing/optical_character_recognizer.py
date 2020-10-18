import os
from typing import List

from PIL import Image

import pytesseract




class OpticalCharacterRecognizer:
    """
    Uses Tesseract to extract text from images.
    """
    @staticmethod
    def extract(image_path: str) -> str:
        image = Image.open(image_path)
        return pytesseract.image_to_string(image)

    @staticmethod
    def extract_list(images: List[str]) -> List[str]:
        text = []
        for image in images:
            text.append(OpticalCharacterRecognizer.extract(image))

        return text

    @staticmethod
    def extract_from_folder(folder_path: str) -> List[str]:
        text = []
        for image_name in os.listdir(folder_path):
            image_path = folder_path + image_name
            text.append(OpticalCharacterRecognizer.extract(image_path))

        return text
