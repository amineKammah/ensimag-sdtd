import os

from pyspark import SparkContext

if __name__ == "__main__":
    test_data_path = "../test_data/how_to_win_argments/"

    images = []
    for image_name in os.listdir(test_data_path):
        image_path = test_data_path + image_name
        images.append(image_path)

    sc = SparkContext("local", "first app")
    sc.addPyFile('optical_character_recognizer.py')
    from optical_character_recognizer import OpticalCharacterRecognizer

    print(sc.parallelize(images).map(lambda image: OpticalCharacterRecognizer.extract(image)).collect())